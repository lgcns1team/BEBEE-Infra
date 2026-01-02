# ========================================
# Variables
# ========================================

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
}