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
  description = "환경 이름 (dev, stg, prod)"
  type        = string
  default     = "dev"
}

variable "service_names" {
  description = "SNS Topic 및 SQS Queue를 생성할 서비스 목록"
  type        = set(string)
  default     = [
    "member",
    "match",
    "payment",
    "chat",
    "notification"
  ]
}
