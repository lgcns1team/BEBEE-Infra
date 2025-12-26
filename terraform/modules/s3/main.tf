# ========================================
# S3 Bucket for Image Storage
# ========================================

# S3 버킷 생성
resource "aws_s3_bucket" "images" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    {
      Name    = var.bucket_name
      Purpose = "Image Storage"
    }
  )
}

# 버킷 버저닝 설정 (이미지 복구 및 버전 관리)
resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

# 서버 측 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public Access Block 설정
resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# CORS 설정 (웹 애플리케이션에서 이미지 업로드/다운로드)
resource "aws_s3_bucket_cors_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# 라이프사이클 정책 (오래된 버전 자동 삭제)
resource "aws_s3_bucket_lifecycle_configuration" "images" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.images.id

  # 이전 버전 자동 삭제
  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  # Incomplete Multipart Upload 정리
  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# 버킷 정책 (선택적 - CloudFront 또는 특정 리소스만 접근 허용)
resource "aws_s3_bucket_policy" "images" {
  count  = var.enable_bucket_policy ? 1 : 0
  bucket = aws_s3_bucket.images.id

  # 개발 편의성을 위해서(FE)가 바로 확인할 수 있도록 설정!!
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPublicRead"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.images.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.images]
}

# ========================================
# IAM Policy for S3 Access
# ========================================
# 애플리케이션(EC2/ECS/Lambda)이 S3 버킷에 접근하기 위한 IAM 정책

# IAM Policy Document (정책 내용 정의)
data "aws_iam_policy_document" "s3_access" {
  # 이미지 업로드 권한
  statement {
    sid    = "AllowPutObject"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${aws_s3_bucket.images.arn}/*"
    ]
  }

  # 이미지 다운로드 권한
  statement {
    sid    = "AllowGetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "${aws_s3_bucket.images.arn}/*"
    ]
  }

  # 이미지 삭제 권한
  statement {
    sid    = "AllowDeleteObject"
    effect = "Allow"
    actions = [
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.images.arn}/*"
    ]
  }

  # 버킷 목록 조회 권한
  statement {
    sid    = "AllowListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.images.arn
    ]
  }
}

# IAM Policy 생성
resource "aws_iam_policy" "s3_access" {
  name        = "${var.bucket_name}-access-policy"
  description = "Policy for accessing ${var.bucket_name} S3 bucket"
  policy      = data.aws_iam_policy_document.s3_access.json

  tags = merge(
    var.tags,
    {
      Name = "${var.bucket_name}-access-policy"
    }
  )
}

# ========================================
# IAM Role for EKS (IRSA - IAM Roles for Service Accounts)
# ========================================
# EKS Pod에서 S3에 접근하기 위한 IAM Role

resource "aws_iam_role" "s3_access" {
  count = var.create_iam_role && var.eks_oidc_provider_arn != "" ? 1 : 0

  name = "${var.bucket_name}-eks-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
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
      Name = "${var.bucket_name}-eks-access-role"
    }
  )
}

# IAM Role에 Policy 연결
resource "aws_iam_role_policy_attachment" "s3_access" {
  count = var.create_iam_role && var.eks_oidc_provider_arn != "" ? 1 : 0

  role       = aws_iam_role.s3_access[0].name
  policy_arn = aws_iam_policy.s3_access.arn
}

# ========================================
# IAM User for Local Testing (Optional)
# ========================================
# 로컬 개발 환경에서 S3 접근을 테스트하기 위한 IAM User

resource "aws_iam_user" "local_test" {
  count = var.create_local_test_user ? 1 : 0

  name = "${var.bucket_name}-local-test-user"

  tags = merge(
    var.tags,
    {
      Name    = "${var.bucket_name}-local-test-user"
      Purpose = "Local Development Testing"
    }
  )
}

# IAM User에 Policy 연결
resource "aws_iam_user_policy_attachment" "local_test" {
  count = var.create_local_test_user ? 1 : 0

  user       = aws_iam_user.local_test[0].name
  policy_arn = aws_iam_policy.s3_access.arn
}

# IAM Access Key 생성 (로컬 테스트용)
resource "aws_iam_access_key" "local_test" {
  count = var.create_local_test_user ? 1 : 0

  user = aws_iam_user.local_test[0].name
}