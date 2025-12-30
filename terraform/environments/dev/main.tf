# ========================================
# Data Sources (동적 값 조회)
# ========================================

# 현재 AWS Region 정보
data "aws_region" "current" {}

# 현재 AWS Account ID 정보
data "aws_caller_identity" "current" {}

# ========================================
# VPC Module
# ========================================

# VPC 모듈 호출
module "vpc" {
  source = "../../modules/vpc"

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

  # IAM Role for EKS (IRSA) - file-service용 S3 접근
  create_iam_role               = true
  eks_oidc_provider_arn         = module.eks.oidc_provider_arn
  eks_oidc_provider_url         = module.eks.oidc_provider_url
  eks_service_account_namespace = "bebee"
  eks_service_account_name      = "bebee-s3-sa"

  # 로컬 테스트용 IAM User 생성
  create_local_test_user = true

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Purpose     = "Image Storage"
  }
}

# ========================================
# ECR Repositories (Container Registry)
# ========================================

module "ecr" {
  for_each = var.ecr_repositories
  source   = "../../modules/ecr"

  repository_name      = "bebee-${each.key}-service"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  enable_lifecycle_policy = true
  lifecycle_keep_count    = 10

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Service     = each.key
  }
}

# ========================================
# Secrets Manager (시크릿 관리)
# ========================================

# Database Credentials
module "secret_db_credentials" {
  for_each = var.db_schemas
  source = "../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-${each.key}-db-credentials"
  description = "RDS 데이터베이스 접속 정보"

  # RDS 모듈에서 생성된 정보를 자동으로 Secrets Manager에 저장
  secret_string = jsonencode({
    username = each.value.username
    password = var.db_bebee_password
    engine   = module.rds.engine
    host     = module.rds.address
    port     = module.rds.port
    dbname   = each.value.db_name
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "database"
  }

  depends_on = [module.rds]
}

# Redis Credentials
module "secret_redis_credentials" {
  source = "../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-redis-credentials"
  description = "ElastiCache Redis 접속 정보"

  # ElastiCache 모듈에서 생성된 정보를 자동으로 Secrets Manager에 저장
  secret_string = jsonencode({
    primary_endpoint = module.elasticache.primary_endpoint_address
    reader_endpoint  = module.elasticache.reader_endpoint_address
    port             = module.elasticache.port
    # 개발 환경에서는 인증 비활성화 (transit_encryption_enabled = false)
    # 운영 환경에서는 auth_token 추가 필요
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "cache"
  }

  depends_on = [module.elasticache]
}

# Application JWT Secret
module "secret_jwt" {
  source = "../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-jwt-secret"
  description = "JWT 토큰 생성용 Secret Key"

  # 변수로 전달받은 JWT Secret 저장
  secret_string = jsonencode({
    jwt_secret               = var.jwt_secret
    algorithm                = "HS256"
    issuer                   = var.jwt_issuer
    access_token_expires_in  = var.access_token_expires_in
    refresh_token_expires_in = var.refresh_token_expires_in
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "application"
  }
}

# AWS Configuration
module "secret_aws" {
  source = "../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-aws-config"
  description = "AWS 공통 설정 (Region, Account 등)"

  # AWS 환경 정보
  secret_string = jsonencode({
    region     = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "aws"
  }
}

# S3 Images Bucket Information
module "secret_s3_images" {
  source = "../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-s3-images"
  description = "S3 Images Bucket 접속 정보"

  # S3 모듈에서 생성된 정보를 자동으로 Secrets Manager에 저장
  secret_string = jsonencode({
    bucket_name                  = module.s3_images.bucket_name
    bucket_arn                   = module.s3_images.bucket_arn
    region                       = module.s3_images.bucket_region
    bucket_domain_name           = module.s3_images.bucket_domain_name
    bucket_regional_domain_name  = module.s3_images.bucket_regional_domain_name
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "storage"
  }

  depends_on = [module.s3_images]
}

# Application Configuration
module "secret_app" {
  source = "../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-app-config"
  description = "애플리케이션 공통 설정"

  # 애플리케이션 환경 설정
  secret_string = jsonencode({
    # Server 설정
    server_port = "8080"
    
    # Swagger/API 문서 설정
    springdoc_api_host = ""  # 개발 환경에서는 비워둠
    springdoc_api_desc = "개발 서버"
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "application"
  }
}

# ========================================
# 통합 Secrets Manager IRSA (모든 서비스 공용)
# ========================================
module "secrets_manager_irsa" {
  source = "../../modules/secrets-manager"

  # Secret은 생성하지 않음 (IRSA만 생성)
  create_secret = false
  secret_name   = "${var.project}-${var.environment}-secrets-manager"

  # IRSA 생성
  create_iam_policy = true
  create_iam_role   = true

  # 통합 IAM Role/Policy 이름
  iam_role_name   = "${var.project}-${var.environment}-secrets-manager-access-role"
  iam_policy_name = "${var.project}-${var.environment}-secrets-manager-access"

  # EKS OIDC Provider 정보
  eks_oidc_provider_arn         = module.eks.oidc_provider_arn
  eks_oidc_provider_url         = module.eks.oidc_provider_url
  eks_service_account_namespace = "bebee"
  eks_service_account_name      = "*-secrets-sa"

  # 와일드카드 ServiceAccount 패턴 사용
  use_service_account_wildcard = true

  # 모든 bebee-dev-* secrets에 접근
  use_wildcard_secrets   = true
  wildcard_secret_prefix = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project}-${var.environment}-*"

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "irsa"
  }
}