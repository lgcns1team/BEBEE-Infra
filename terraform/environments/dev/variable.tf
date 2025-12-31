variable "aws_region" {
  description = "AWS 리전 설정"
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "프로젝트 이름"
  type        = string
  default     = "bebee"
}

variable "environment" {
  description = "환경 (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "가용 영역 리스트"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  description = "Public 서브넷 CIDR 리스트 (2개)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Private 서브넷 (4개, 각 AZ에 2개씩 - 백엔드/DB 분리)
variable private_subnet_cidrs {
  description = "Private 서브넷 CIDR 리스트 (2개)"
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]
}

variable "db_root_password" {
  description = "RDS root 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_bebee_password" {
  description = "bebee 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT 토큰 생성용 Secret Key (최소 32바이트 권장)"
  type        = string
  sensitive   = true
}

variable "jwt_issuer" {
  description = "JWT 토큰 발행자"
  type        = string
  default     = "bebee"
}

variable "access_token_expires_in" {
  description = "Access Token 만료 시간 (초 단위)"
  type        = number
  default     = 900  # 15분
}

variable "refresh_token_expires_in" {
  description = "Refresh Token 만료 시간 (초 단위)"
  type        = number
  default     = 86400 # 1일
}


variable "db_schemas" {
  description = "서비스 별 DB 스키마 정보"
  type = map(object({
    db_name = string
    username = string
  }))

  default = {
    member = { db_name = "bebee_member", username = "bebee"},
    match = { db_name = "bebee_match", username = "bebee"},
    chat = { db_name = "bebee_chat", username = "bebee"},
    notification = { db_name = "bebee_notification", username = "bebee"},
    payment = { db_name = "bebee_payment", username = "bebee"},
  }
}



# Bastion Host 설정

variable "bastion_instance_type" {
  description = "Bastion Host 인스턴스 타입"
  type        = string
  default     = "t2.micro"
}



variable "bastion_ssh_allowed_cidrs" {
  description = "Bastion Host SSH 접속 허용 IP 대역"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# S3 설정
variable "s3_cors_allowed_origins" {
  description = "S3 CORS에서 허용할 Origin 목록"
  type        = list(string)
  default     = ["*"]
}

# EKS 설정
variable "eks_cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = "1.34"
}

variable "eks_public_access_cidrs" {
  description = "EKS API 서버 Public Endpoint 접근 허용 IP 대역"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ECR 설정
variable "ecr_repositories" {
  description = "ECR 리포지토리 목록 (서비스별)"
  type        = set(string)
  default     = ["chat", "file", "match", "member", "notification", "payment", "swagger"]
}
