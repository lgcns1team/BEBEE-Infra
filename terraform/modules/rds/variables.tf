variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID (Security Group 생성용)"
  type        = string
}

variable "subnet_ids" {
  description = "RDS가 배치될 서브넷 ID 리스트"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR (내부 접속 허용용)"
  type        = string
}

variable "allowed_security_groups" {
  description = "접속을 허용할 외부 보안 그룹 ID 리스트 (예: Bastion SG)"
  type        = list(string)
  default     = []
}

# DB 설정 변수
variable "engine" {
  description = "DB 엔진 (예: mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "DB 엔진 버전"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "DB 인스턴스 타입"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "스토리지 용량 (GB)"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "스토리지 타입 (gp2, gp3, io1 등)"
  type        = string
  default     = "gp2"
}

variable "multi_az" {
  description = "Multi-AZ 배포 여부"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "초기 생성할 DB 이름"
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "마스터 사용자 이름"
  type        = string
  default     = "root"
}

variable "password" {
  description = "마스터 사용자 비밀번호"
  type        = string
  sensitive   = true # 민감한 정보로 표시 (로그 출력 방지)
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
