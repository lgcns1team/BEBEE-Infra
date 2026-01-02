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

variable "mongodb_instance_type" {
  description = "MongoDB EC2 인스턴스 타입"
  type        = string
  default     = "t3a.medium"
}

variable "mongodb_volume_size" {
  description = "MongoDB EBS 볼륨 크기 (GB)"
  type        = number
  default     = 20
}

variable "mongodb_admin_username" {
  description = "MongoDB 관리자 사용자명"
  type        = string
  default     = ""
  sensitive   = true
}

variable "mongodb_admin_password" {
  description = "MongoDB 관리자 비밀번호"
  type        = string
  default     = ""
  sensitive   = true
}