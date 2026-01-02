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
# NOTE: IAM 리소스는 00-iam 디렉토리에서 별도 관리
# ========================================
# S3 모듈은 순수하게 S3 버킷과 설정만 관리합니다.
# IAM User, IAM Role, IAM Policy는 00-iam에서 생성하고,
# 05-application에서 연결합니다.