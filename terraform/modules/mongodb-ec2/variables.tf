variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block (MongoDB 포트 접근 허용용)"
  type        = string
}

variable "subnet_id" {
  description = "MongoDB EC2 인스턴스가 배치될 Private Subnet ID"
  type        = string
}

variable "instance_type" {
  description = "MongoDB EC2 인스턴스 타입"
  type        = string
  default     = "t3.small"
}

variable "volume_type" {
  description = "EBS 볼륨 타입"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "EBS 볼륨 크기 (GB)"
  type        = number
  default     = 30
}

variable "delete_volume_on_termination" {
  description = "EC2 종료 시 볼륨 삭제 여부"
  type        = bool
  default     = false
}

variable "mongodb_admin_username" {
  description = "MongoDB 관리자 사용자명 (비워두면 인증 비활성화)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "mongodb_admin_password" {
  description = "MongoDB 관리자 비밀번호 (비워두면 인증 비활성화)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
