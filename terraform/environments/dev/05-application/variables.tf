variable "aws_region" {
  description = "AWS 리전 설정"
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "프로젝트 이름"
  type        = string
  default     = "bebee"
}

variable "environment" {
  description = "환경 (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "db_bebee_password" {
  description = "bebee 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT 토큰 생성용 Secret Key"
  type        = string
  sensitive   = true
}

variable "jwt_issuer" {
  description = "JWT 토큰 발행자"
  type        = string
  default     = "bebee"
}

variable "access_token_expires_in" {
  description = "Access Token 만료 시간 (초)"
  type        = number
  default     = 86400
}

variable "refresh_token_expires_in" {
  description = "Refresh Token 만료 시간 (초)"
  type        = number
  default     = 602800
}

variable "db_schemas" {
  description = "서비스 별 DB 스키마 정보"
  type = map(object({
    db_name  = string
    username = string
  }))

  default = {
    member       = { db_name = "bebee_member", username = "bebee" }
    match        = { db_name = "bebee_match", username = "bebee" }
    chat         = { db_name = "bebee_chat", username = "bebee" }
    notification = { db_name = "bebee_notification", username = "bebee" }
    payment      = { db_name = "bebee_payment", username = "bebee" }
  }
}

variable "mongodb_username" {
  description = "MongoDB 사용자명"
  type        = string
  sensitive   = true
}

variable "mongodb_password" {
  description = "MongoDB 비밀번호"
  type        = string
  sensitive   = true
}

# ========================================
# 외부 API 인증 정보
# ========================================

variable "kakao_api_key" {
  description = "카카오 API KEY"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME"
}

variable "toss_client_key" {
  description = "토스 클라이언트 키"
  type = string
  sensitive = true
  default = "CHANGE_ME"
}

variable "toss_secret_key" {
  description = "토스 시크릿 키"
  type = string
  sensitive = true
  default = "CHANGE_ME"
}
