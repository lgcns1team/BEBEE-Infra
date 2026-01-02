# ========================================
# Outputs
# ========================================

# IAM User (로컬 테스트용)
output "s3_local_test_user_name" {
  description = "S3 로컬 테스트용 IAM User 이름"
  value       = aws_iam_user.s3_local_test.name
}

output "s3_local_test_user_arn" {
  description = "S3 로컬 테스트용 IAM User ARN"
  value       = aws_iam_user.s3_local_test.arn
}

output "s3_access_key_id" {
  description = "S3 접근용 Access Key ID"
  value       = aws_iam_access_key.s3_local_test.id
  sensitive   = true
}

output "s3_secret_access_key" {
  description = "S3 접근용 Secret Access Key"
  value       = aws_iam_access_key.s3_local_test.secret
  sensitive   = true
}

# IAM Role (EKS IRSA용)
output "s3_eks_access_role_arn" {
  description = "S3 접근용 IAM Role ARN (EKS IRSA)"
  value       = aws_iam_role.s3_eks_access.arn
}

output "s3_eks_access_role_name" {
  description = "S3 접근용 IAM Role 이름 (EKS IRSA)"
  value       = aws_iam_role.s3_eks_access.name
}

output "s3_access_policy_arn" {
  description = "S3 접근용 IAM Policy ARN"
  value       = aws_iam_policy.s3_access.arn
}