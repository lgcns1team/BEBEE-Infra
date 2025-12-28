variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "EKS 클러스터가 사용할 서브넷 ID 목록 (Private Subnet 권장)"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "EKS API 서버에 대한 Private Endpoint 접근 활성화"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "EKS API 서버에 대한 Public Endpoint 접근 활성화"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "Public Endpoint에 접근 가능한 CIDR 블록 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}

# ========================================
# Node Group 설정
# ========================================

variable "node_desired_size" {
  description = "노드 그룹 원하는 노드 수"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "노드 그룹 최소 노드 수"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "노드 그룹 최대 노드 수"
  type        = number
  default     = 3
}

variable "node_instance_types" {
  description = "노드 인스턴스 타입 목록"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "노드 디스크 크기 (GB)"
  type        = number
  default     = 20
}

# ========================================
# AWS Load Balancer Controller 설정
# ========================================

variable "enable_aws_load_balancer_controller" {
  description = "AWS Load Balancer Controller 활성화 여부"
  type        = bool
  default     = true
}