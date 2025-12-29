output "endpoint" {
  description = "RDS 접속 엔드포인트"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "RDS 호스트 주소 (포트 제외)"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "RDS 접속 포트"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "데이터베이스 이름"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "마스터 사용자 이름"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "engine" {
  description = "데이터베이스 엔진"
  value       = aws_db_instance.main.engine
}

output "db_instance_id" {
  description = "RDS 인스턴스 ID"
  value       = aws_db_instance.main.id
}
