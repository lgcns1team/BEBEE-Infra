# ========================================
# Secrets Manager Secret
# ========================================

resource "aws_secretsmanager_secret" "main" {
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
  count = var.secret_string != null ? 1 : 0

  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string
}

# ========================================
# Secret Rotation (자동 회전 설정)
# ========================================

resource "aws_secretsmanager_secret_rotation" "main" {
  count = var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.main.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }

  depends_on = [aws_secretsmanager_secret_version.main]
}