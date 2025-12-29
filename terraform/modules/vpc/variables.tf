variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "availability_zones" {
  description = "가용 영역 리스트"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public 서브넷 CIDR 리스트"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private 서브넷 CIDR 리스트"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "NAT Gateway 활성화 여부"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS 클러스터 이름 (서브넷 태그용, 선택사항)"
  type        = string
  default     = null
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}