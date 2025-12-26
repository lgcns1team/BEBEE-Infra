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

output "iam_policy_arn" {
  description = "S3 접근용 IAM Policy ARN"
  value       = aws_iam_policy.s3_access.arn
}

output "iam_policy_name" {
  description = "S3 접근용 IAM Policy 이름"
  value       = aws_iam_policy.s3_access.name
}

output "iam_role_arn" {
  description = "S3 접근용 IAM Role ARN (EKS IRSA용)"
  value       = var.create_iam_role && var.eks_oidc_provider_arn != "" ? aws_iam_role.s3_access[0].arn : null
}

output "iam_role_name" {
  description = "S3 접근용 IAM Role 이름 (EKS IRSA용)"
  value       = var.create_iam_role && var.eks_oidc_provider_arn != "" ? aws_iam_role.s3_access[0].name : null
}

output "local_test_user_name" {
  description = "로컬 테스트용 IAM User 이름"
  value       = var.create_local_test_user ? aws_iam_user.local_test[0].name : null
}

output "local_test_access_key_id" {
  description = "로컬 테스트용 Access Key ID"
  value       = var.create_local_test_user ? aws_iam_access_key.local_test[0].id : null
  sensitive   = true
}

output "local_test_secret_access_key" {
  description = "로컬 테스트용 Secret Access Key"
  value       = var.create_local_test_user ? aws_iam_access_key.local_test[0].secret : null
  sensitive   = true
}