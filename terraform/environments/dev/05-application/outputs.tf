output "secret_db_credentials_arns" {
  description = "DB Credentials Secret ARNs"
  value = {
    for service, secret in module.secret_db_credentials : service => secret.secret_arn
  }
}

output "secret_redis_credentials_arn" {
  description = "Redis Credentials Secret ARN"
  value       = module.secret_redis_credentials.secret_arn
}

output "secret_jwt_arn" {
  description = "JWT Secret ARN"
  value       = module.secret_jwt.secret_arn
}

output "secret_aws_arn" {
  description = "AWS Config Secret ARN"
  value       = module.secret_aws.secret_arn
}

output "secret_s3_images_arn" {
  description = "S3 Images Secret ARN"
  value       = module.secret_s3_images.secret_arn
}

output "secret_app_arn" {
  description = "App Config Secret ARN"
  value       = module.secret_app.secret_arn
}

output "secrets_manager_irsa_role_arn" {
  description = "Secrets Manager IRSA Role ARN"
  value       = module.secrets_manager_irsa.iam_role_arn
}

output "secrets_manager_irsa_policy_arn" {
  description = "Secrets Manager IRSA Policy ARN"
  value       = module.secrets_manager_irsa.iam_policy_arn
}