variable "aws_region" {
  description = "AWS 리전"
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

variable "cloudfront_price_class" {
  description = "CloudFront 가격 클래스"
  type        = string
  default     = "PriceClass_200" # Use Only North America, Europe, Asia, Middle East, and Africa
  # PriceClass_All - 모든 엣지 로케이션
  # PriceClass_200 - 북미, 유럽, 아시아, 중동, 아프리카
  # PriceClass_100 - 북미, 유럽
}