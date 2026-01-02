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