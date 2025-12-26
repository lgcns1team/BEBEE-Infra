output "endpoint" {
  description = "RDS 접속 엔드포인트"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "RDS 접속 포트"
  value       = aws_db_instance.main.port
}

output "db_instance_id" {
  description = "RDS 인스턴스 ID"
  value       = aws_db_instance.main.id
}
