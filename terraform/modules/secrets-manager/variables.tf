variable "secret_name" {
  description = "시크릿 이름 (고유해야 함)"
  type        = string
}

variable "description" {
  description = "시크릿 설명"
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "암호화에 사용할 KMS 키 ID (지정하지 않으면 AWS 관리형 키 사용)"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "시크릿 삭제 후 복구 가능 기간 (7-30일, 0이면 즉시 삭제)"
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "복구 기간은 0 (즉시 삭제) 또는 7-30일 사이여야 합니다."
  }
}

variable "secret_string" {
  description = "시크릿 값 (JSON 문자열 형식, 민감 정보이므로 별도 관리 권장)"
  type        = string
  default     = null
  sensitive   = true
}

variable "replica_regions" {
  description = "시크릿을 복제할 리전 목록"
  type = list(object({
    region     = string
    kms_key_id = optional(string)
  }))
  default = []
}

variable "enable_rotation" {
  description = "자동 회전 활성화 여부"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "시크릿 회전에 사용할 Lambda 함수 ARN (enable_rotation이 true일 때 필수)"
  type        = string
  default     = null
}

variable "rotation_days" {
  description = "자동 회전 주기 (일 단위)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}