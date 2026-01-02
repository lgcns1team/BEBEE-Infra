output "rds_endpoint" {
  description = "RDS 접속 엔드포인트"
  value       = module.rds.endpoint
}

output "rds_address" {
  description = "RDS 주소"
  value       = module.rds.address
}

output "rds_port" {
  description = "RDS 포트"
  value       = module.rds.port
}

output "rds_engine" {
  description = "RDS 엔진"
  value       = module.rds.engine
}

output "redis_primary_endpoint" {
  description = "Redis Primary 엔드포인트"
  value       = module.elasticache.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis Reader 엔드포인트"
  value       = module.elasticache.reader_endpoint_address
}

output "redis_port" {
  description = "Redis 포트"
  value       = module.elasticache.port
}

output "mongodb_instance_id" {
  description = "MongoDB EC2 인스턴스 ID"
  value       = module.mongodb.instance_id
}

output "mongodb_private_ip" {
  description = "MongoDB Private IP"
  value       = module.mongodb.private_ip
}

output "mongodb_connection_string" {
  description = "MongoDB 연결 문자열"
  value       = module.mongodb.mongodb_connection_string
}

output "mongodb_security_group_id" {
  description = "MongoDB 보안 그룹 ID"
  value       = module.mongodb.security_group_id
}