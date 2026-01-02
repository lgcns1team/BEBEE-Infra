# ========================================
# DB 초기화 자동화
# ========================================
# RDS 및 MongoDB가 생성된 후 Bastion을 통해 초기 스키마 및 사용자 설정

# 호스트 및 포트 정보 추출
locals {
  rds_host = split(":", module.rds.endpoint)[0]
  rds_port = module.rds.port
  
  mongodb_host = module.mongodb.private_ip
  mongodb_port = 27017

  # Network state에서 Bastion 정보 가져오기
  bastion_public_ip      = data.terraform_remote_state.network.outputs.bastion_public_ip

  key_filename = basename(data.terraform_remote_state.network.outputs.bastion_private_key_path)
  bastion_private_key_path = "${path.module}/../01-network/${local.key_filename}"
}

# -------------------------------------------------------------------------
# RDS (MySQL) 초기화
# -------------------------------------------------------------------------
resource "null_resource" "db_init" {
  # RDS가 생성된 후 실행
  depends_on = [
    module.rds
  ]

  # RDS endpoint나 비밀번호가 변경되면 재실행
  triggers = {
    rds_endpoint      = module.rds.endpoint
    db_root_password  = var.db_root_password
    script_hash       = filemd5("${path.module}/scripts/init_db.sql")
  }

  # Bastion에 SQL 스크립트 업로드
  provisioner "file" {
    source      = "${path.module}/scripts/init_db.sql"
    destination = "/tmp/init_db.sql"

    connection {
      type        = "ssh"
      host        = local.bastion_public_ip
      user        = "ec2-user"
      private_key = file(local.bastion_private_key_path)
      timeout     = "5m"
    }
  }

  # Bastion에서 RDS로 SQL 스크립트 실행
  provisioner "remote-exec" {
    on_failure = fail

    inline = [
      "echo '===================================='",
      "echo 'Installing MySQL client...'",
      "echo '===================================='",
      "sudo yum install -y mariadb105",
      "echo '===================================='",
      "echo 'Waiting for RDS to be ready...'",
      "echo '===================================='",
      "sleep 60",
      "echo '===================================='",
      "echo 'Testing RDS connection...'",
      "echo '===================================='",
      "mysql -h ${local.rds_host} -P ${local.rds_port} -u root -p'${var.db_root_password}' -e 'SELECT VERSION();'",
      "echo '===================================='",
      "echo 'Executing initialization script...'",
      "echo '===================================='",
      "mysql -h ${local.rds_host} -P ${local.rds_port} -u root -p'${var.db_root_password}' < /tmp/init_db.sql",
      "echo '===================================='",
      "echo 'Verifying database creation...'",
      "echo '===================================='",
      "mysql -h ${local.rds_host} -P ${local.rds_port} -u root -p'${var.db_root_password}' -e \"SHOW DATABASES LIKE 'bebee_%';\"",
      "echo '===================================='",
      "echo 'Verifying bebee user...'",
      "echo '===================================='",
      "mysql -h ${local.rds_host} -P ${local.rds_port} -u root -p'${var.db_root_password}' -e \"SELECT User, Host FROM mysql.user WHERE User IN ('root', 'bebee');\"",
      "echo '===================================='",
      "echo 'Database initialization completed!'",
      "echo '===================================='",
      "rm -f /tmp/init_db.sql"
    ]

    connection {
      type        = "ssh"
      host        = local.bastion_public_ip
      user        = "ec2-user"
      private_key = file(local.bastion_private_key_path)
      timeout     = "10m"
    }
  }
}

# -------------------------------------------------------------------------
# MongoDB 초기화
# -------------------------------------------------------------------------
resource "null_resource" "mongodb_init" {
  depends_on = [module.mongodb]

  # MongoDB 초기화 스크립트를 Bastion으로 복사
  provisioner "file" {
    source      = "${path.module}/scripts/init_mongodb.js"
    destination = "/tmp/init_mongodb.js"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = local.bastion_public_ip
      private_key = file(local.bastion_private_key_path)
    }
  }

  # Bastion에서 MongoDB CLI 설치 및 초기화 스크립트 실행
  provisioner "remote-exec" {
    inline = [
      # MongoDB Shell 설치 (Amazon Linux 호환)
      "echo 'Installing MongoDB Shell...'",
      "sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo > /dev/null <<EOF",
      "[mongodb-org-8.0]",
      "name=MongoDB Repository",
      "baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/8.0/x86_64/",
      "gpgcheck=1",
      "enabled=1",
      "gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc",
      "EOF",
      "sudo yum clean all",
      "sudo yum install -y mongodb-mongosh",

      # MongoDB 인스턴스가 준비될 때까지 대기
      "echo 'Waiting for MongoDB to be ready...'",
      "for i in {1..30}; do timeout 1 bash -c 'cat < /dev/null > /dev/tcp/${local.mongodb_host}/${local.mongodb_port}' 2>/dev/null && break || sleep 10; done",

      # 초기화 스크립트 실행
      "echo 'Running MongoDB initialization script...'",
      "mongosh mongodb://${var.mongodb_admin_username}:${var.mongodb_admin_password}@${local.mongodb_host}:${local.mongodb_port}/admin < /tmp/init_mongodb.js",

      # 정리
      "rm -f /tmp/init_mongodb.js",
      "echo 'MongoDB initialization completed!'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = local.bastion_public_ip
      private_key = file(local.bastion_private_key_path)
    }
  }
}

# 초기화 완료 출력
output "db_initialization_status" {
  description = "DB 초기화 상태"
  value = {
    status          = "Completed"
    bastion_host    = local.bastion_public_ip
    rds_endpoint    = module.rds.endpoint
    mongodb_host    = module.mongodb.private_ip
    databases       = ["bebee_member", "bebee_match", "bebee_chat", "bebee_notification", "bebee_payment", "MongoDB"]
    bebee_user      = "bebee@%"
    initialization  = "Auto-initialized via Terraform"
  }
  depends_on = [
    null_resource.db_init,
    null_resource.mongodb_init
  ]
}
