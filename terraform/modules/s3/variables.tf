variable "bucket_name" {
  description = "S3 버킷 이름 (globally unique해야 함)"
  type        = string
}

variable "versioning_enabled" {
  description = "버킷 버저닝 활성화 여부"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Public Access Block 활성화 여부 (true = private, false = public 허용)"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "CORS에서 허용할 Origin 목록"
  type        = list(string)
  default     = ["*"]
}

variable "lifecycle_enabled" {
  description = "라이프사이클 정책 활성화 여부"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "이전 버전 삭제까지의 일수"
  type        = number
  default     = 90
}

variable "enable_bucket_policy" {
  description = "버킷 정책 활성화 여부 (Public Read 허용)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}