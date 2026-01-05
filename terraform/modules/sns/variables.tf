variable "name_prefix" {
  description = "리소스 이름 접두사 (예: project-env-feature)"
  type        = string
}

variable "display_name" {
  description = "SMS 등에서 표시될 이름 (Optional)"
  type        = string
  default     = ""
}

variable "kms_master_key_id" {
  description = "암호화에 사용할 KMS Key ID (기본값: alias/aws/sns)"
  type        = string
  default     = "alias/aws/sns"
}

variable "email_subscriptions" {
  description = "구독할 이메일 리스트 (옵션)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
