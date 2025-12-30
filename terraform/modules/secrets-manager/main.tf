# ========================================
# Secrets Manager Secret
# ========================================

resource "aws_secretsmanager_secret" "main" {
  count = var.create_secret ? 1 : 0

  name        = var.secret_name
  description = var.description
  kms_key_id  = var.kms_key_id

  # 삭제 시 복구 기간 설정
  recovery_window_in_days = var.recovery_window_in_days

  # 다중 리전 복제 설정
  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_id
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.secret_name
    }
  )
}

# ========================================
# Secret Version (시크릿 값 저장)
# ========================================

# 시크릿 값이 제공된 경우에만 버전 생성
resource "aws_secretsmanager_secret_version" "main" {
  count = var.create_secret && var.secret_string != null ? 1 : 0

  secret_id     = aws_secretsmanager_secret.main[0].id
  secret_string = var.secret_string
}

# ========================================
# Secret Rotation (자동 회전 설정)
# ========================================

resource "aws_secretsmanager_secret_rotation" "main" {
  count = var.create_secret && var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.main[0].id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }

  depends_on = [aws_secretsmanager_secret_version.main]
}

# ========================================
# IAM Policy for Secrets Manager Access
# ========================================
# 애플리케이션(EKS Pod)이 Secrets Manager에 접근하기 위한 IAM 정책

# IAM Policy Document (정책 내용 정의)
data "aws_iam_policy_document" "secrets_manager_access" {
  # Secret 값 읽기 권한
  statement {
    sid    = "AllowGetSecretValue"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    # 와일드카드 사용 시: 지정된 prefix의 모든 secrets
    # 아니면: 현재 secret + 추가 secret ARN 목록
    resources = var.use_wildcard_secrets ? [
      var.wildcard_secret_prefix
    ] : var.create_secret ? concat(
      [aws_secretsmanager_secret.main[0].arn],
      var.additional_secret_arns
    ) : var.additional_secret_arns
  }
}

# IAM Policy 생성
resource "aws_iam_policy" "secrets_manager_access" {
  count = var.create_iam_policy ? 1 : 0

  name        = var.iam_policy_name != "" ? var.iam_policy_name : "${var.secret_name}-access-policy"
  description = "Policy for accessing Secrets Manager"
  policy      = data.aws_iam_policy_document.secrets_manager_access.json

  tags = merge(
    var.tags,
    {
      Name = var.iam_policy_name != "" ? var.iam_policy_name : "${var.secret_name}-access-policy"
    }
  )
}

# ========================================
# IAM Role for EKS (IRSA - IAM Roles for Service Accounts)
# ========================================
# EKS Pod에서 Secrets Manager에 접근하기 위한 IAM Role

resource "aws_iam_role" "secrets_manager_access" {
  count = var.create_iam_role ? 1 : 0

  name = var.iam_role_name != "" ? var.iam_role_name : "${var.secret_name}-eks-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = var.use_service_account_wildcard ? {
          # 와일드카드 패턴 사용 (예: *-secrets-sa)
          StringLike = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.eks_service_account_namespace}:${var.eks_service_account_name}"
          }
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        } : {
          # 정확한 ServiceAccount 이름 매칭
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.eks_service_account_namespace}:${var.eks_service_account_name}"
            "${replace(var.eks_oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.secret_name}-eks-access-role"
    }
  )
}

# IAM Role에 Policy 연결
resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  count = var.create_iam_role && var.create_iam_policy ? 1 : 0

  role       = aws_iam_role.secrets_manager_access[0].name
  policy_arn = aws_iam_policy.secrets_manager_access[0].arn
}