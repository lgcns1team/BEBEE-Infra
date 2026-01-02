output "s3_bucket_name" {
  description = "S3 이미지 버킷 이름"
  value       = module.s3_images.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 이미지 버킷 ARN"
  value       = module.s3_images.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "S3 이미지 버킷 도메인"
  value       = module.s3_images.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "S3 이미지 버킷 리전 도메인"
  value       = module.s3_images.bucket_regional_domain_name
}

output "s3_bucket_region" {
  description = "S3 이미지 버킷 리전"
  value       = module.s3_images.bucket_region
}

output "ecr_repository_urls" {
  description = "모든 ECR 리포지토리 URL 맵"
  value = {
    for service, repo in module.ecr : service => repo.repository_url
  }
}

output "ecr_repository_arns" {
  description = "모든 ECR 리포지토리 ARN 맵"
  value = {
    for service, repo in module.ecr : service => repo.repository_arn
  }
}

output "ecr_repository_names" {
  description = "모든 ECR 리포지토리 이름 맵"
  value = {
    for service, repo in module.ecr : service => repo.repository_name
  }
}