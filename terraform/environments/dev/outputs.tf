output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = module.vpc.vpc_cidr
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = module.vpc.vpc_arn
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID 리스트"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private 서브넷 ID 리스트"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "rds_endpoint" {
  description = "RDS 접속 엔드포인트"
  value       = module.rds.endpoint
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = module.bastion.bastion_public_ip
}

output "bastion_private_key_path" {
  description = "Bastion 접속용 키 파일 위치"
  value       = module.bastion.private_key_path
}

output "redis_primary_endpoint" {
  description = "Redis Primary 엔드포인트 (읽기/쓰기)"
  value       = module.elasticache.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis Reader 엔드포인트 (읽기 전용)"
  value       = module.elasticache.reader_endpoint_address
}

output "redis_port" {
  description = "Redis 포트"
  value       = module.elasticache.port
}

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

output "s3_iam_policy_arn" {
  description = "S3 접근용 IAM Policy ARN"
  value       = module.s3_images.iam_policy_arn
}

output "s3_iam_role_arn" {
  description = "S3 접근용 IAM Role ARN (EKS IRSA용)"
  value       = module.s3_images.iam_role_arn
}

output "s3_local_test_user_name" {
  description = "S3 로컬 테스트용 IAM User 이름"
  value       = module.s3_images.local_test_user_name
}

output "s3_local_test_access_key_id" {
  description = "S3 로컬 테스트용 Access Key ID (민감 정보)"
  value       = module.s3_images.local_test_access_key_id
  sensitive   = true
}

output "s3_local_test_secret_access_key" {
  description = "S3 로컬 테스트용 Secret Access Key (민감 정보)"
  value       = module.s3_images.local_test_secret_access_key
  sensitive   = true
}
