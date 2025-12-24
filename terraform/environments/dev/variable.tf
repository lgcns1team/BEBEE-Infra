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

variable "private_subnet_cidrs" {
  description = "Private 서브넷 CIDR 리스트 (4개, 2개 AZ에 2개씩)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]
}