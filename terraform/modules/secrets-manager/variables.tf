variable "create_secret" {
  description = "Secret 리소스 생성 여부 (false이면 IRSA만 생성)"
  type        = bool
  default     = true
}

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

# ========================================
# IRSA (IAM Roles for Service Accounts) 관련 변수
# ========================================

variable "create_iam_policy" {
  description = "IAM Policy 생성 여부"
  type        = bool
  default     = false
}

variable "create_iam_role" {
  description = "IAM Role 생성 여부 (EKS에서 Secrets Manager 접근)"
  type        = bool
  default     = false
}

variable "iam_role_name" {
  description = "IAM Role 이름 (비어있으면 자동 생성: {secret_name}-eks-access-role)"
  type        = string
  default     = ""
}

variable "iam_policy_name" {
  description = "IAM Policy 이름 (비어있으면 자동 생성: {secret_name}-access-policy)"
  type        = string
  default     = ""
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
  description = "EKS Service Account Name (와일드카드 지원: *-secrets-sa)"
  type        = string
  default     = "secrets-manager-access-sa"
}

variable "use_service_account_wildcard" {
  description = "ServiceAccount 이름에 와일드카드 사용 여부 (StringLike 조건 사용)"
  type        = bool
  default     = false
}

variable "additional_secret_arns" {
  description = "추가로 접근할 Secret ARN 목록 (통합 IAM Role용)"
  type        = list(string)
  default     = []
}

variable "use_wildcard_secrets" {
  description = "와일드카드를 사용하여 모든 secrets에 접근 (true이면 additional_secret_arns 무시)"
  type        = bool
  default     = false
}

variable "wildcard_secret_prefix" {
  description = "와일드카드 사용 시 Secret ARN 접두사 (예: arn:aws:secretsmanager:region:account:secret:prefix-*)"
  type        = string
  default     = ""
}