# ========================================
# S3 (이미지 저장소)
# ========================================
# IAM 리소스는 00-iam에서 별도 관리
# S3 모듈은 순수하게 버킷과 설정만 관리

module "s3_images" {
  source = "../../../modules/s3"

  bucket_name = "${var.project}-${var.environment}-images"

  # 버저닝 활성화 (이미지 복구 가능)
  versioning_enabled = true

  # Private 버킷 (CloudFront 또는 Signed URL로 접근)
  block_public_access = false

  # CORS 설정 (웹 애플리케이션에서 업로드/다운로드)
  cors_allowed_origins = var.s3_cors_allowed_origins

  # 라이프사이클 정책 활성화
  lifecycle_enabled                  = true
  noncurrent_version_expiration_days = 90

  # 퍼블릭 읽기 비활성화
  enable_bucket_policy = false

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Purpose     = "Image Storage"
  }
}

# ========================================
# CloudFront Origin Access Control (OAC)
# ========================================
# CloudFront가 S3 버킷에 안전하게 접근하기 위한 설정

resource "aws_cloudfront_origin_access_control" "images" {
  name                              = "${var.project}-${var.environment}-images-oac"
  description                       = "OAC for ${var.project} images S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ========================================
# CloudFront Distribution for Images
# ========================================
# 이미지 전송 최적화를 위한 CDN 배포

resource "aws_cloudfront_distribution" "images" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project}-${var.environment} Images Distribution"
  price_class     = var.cloudfront_price_class

  # S3 Origin 설정
  origin {
    domain_name              = module.s3_images.bucket_regional_domain_name
    origin_id                = "S3-${module.s3_images.bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.images.id
  }

  # 기본 캐시 동작 (이미지 최적화)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${module.s3_images.bucket_id}"

    # Managed Cache Policy - CachingOptimized
    # 이미지는 변경이 적으므로 긴 TTL 사용
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    # Managed Origin Request Policy - CORS-S3Origin
    # CORS 헤더를 S3로 전달
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    # Managed Response Headers Policy - CORS-with-preflight-and-SecurityHeadersPolicy
    # CORS 및 보안 헤더 추가
    response_headers_policy_id = "e61eb60c-9c35-4d20-a928-2b84e02af89c"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # 지리적 제한 없음
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL 인증서 (CloudFront 기본 인증서 사용)
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-images-cdn"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Purpose     = "Image CDN"
  }

  # AWS 콘솔에서 수동으로 변경한 내용을 Terraform이 되돌리지 않도록 설정
  lifecycle {
    ignore_changes = [
      aliases,              # 커스텀 도메인
      viewer_certificate,   # ACM 인증서
    ]
  }
}

# ========================================
# S3 Bucket Policy (CloudFront Access Only)
# ========================================
# CloudFront만 S3에 접근 가능하도록 설정

resource "aws_s3_bucket_policy" "images_cloudfront_access" {
  bucket = module.s3_images.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_images.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.images.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.images]
}

# ========================================
# ECR Repositories (Container Registry)
# ========================================

module "ecr" {
  for_each = var.ecr_repositories
  source   = "../../../modules/ecr"

  repository_name      = "bebee-${each.key}-service"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  enable_lifecycle_policy = true
  lifecycle_keep_count    = 10

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Service     = each.key
  }
}