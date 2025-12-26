variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "bastion_subnet_id" {
  description = "Bastion Host가 배치될 Public Subnet ID"
  type        = string
}

variable "bastion_ssh_allowed_cidr" {
  description = "Bastion SSH 접속을 허용할 IP 대역"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_instance_type" {
  description = "Bastion EC2 인스턴스 타입"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}