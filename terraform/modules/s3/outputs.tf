output "bucket_id" {
  description = "S3 버킷 ID"
  value       = aws_s3_bucket.images.id
}

output "bucket_arn" {
  description = "S3 버킷 ARN"
  value       = aws_s3_bucket.images.arn
}

output "bucket_name" {
  description = "S3 버킷 이름"
  value       = aws_s3_bucket.images.bucket
}

output "bucket_domain_name" {
  description = "S3 버킷 도메인 이름"
  value       = aws_s3_bucket.images.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "S3 버킷 리전별 도메인 이름"
  value       = aws_s3_bucket.images.bucket_regional_domain_name
}

output "bucket_region" {
  description = "S3 버킷이 위치한 리전"
  value       = aws_s3_bucket.images.region
}