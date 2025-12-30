# ========================================
# DB 초기화 자동화
# ========================================
# RDS가 생성된 후 Bastion을 통해 초기 스키마 및 사용자 설정

# RDS endpoint에서 호스트 추출
locals {
  rds_host = split(":", module.rds.endpoint)[0]
  rds_port = module.rds.port
}

# 초기화 스크립트를 Bastion을 통해 실행
resource "null_resource" "db_init" {
  # RDS와 Bastion이 모두 생성된 후 실행
  depends_on = [
    module.rds,
    module.bastion
  ]

  # RDS endpoint나 비밀번호가 변경되면 재실행
  triggers = {
    rds_endpoint      = module.rds.endpoint
    db_root_password  = var.db_root_password
    db_bebee_password = var.db_bebee_password
    script_hash       = filemd5("${path.module}/scripts/init_db.sql")
  }

  # Bastion에 SQL 스크립트 업로드
  provisioner "file" {
    source      = "${path.module}/scripts/init_db.sql"
    destination = "/tmp/init_db.sql"

    connection {
      type        = "ssh"
      host        = module.bastion.bastion_public_ip
      user        = "ec2-user"
      private_key = file(module.bastion.private_key_path)
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
      host        = module.bastion.bastion_public_ip
      user        = "ec2-user"
      private_key = file(module.bastion.private_key_path)
      timeout     = "10m"
    }
  }
}

# 초기화 완료 출력
output "db_initialization_status" {
  description = "DB 초기화 상태"
  value = {
    status          = "Completed"
    bastion_host    = module.bastion.bastion_public_ip
    rds_endpoint    = module.rds.endpoint
    databases       = ["bebee_member", "bebee_match", "bebee_chat", "bebee_notification", "bebee_payment"]
    bebee_user      = "bebee@%"
    initialization  = "Auto-initialized via Terraform"
  }
  depends_on = [null_resource.db_init]
}