output "secret_id" {
  description = "시크릿 ID"
  value       = try(aws_secretsmanager_secret.main[0].id, null)
}

output "secret_arn" {
  description = "시크릿 ARN"
  value       = try(aws_secretsmanager_secret.main[0].arn, null)
}

output "secret_name" {
  description = "시크릿 이름"
  value       = try(aws_secretsmanager_secret.main[0].name, null)
}

output "version_id" {
  description = "현재 시크릿 버전 ID"
  value       = try(aws_secretsmanager_secret_version.main[0].version_id, null)
}

output "version_stages" {
  description = "현재 시크릿 버전 스테이지"
  value       = try(aws_secretsmanager_secret_version.main[0].version_stages, null)
}

# ========================================
# IRSA Outputs
# ========================================

output "iam_role_arn" {
  description = "EKS Service Account용 IAM Role ARN"
  value       = try(aws_iam_role.secrets_manager_access[0].arn, null)
}

output "iam_role_name" {
  description = "EKS Service Account용 IAM Role 이름"
  value       = try(aws_iam_role.secrets_manager_access[0].name, null)
}

output "iam_policy_arn" {
  description = "Secrets Manager 접근 IAM Policy ARN"
  value       = try(aws_iam_policy.secrets_manager_access[0].arn, null)
}