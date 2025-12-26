# 1. SSH Key Pair 생성 (접속용)
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.name_prefix}-bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh

  tags = var.tags
}

# 2. 로컬에 프라이빗 키 저장
resource "local_file" "private_key_file" {
  content         = tls_private_key.bastion_key.private_key_pem
  filename        = "${path.root}/bastion-key.pem"
  file_permission = "0400"
}

# 3. Security Group (SSH 허용)
resource "aws_security_group" "bastion_sg" {
  name        = "${var.name_prefix}-bastion-sg"
  description = "Allow SSH access to Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_ssh_allowed_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-bastion-sg"
    }
  )
}

# 4. AMI Data Source
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 5. EC2 Instance (Bastion Host)
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.bastion_instance_type
  subnet_id     = var.bastion_subnet_id
  key_name      = aws_key_pair.bastion_key.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-bastion"
    }
  )
}