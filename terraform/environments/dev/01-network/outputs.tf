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

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway Public IP"
  value       = module.vpc.nat_gateway_public_ip
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = module.bastion.bastion_public_ip
}

output "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  value       = module.bastion.bastion_security_group_id
}

output "bastion_private_key_path" {
  description = "Bastion 접속용 키 파일 위치"
  value       = module.bastion.private_key_path
}

output "bastion_key_pair_name" {
  description = "Bastion SSH Key Pair 이름"
  value       = module.bastion.key_pair_name
}

# ========================================
# ALB Outputs
# ========================================

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "alb_name" {
  description = "ALB 이름 (Ingress에서 참조)"
  value       = module.alb.alb_name
}

output "alb_dns_name" {
  description = "ALB DNS 이름 (Route53 등록용)"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID (Route53 Alias 레코드용)"
  value       = module.alb.alb_zone_id
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = module.alb.alb_security_group_id
}