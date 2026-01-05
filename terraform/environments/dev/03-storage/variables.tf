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

variable "s3_cors_allowed_origins" {
  description = "S3 CORS에서 허용할 Origin 목록"
  type        = list(string)
  default     = ["*"]
}

variable "ecr_repositories" {
  description = "ECR 리포지토리 목록 (서비스별)"
  type        = set(string)
  default     = ["chat", "file", "match", "member", "notification", "payment", "swagger", "gateway"]
}

variable "cloudfront_price_class" {
  description = "CloudFront 요금 클래스 (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_200" # 아시아, 유럽, 북미
}