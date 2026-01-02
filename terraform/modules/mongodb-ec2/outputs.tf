output "instance_id" {
  description = "MongoDB EC2 인스턴스 ID"
  value       = aws_instance.mongodb.id
}

output "private_ip" {
  description = "MongoDB EC2 인스턴스 Private IP"
  value       = aws_instance.mongodb.private_ip
}

output "security_group_id" {
  description = "MongoDB 보안 그룹 ID"
  value       = aws_security_group.mongodb_sg.id
}

output "mongodb_connection_string" {
  description = "MongoDB 연결 문자열 (인증 비활성화 시)"
  value       = "mongodb://${aws_instance.mongodb.private_ip}:27017"
}

output "mongodb_connection_string_authenticated" {
  description = "MongoDB 연결 문자열 (인증 활성화 시)"
  value       = var.mongodb_admin_username != "" ? "mongodb://${var.mongodb_admin_username}:${var.mongodb_admin_password}@${aws_instance.mongodb.private_ip}:27017/?authSource=admin" : ""
  sensitive   = true
}