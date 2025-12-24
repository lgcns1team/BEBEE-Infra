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
