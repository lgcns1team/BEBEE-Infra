# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

# RDS Security Group
resource "aws_security_group" "rds-sg" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow DB access from within VPC"
  vpc_id      = var.vpc_id

  # Inbound: VPC 내부에서 오는 DB 포트 접속 허용
  ingress {
    from_port   = 3306 # 엔진에 따라 포트 자동 선택 (단순화)
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Inbound: 특정 보안 그룹(Bastion 등)에서의 접속 허용
  dynamic "ingress" {
    for_each = var.allowed_security_groups
    content {
      from_port       = 3306 # 엔진에 따라 변경 필요시 변수 사용
      to_port         = 3306
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
      Name = "${var.name_prefix}-rds-sg"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-rds"

  # Engine & Version
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  # Database Config
  db_name  = var.db_name
  username = var.username
  password = var.password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  multi_az               = var.multi_az
  publicly_accessible    = false # Private Subnet이므로 외부 접근 차단

  # Backup & Maintenance
  skip_final_snapshot = true # 실습용이므로 삭제 시 스냅샷 생략 (운영환경에선 false 권장)

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds"
    }
  )
}
