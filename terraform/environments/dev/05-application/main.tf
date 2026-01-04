# ========================================
# Data Sources
# ========================================

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Database state (RDS, Redis 정보 참조)
data "terraform_remote_state" "database" {
  backend = "local"

  config = {
    path = "../04-database/terraform.tfstate"
  }
}


# Compute state (EKS OIDC 정보 참조)
data "terraform_remote_state" "compute" {
  backend = "local"

  config = {
    path = "../02-compute/terraform.tfstate"
  }
}

# Storage state (S3 정보 참조)
data "terraform_remote_state" "storage" {
  backend = "local"

  config = {
    path = "../03-storage/terraform.tfstate"
  }
}


# ========================================
# Secrets Manager - Database Credentials
# ========================================

module "secret_db_credentials" {
  for_each = var.db_schemas
  source   = "../../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-${each.key}-db-credentials"
  description = "RDS 데이터베이스 접속 정보"

  secret_string = jsonencode({
    username = each.value.username
    password = var.db_bebee_password
    engine   = data.terraform_remote_state.database.outputs.rds_engine
    host     = data.terraform_remote_state.database.outputs.rds_address
    port     = data.terraform_remote_state.database.outputs.rds_port
    dbname   = each.value.db_name
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "database"
  }
}

# ========================================
# Secrets Manager - Redis Credentials
# ========================================

module "secret_redis_credentials" {
  source = "../../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-redis-credentials"
  description = "ElastiCache Redis 접속 정보"

  secret_string = jsonencode({
    primary_endpoint = data.terraform_remote_state.database.outputs.redis_primary_endpoint
    reader_endpoint  = data.terraform_remote_state.database.outputs.redis_reader_endpoint
    port             = data.terraform_remote_state.database.outputs.redis_port
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "cache"
  }
}

# ========================================
# Secrets Manager - MongoDB Credentials
# ========================================

module "secret_mongodb_credentials" {
  source = "../../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-mongodb-credentials"
  description = "MongoDB 접속 정보"

  secret_string = jsonencode({
    host     = data.terraform_remote_state.database.outputs.mongodb_private_ip
    username = var.mongodb_username
    password = var.mongodb_password
    uri      = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${data.terraform_remote_state.database.outputs.mongodb_private_ip}:27017/bebee?authSource=bebee"
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "database"
  }
}

# ========================================
# Secrets Manager - JWT Secret
# ========================================

module "secret_jwt" {
  source = "../../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-jwt-secret"
  description = "JWT 토큰 생성용 Secret Key"

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

# ========================================
# Secrets Manager - AWS Configuration
# ========================================

module "secret_aws" {
  source = "../../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-aws-config"
  description = "AWS 공통 설정 (Region, Account 등)"

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

# ========================================
# Secrets Manager - S3 Images Bucket
# ========================================

module "secret_s3_images" {
  source = "../../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-s3-images"
  description = "S3 Images Bucket 접속 정보"

  secret_string = jsonencode({
    bucket_name                 = data.terraform_remote_state.storage.outputs.s3_bucket_name
    bucket_arn                  = data.terraform_remote_state.storage.outputs.s3_bucket_arn
    region                      = data.terraform_remote_state.storage.outputs.s3_bucket_region
    bucket_domain_name          = data.terraform_remote_state.storage.outputs.s3_bucket_domain_name
    bucket_regional_domain_name = data.terraform_remote_state.storage.outputs.s3_bucket_regional_domain_name
  })

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "storage"
  }
}

# ========================================
# Secrets Manager - Application Config
# ========================================

module "secret_app" {
  source = "../../../modules/secrets-manager"

  secret_name = "${var.project}-${var.environment}-app-config"
  description = "애플리케이션 공통 설정"

  secret_string = jsonencode({
    server_port        = "8080"
    springdoc_api_host = ""
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
# Secrets Manager IRSA (통합)
# ========================================

module "secrets_manager_irsa" {
  source = "../../../modules/secrets-manager"

  create_secret = false
  secret_name   = "${var.project}-${var.environment}-secrets-manager"

  create_iam_policy = true
  create_iam_role   = true

  iam_role_name   = "${var.project}-${var.environment}-secrets-manager-access-role"
  iam_policy_name = "${var.project}-${var.environment}-secrets-manager-access"

  eks_oidc_provider_arn         = data.terraform_remote_state.compute.outputs.eks_oidc_provider_arn
  eks_oidc_provider_url         = data.terraform_remote_state.compute.outputs.eks_oidc_provider_url
  eks_service_account_namespace = "bebee"
  eks_service_account_name      = "*-secrets-sa"

  use_service_account_wildcard = true
  use_wildcard_secrets         = true
  wildcard_secret_prefix       = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project}-${var.environment}-*"

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "irsa"
  }
}