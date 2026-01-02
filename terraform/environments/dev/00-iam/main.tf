# ========================================
# IAM User for S3 Local Testing
# ========================================
# 로컬 개발 환경에서 S3 접근을 위한 IAM User
# 여러 S3 버킷에 대해 재사용 가능하도록 패턴 기반 권한 부여

# IAM User 생성
resource "aws_iam_user" "s3_local_test" {
  name = "${var.project}-${var.environment}-s3-local-test-user"

  tags = {
    Name        = "${var.project}-${var.environment}-s3-local-test-user"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Purpose     = "Local Development S3 Access"
  }
}

# S3 접근 정책 (패턴 기반 - 모든 bebee-dev-* 버킷에 접근 가능)
resource "aws_iam_user_policy" "s3_access" {
  name = "${var.project}-${var.environment}-s3-access-policy"
  user = aws_iam_user.s3_local_test.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ObjectOperations"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project}-${var.environment}-*/*"
        ]
      },
      {
        Sid    = "AllowS3BucketOperations"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.project}-${var.environment}-*"
        ]
      }
    ]
  })
}

# IAM Access Key 생성 (로컬 테스트용)
resource "aws_iam_access_key" "s3_local_test" {
  user = aws_iam_user.s3_local_test.name
}

# ========================================
# IAM Role for EKS S3 Access (IRSA)
# ========================================
# EKS Pod가 S3에 접근하기 위한 IAM Role
# ServiceAccount를 통해 Pod에 연결됨

data "aws_caller_identity" "current" {}

# S3 접근용 IAM Policy (독립적인 Policy로 관리)
resource "aws_iam_policy" "s3_access" {
  name        = "${var.project}-${var.environment}-s3-access-policy"
  description = "Policy for EKS Pods to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ObjectOperations"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project}-${var.environment}-*/*"
        ]
      },
      {
        Sid    = "AllowS3BucketOperations"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.project}-${var.environment}-*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-s3-access-policy"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# S3 접근용 IAM Role (EKS IRSA)
resource "aws_iam_role" "s3_eks_access" {
  name = "${var.project}-${var.environment}-s3-eks-access-role"

  # EKS OIDC Provider를 통한 AssumeRole 정책
  # 실제 OIDC Provider ARN/URL은 05-application에서 data source로 참조
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/*"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "oidc.eks.ap-northeast-2.amazonaws.com/id/*:sub" = "system:serviceaccount:bebee:*-s3-sa"
            "oidc.eks.ap-northeast-2.amazonaws.com/id/*:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-s3-eks-access-role"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# IAM Role에 S3 Policy 연결
resource "aws_iam_role_policy_attachment" "s3_eks_access" {
  role       = aws_iam_role.s3_eks_access.name
  policy_arn = aws_iam_policy.s3_access.arn
}

