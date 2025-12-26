# ========================================
# ElastiCache Redis Outputs (Master-Replica 모드)
# ========================================

output "replication_group_id" {
  description = "ElastiCache Replication Group ID"
  value       = aws_elasticache_replication_group.main.id
}

output "primary_endpoint_address" {
  description = <<-EOT
    Primary 엔드포인트 주소 (Master 노드)
    - 읽기/쓰기 모두 가능
    - 애플리케이션에서 쓰기 작업에 사용
  EOT
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = <<-EOT
    Reader 엔드포인트 주소 (Replica 노드들)
    - 읽기 전용
    - 자동으로 Replica 간 로드 밸런싱
    - 읽기 부하 분산에 사용
  EOT
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}
#
# output "configuration_endpoint_address" {
#   description = "Configuration 엔드포인트 (클러스터 모드에서 사용, Master-Replica 모드에서는 null)"
#   value       = aws_elasticache_replication_group.main.configuration_endpoint_address
# }

output "port" {
  description = "Redis 포트"
  value       = 6379
}

output "security_group_id" {
  description = "Redis Security Group ID"
  value       = aws_security_group.redis_sg.id
}

output "member_clusters" {
  description = <<-EOT
    모든 노드(클러스터) 목록
    - 첫 번째: Master
    - 나머지: Replicas
  EOT
  value       = aws_elasticache_replication_group.main.member_clusters
}