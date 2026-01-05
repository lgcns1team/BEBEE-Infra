variable "name_prefix" {
  description = "리소스 이름 접두사 (예: project-env-queue-name)"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "메시지 가시성 타임아웃 (초)"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "메시지 보존 기간 (초)"
  type        = number
  default     = 345600 # 4일
}

variable "max_message_size" {
  description = "최대 메시지 크기 (바이트)"
  type        = number
  default     = 262144 # 256KB
}

variable "delay_seconds" {
  description = "메시지 전송 지연 시간 (초)"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long Polling 대기 시간 (초)"
  type        = number
  default     = 20 # 0~20
}

variable "create_dlq" {
  description = "Dead Letter Queue 생성 여부"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "DLQ로 이동하기 전 최대 수신 횟수"
  type        = number
  default     = 3
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
