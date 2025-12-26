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

variable "create_iam_role" {
  description = "IAM Role 생성 여부 (EKS에서 S3 접근)"
  type        = bool
  default     = true
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN (EKS IAM Role 생성 시 필요)"
  type        = string
  default     = ""
}

variable "eks_oidc_provider_url" {
  description = "EKS OIDC Provider URL (EKS IAM Role 생성 시 필요)"
  type        = string
  default     = ""
}

variable "eks_service_account_namespace" {
  description = "EKS Service Account Namespace"
  type        = string
  default     = "default"
}

variable "eks_service_account_name" {
  description = "EKS Service Account Name"
  type        = string
  default     = "s3-access-sa"
}

variable "create_local_test_user" {
  description = "로컬 테스트용 IAM User 생성 여부"
  type        = bool
  default     = false
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}