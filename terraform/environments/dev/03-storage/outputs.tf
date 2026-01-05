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

# ========================================
# CloudFront Outputs
# ========================================

output "cloudfront_distribution_id" {
  description = "이미지 CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.images.id
}

output "cloudfront_distribution_arn" {
  description = "이미지 CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.images.arn
}

output "cloudfront_distribution_domain_name" {
  description = "이미지 CloudFront Distribution 도메인 (이 URL을 file-service에서 사용)"
  value       = aws_cloudfront_distribution.images.domain_name
}

output "cloudfront_distribution_url" {
  description = "이미지 CloudFront Distribution HTTPS URL"
  value       = "https://${aws_cloudfront_distribution.images.domain_name}"
}