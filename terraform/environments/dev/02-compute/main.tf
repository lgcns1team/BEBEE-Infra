# ========================================
# Data Sources
# ========================================

# Network state (VPC, Subnet 정보 참조)
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../01-network/terraform.tfstate"
  }
}

# ========================================
# EKS Cluster
# ========================================

module "eks" {
  source = "../../../modules/eks"

  cluster_name    = "${var.project}-${var.environment}-cluster"
  cluster_version = var.eks_cluster_version

  # Private Subnet 1, 2번 (Index 0, 1) 사용
  subnet_ids = [
    data.terraform_remote_state.network.outputs.private_subnet_ids[0],
    data.terraform_remote_state.network.outputs.private_subnet_ids[1]
  ]

  # API 서버 접근 설정
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.eks_public_access_cidrs

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}