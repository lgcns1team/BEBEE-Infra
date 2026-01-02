variable "name_prefix" {
  description = "리소스 이름 prefix (예: bebee-dev)"
  type        = string
}

variable "alb_name" {
  description = "ALB 이름 (Ingress에서 참조할 이름)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "ALB가 위치할 Public Subnet ID 목록"
  type        = list(string)
}

variable "cluster_name_hardcode" {
  description = "EKS 클러스터 이름 (hard-code, 고정값)"
  type        = string
}

variable "enable_deletion_protection" {
  description = "ALB 삭제 보호 활성화 여부"
  type        = bool
  default     = false
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}