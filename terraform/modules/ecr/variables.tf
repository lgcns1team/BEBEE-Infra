variable "repository_name" {
  description = "ECR 리포지토리 이름"
  type        = string
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능 여부 (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "푸시 시 이미지 스캔 활성화"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "암호화 유형 (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS 키 ARN (encryption_type이 KMS일 때 필요)"
  type        = string
  default     = null
}

variable "enable_lifecycle_policy" {
  description = "라이프사이클 정책 활성화"
  type        = bool
  default     = true
}

variable "lifecycle_keep_count" {
  description = "유지할 이미지 개수"
  type        = number
  default     = 10
}

variable "repository_policy" {
  description = "ECR 리포지토리 정책 (JSON)"
  type        = string
  default     = null
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}