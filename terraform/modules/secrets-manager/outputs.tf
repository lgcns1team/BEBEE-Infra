output "secret_id" {
  description = "시크릿 ID"
  value       = aws_secretsmanager_secret.main.id
}

output "secret_arn" {
  description = "시크릿 ARN"
  value       = aws_secretsmanager_secret.main.arn
}

output "secret_name" {
  description = "시크릿 이름"
  value       = aws_secretsmanager_secret.main.name
}

output "version_id" {
  description = "현재 시크릿 버전 ID"
  value       = try(aws_secretsmanager_secret_version.main[0].version_id, null)
}

output "version_stages" {
  description = "현재 시크릿 버전 스테이지"
  value       = try(aws_secretsmanager_secret_version.main[0].version_stages, null)
}