# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-redis-subnet-group"
    }
  )
}

# ElastiCache Security Group
resource "aws_security_group" "redis_sg" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Allow Redis access from within VPC"
  vpc_id      = var.vpc_id

  # Inbound: VPC 내부에서 오는 Redis 포트 접속 허용
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Inbound: 특정 보안 그룹에서의 접속 허용
  dynamic "ingress" {
    for_each = var.allowed_security_groups
    content {
      from_port       = 6379
      to_port         = 6379
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  # Outbound: 모든 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-redis-sg"
    }
  )
}

# ========================================
# ElastiCache Redis - Master-Replica 모드
# ========================================
# 클러스터 모드 비활성화 (단일 샤드 구성)
# Master 1개 + Replica N개 구성으로 고가용성 제공
#
# 주요 특징:
# - 데이터 샤딩 없음 (단일 Primary)
# - Read Replica를 통한 읽기 부하 분산
# - 자동 Failover 지원 (Replica가 2개 이상일 때)
#
# 참고: 클러스터 모드를 사용하려면 num_node_groups를 사용해야 함

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.name_prefix}-redis"
  description          = "Redis Master-Replica for ${var.name_prefix}"

  # Engine
  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = 6379

  # ========================================
  # Master-Replica 구성 (비클러스터 모드)
  # ========================================
  # num_cache_clusters: 전체 노드 수 (Master 1 + Replicas)
  # 예: num_cache_clusters = 2 → Master 1개 + Replica 1개
  num_cache_clusters = var.num_cache_nodes

  # 자동 Failover: Replica가 있을 때만 활성화
  # Multi-AZ 배포를 위해서는 최소 2개 이상의 노드 필요
  automatic_failover_enabled = var.num_cache_nodes > 1 ? true : false

  # 클러스터 모드 비활성화 (명시적 설정 - 기본값)
  # cluster_mode는 설정하지 않음 = 비클러스터 모드

  # Network
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis_sg.id]

  # Parameter Group
  parameter_group_name = var.parameter_group_name

  # Backup & Maintenance
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window

  # Auto Minor Version Upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-redis-master-replica"
      Mode = "non-cluster"
    }
  )
}