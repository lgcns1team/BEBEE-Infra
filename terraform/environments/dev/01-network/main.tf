# ========================================
# VPC Module
# ========================================

module "vpc" {
  source = "../../../modules/vpc"

  name_prefix        = "${var.project}-${var.environment}"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # EKS 클러스터 이름 전달 (서브넷 태그용)
  cluster_name = "${var.project}-${var.environment}-cluster"

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ========================================
# Bastion Host
# ========================================

module "bastion" {
  source = "../../../modules/bastion"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = module.vpc.vpc_id

  bastion_subnet_id        = module.vpc.public_subnet_ids[0]
  bastion_instance_type    = var.bastion_instance_type
  bastion_ssh_allowed_cidr = var.bastion_ssh_allowed_cidrs

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ========================================
# Application Load Balancer (Ingress용)
# ========================================
# Network 레이어에서 영구적으로 생성
# Compute(EKS)를 올렸다/내렸다 해도 ALB는 유지 → Route53 변경 불필요

module "alb" {
  source = "../../../modules/alb"

  name_prefix           = "${var.project}-${var.environment}"
  alb_name              = "${var.project}-${var.environment}-ingress-alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  cluster_name_hardcode = "${var.project}-${var.environment}-cluster"

  # 개발 환경에서는 삭제 보호 비활성화
  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Purpose     = "Kubernetes Ingress"
  }
}