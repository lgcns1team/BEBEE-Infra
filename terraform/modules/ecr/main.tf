# ========================================
# ECR Repository
# ========================================

resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # 이미지 스캔 설정
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # 암호화 설정
  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    var.tags,
    {
      Name = var.repository_name
    }
  )
}

# ========================================
# Lifecycle Policy (오래된 이미지 자동 삭제)
# ========================================

resource "aws_ecr_lifecycle_policy" "main" {
  count      = var.enable_lifecycle_policy ? 1 : 0
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최근 이미지 ${var.lifecycle_keep_count}개만 유지"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = var.lifecycle_keep_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ========================================
# Repository Policy (접근 제어)
# ========================================

resource "aws_ecr_repository_policy" "main" {
  count      = var.repository_policy != null ? 1 : 0
  repository = aws_ecr_repository.main.name
  policy     = var.repository_policy
}