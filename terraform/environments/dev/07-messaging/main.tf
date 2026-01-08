# ========================================
# Data Sources
# ========================================

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Compute state (EKS 정보 참조용 - 필요시 사용)
data "terraform_remote_state" "compute" {
  backend = "local"

  config = {
    path = "../02-compute/terraform.tfstate"
  }
}

# ========================================
# SNS Topics (Domain Events)
# ========================================

# 각 서비스별 도메인 이벤트 Topic 생성
module "sns_topics" {
  source   = "../../../modules/sns"
  for_each = var.service_names

  name_prefix = "${var.project}-${var.environment}-${each.key}"

  # 개발 환경에서는 암호화 비활성화 (KMS 권한 이슈 회피)
  kms_master_key_id = ""

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Service     = "${each.key}-service"
    Type        = "DomainEvent"
  }
}

# ========================================
# SQS Queues (Consumers)
# ========================================

locals {
  # 서비스별 구독할 SNS Topic 매핑
  subscription_map = {
    match        = ["member"]
    chat         = ["member", "match"]
    notification = ["chat", "match"]
    payment = ["match"]
  }

  # 구독 관계를 (Queue, Topic) 쌍의 리스트로 변환
  subscriptions = flatten([
    for queue_key, topics in local.subscription_map : [
      for topic_key in topics : {
        queue_key = queue_key
        topic_key = topic_key
      }
    ]
  ])
}

# 모든 서비스에 대해 기본 큐 생성
module "sqs_queues" {
  source   = "../../../modules/sqs"
  for_each = var.service_names

  name_prefix = "${var.project}-${var.environment}-${each.key}"

  # 구독 로직 제거 (모듈 외부에서 처리)
  visibility_timeout_seconds = 30
  max_receive_count          = 3

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Service     = "${each.key}-service"
    Usage       = "MainQueue"
  }
}

# SNS 구독 연결 (Queue -> Topic)
resource "aws_sns_topic_subscription" "sub" {
  for_each = {
    for s in local.subscriptions : "${s.queue_key}-${s.topic_key}" => s
  }

  topic_arn = module.sns_topics[each.value.topic_key].topic_arn
  protocol  = "sqs"
  endpoint  = module.sqs_queues[each.value.queue_key].queue_arn
}

# SQS 정책 설정 (SNS가 SQS에 메시지를 보낼 수 있도록 허용)
resource "aws_sqs_queue_policy" "sns_subscribe" {
  for_each = local.subscription_map

  queue_url = module.sqs_queues[each.key].queue_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = module.sqs_queues[each.key].queue_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = [
              for t in each.value : module.sns_topics[t].topic_arn
            ]
          }
        }
      }
    ]
  })
}

# ========================================
# IRSA (IAM Roles for Service Accounts)
# ========================================

# IAM Policy - SNS/SQS 접근 권한
resource "aws_iam_policy" "messaging_access" {
  name        = "${var.project}-${var.environment}-messaging-access-policy"
  description = "Policy for EKS pods to access SNS and SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SNSPublish"
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.project}-${var.environment}-*"
      },
      {
        Sid    = "SQSConsume"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.project}-${var.environment}-*"
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "sns.${data.aws_region.current.name}.amazonaws.com",
              "sqs.${data.aws_region.current.name}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# IAM Role - EKS ServiceAccount에서 assume할 Role
resource "aws_iam_role" "messaging_eks_access" {
  name        = "${var.project}-${var.environment}-messaging-eks-access-role"
  description = "IAM Role for EKS pods to access SNS and SQS via IRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.terraform_remote_state.compute.outputs.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "${replace(data.terraform_remote_state.compute.outputs.eks_oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:bebee:*-messaging-sa"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# IAM Policy 를 Role에 연결
resource "aws_iam_role_policy_attachment" "messaging_eks_access" {
  role       = aws_iam_role.messaging_eks_access.name
  policy_arn = aws_iam_policy.messaging_access.arn
}
