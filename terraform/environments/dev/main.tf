# VPC 모듈 호출
module "vpc" {
  source = "../../modules/vpc"

  name_prefix        = "${var.project}-${var.environment}"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Compute (Bastion) 모듈 호출
module "bastion" {
  source = "../../modules/bastion"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = module.vpc.vpc_id
  
  # Bastion 전용 입력 변수명 사용
  bastion_subnet_id        = module.vpc.public_subnet_ids[0]
  bastion_instance_type    = var.bastion_instance_type
  bastion_ssh_allowed_cidr = var.bastion_ssh_allowed_cidrs

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# RDS 모듈 호출
module "rds" {
  source = "../../modules/rds"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr

  # Bastion에서의 접근 허용
  allowed_security_groups = [module.bastion.bastion_security_group_id]

  # Private Subnet 3, 4번 (Index 2, 3) 사용
  subnet_ids = [
    module.vpc.private_subnet_ids[2],
    module.vpc.private_subnet_ids[3]
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

# ElastiCache (Redis) 모듈 호출
module "elasticache" {
  source = "../../modules/elasticache"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr

  # Bastion에서의 접근 허용
  allowed_security_groups = [module.bastion.bastion_security_group_id]

  # Private Subnet 3, 4번 (Index 2, 3) 사용
  subnet_ids = [
    module.vpc.private_subnet_ids[2],
    module.vpc.private_subnet_ids[3]
  ]

  # Redis 스펙 설정
  engine_version   = "7.0"
  node_type        = "cache.t3.micro"
  num_cache_nodes  = 2  # Primary 1개 + Replica 1개

  # Backup 설정
  snapshot_retention_limit = 5
  snapshot_window         = "03:00-05:00"
  maintenance_window      = "mon:05:00-mon:07:00"

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


# EKS 클러스터 모듈 호출
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "${var.project}-${var.environment}-cluster"
  cluster_version = var.eks_cluster_version

  # Private Subnet 1, 2번 (Index 0, 1) 사용
  subnet_ids = [
    module.vpc.private_subnet_ids[0],
    module.vpc.private_subnet_ids[1]
  ]

  # API 서버 접근 설정
  endpoint_private_access = true  # VPC 내부에서 접근 가능
  endpoint_public_access  = true  # 인터넷에서도 접근 가능 (개발 환경)
  public_access_cidrs     = var.eks_public_access_cidrs

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# S3 (이미지 저장소) 모듈 호출
module "s3_images" {
  source = "../../modules/s3"

  bucket_name = "${var.project}-${var.environment}-images"

  # 버저닝 활성화 (이미지 복구 가능)
  versioning_enabled = true

  # Private 버킷 (CloudFront 또는 Signed URL로 접근)
  # 일단 개발 편의성을 위한 false 로 설정
  block_public_access = false

  # CORS 설정 (웹 애플리케이션에서 업로드/다운로드)
  cors_allowed_origins = var.s3_cors_allowed_origins

  # 라이프사이클 정책 활성화
  lifecycle_enabled                  = true
  noncurrent_version_expiration_days = 90

  # 퍼블릭 읽기 비활성화 (개발 환경에서 테스트 시 true로 변경 가능)
  enable_bucket_policy = false

  # IAM Role for EKS (IRSA)
  # 주의: S3 모듈이 EKS 모듈보다 먼저 선언되어 있어 순환 참조 발생
  # 해결 방법: S3 모듈을 EKS 모듈 뒤로 이동하거나, 2단계로 적용
  # 1단계: create_iam_role = false로 EKS 클러스터 먼저 생성
  # 2단계: 아래 주석을 해제하고 create_iam_role = true로 변경 후 재적용
  create_iam_role = false
  # eks_oidc_provider_arn = module.eks.oidc_provider_arn
  # eks_oidc_provider_url = module.eks.oidc_provider_url
  # eks_service_account_namespace = "default"
  # eks_service_account_name = "s3-access-sa"

  # 로컬 테스트용 IAM User 생성
  create_local_test_user = true

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Purpose     = "Image Storage"
  }
}
