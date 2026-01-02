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