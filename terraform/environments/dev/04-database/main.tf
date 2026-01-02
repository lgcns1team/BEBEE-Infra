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
# RDS (MySQL)
# ========================================

module "rds" {
  source = "../../../modules/rds"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr    = var.vpc_cidr

  # Bastion에서의 접근 허용
  allowed_security_groups = [data.terraform_remote_state.network.outputs.bastion_security_group_id]

  # Private Subnet 3, 4번 (Index 2, 3) 사용
  subnet_ids = [
    data.terraform_remote_state.network.outputs.private_subnet_ids[2],
    data.terraform_remote_state.network.outputs.private_subnet_ids[3]
  ]

  # DB 스펙 설정
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  multi_az          = true

  # DB 접속 정보
  db_name  = "bebee"
  username = "root"
  password = var.db_root_password

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ========================================
# ElastiCache (Redis)
# ========================================

module "elasticache" {
  source = "../../../modules/elasticache"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr    = var.vpc_cidr

  # Bastion에서의 접근 허용
  allowed_security_groups = [data.terraform_remote_state.network.outputs.bastion_security_group_id]

  # Private Subnet 3, 4번 (Index 2, 3) 사용
  subnet_ids = [
    data.terraform_remote_state.network.outputs.private_subnet_ids[2],
    data.terraform_remote_state.network.outputs.private_subnet_ids[3]
  ]

  # Redis 스펙 설정
  engine_version  = "7.0"
  node_type       = "cache.t3.micro"
  num_cache_nodes = 2

  # Backup 설정
  snapshot_retention_limit = 5
  snapshot_window          = "03:00-05:00"
  maintenance_window       = "mon:05:00-mon:07:00"

  # Auto upgrade
  auto_minor_version_upgrade = true

  # Encryption (개발 환경에서는 비활성화)
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ========================================
# MongoDB EC2
# ========================================

module "mongodb" {
  source = "../../../modules/mongodb-ec2"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr    = var.vpc_cidr

  # Private Subnet 3번 (Index 2) 사용 - RDS와 동일한 서브넷
  subnet_id = data.terraform_remote_state.network.outputs.private_subnet_ids[2]

  # MongoDB 인스턴스 스펙
  instance_type = var.mongodb_instance_type
  volume_type   = "gp3"
  volume_size   = var.mongodb_volume_size

  # 개발 환경에서는 볼륨 삭제 허용
  delete_volume_on_termination = true

  # MongoDB 관리자 계정 (선택사항)
  mongodb_admin_username = var.mongodb_admin_username
  mongodb_admin_password = var.mongodb_admin_password

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}