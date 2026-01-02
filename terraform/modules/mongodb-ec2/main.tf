# ========================================
# MongoDB EC2 Instance Module
# ========================================

# 1. Security Group (MongoDB 접근 제어)
resource "aws_security_group" "mongodb_sg" {
  name        = "${var.name_prefix}-mongodb-sg"
  description = "Security group for MongoDB EC2 instance"
  vpc_id      = var.vpc_id

  # MongoDB 기본 포트 (27017) - VPC 내부에서만 접근 허용
  ingress {
    description = "MongoDB from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound: 모든 트래픽 허용 (패키지 다운로드, 업데이트 등)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-mongodb-sg"
    }
  )
}

# 2. AMI Data Source (Ubuntu 22.04 LTS - MongoDB 공식 지원)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 4. User Data Script - MongoDB 설치 및 설정
locals {
  user_data = <<-EOF
#!/bin/bash
set -e

# 시스템 업데이트
apt-get update
apt-get upgrade -y

# MongoDB 공식 저장소 추가
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | \
   tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# MongoDB 설치
apt-get update
apt-get install -y mongodb-org

# MongoDB 설정 파일 수정 (외부 접근 허용)
cat > /etc/mongod.conf <<'MONGOCONF'
# MongoDB 8.0 Configuration File

storage:
  dbPath: /var/lib/mongodb

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 0.0.0.0  # 모든 인터페이스에서 접속 허용

processManagement:
  timeZoneInfo: /usr/share/zoneinfo

# 보안 설정 (초기에는 비활성화, 설정 후 활성화 권장)
# security:
#   authorization: enabled

# Replication (필요시 활성화)
# replication:
#   replSetName: "rs0"
MONGOCONF

# MongoDB 서비스 시작 및 자동 시작 설정
systemctl daemon-reload
systemctl enable mongod
systemctl start mongod

# 상태 확인
systemctl status mongod

# MongoDB 초기 사용자 생성 (옵션)
%{if var.mongodb_admin_username != "" && var.mongodb_admin_password != ""}

echo "Waiting for MongoDB to be read..."
for i in {1..30}; do
  mongosh --eval "db.adminCommand('ping')" > /dev/null 2&1 && break
  sleep 2
done

# MongoDB 사용자 생성 스크립트
mongosh admin --eval "
  db.createUser({
    user: '${var.mongodb_admin_username}',
    pwd: '${var.mongodb_admin_password}',
    roles: [{role: 'root', db: 'admin'}]
  });
"

# 인증 활성화
cat >> /etc/mongod.conf <<'SECURITY'

security:
  authorization: enabled
SECURITY

systemctl restart mongod
%{endif}

# 완료 메시지
echo "MongoDB installation completed successfully"
EOF
}

# 5. EC2 Instance (MongoDB Server)
resource "aws_instance" "mongodb" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]

  # Private Subnet이므로 Public IP 할당하지 않음
  associate_public_ip_address = false

  # EBS Volume 설정 (MongoDB 데이터 저장)
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = var.delete_volume_on_termination
    encrypted             = true

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-mongodb-root-volume"
      }
    )
  }

  # User Data (MongoDB 설치 스크립트)
  user_data = local.user_data

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-mongodb"
      Role = "MongoDB Database Server"
    }
  )
}