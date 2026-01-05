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


