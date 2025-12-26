variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID (Security Group 생성용)"
  type        = string
}

variable "subnet_ids" {
  description = "ElastiCache가 배치될 서브넷 ID 리스트"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR (내부 접속 허용용)"
  type        = string
}

variable "allowed_security_groups" {
  description = "접속을 허용할 외부 보안 그룹 ID 리스트 (예: Bastion, Backend SG)"
  type        = list(string)
  default     = []
}

# ========================================
# Redis 설정 변수 (Master-Replica 모드)
# ========================================

variable "engine_version" {
  description = "Redis 엔진 버전"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "캐시 노드 타입 (예: cache.t2.micro, cache.t3.small)"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = <<-EOT
    Master-Replica 모드의 전체 노드 수
    - 1: Master만 (Failover 없음)
    - 2: Master 1 + Replica 1 (자동 Failover 활성화)
    - 3: Master 1 + Replica 2 (고가용성)

    참고: 클러스터 모드가 아닌 Master-Replica 모드입니다.
  EOT
  type        = number
  default     = 2
}

variable "parameter_group_name" {
  description = "파라미터 그룹 이름"
  type        = string
  default     = "default.redis7"
}

# Backup 설정
variable "snapshot_retention_limit" {
  description = "스냅샷 보관 기간 (일), 0이면 스냅샷 비활성화"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "스냅샷 생성 시간대 (UTC)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "유지보수 시간대"
  type        = string
  default     = "mon:05:00-mon:07:00"
}

# Auto Minor Version Upgrade
variable "auto_minor_version_upgrade" {
  description = "자동 마이너 버전 업그레이드 여부"
  type        = bool
  default     = true
}

# Encryption
variable "at_rest_encryption_enabled" {
  description = "저장 데이터 암호화 여부"
  type        = bool
  default     = false
}

variable "transit_encryption_enabled" {
  description = "전송 중 데이터 암호화 여부"
  type        = bool
  default     = false
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}