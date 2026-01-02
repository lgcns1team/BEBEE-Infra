# ========================================
# Application Load Balancer (ALB)
# ========================================
# Network 레이어에서 ALB를 영구적으로 생성
# Compute(EKS)를 올렸다/내렸다 해도 ALB는 유지되어 Route53 변경 불필요

# ALB용 Security Group
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP 인바운드
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS 인바운드 (필요시)
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 모든 아웃바운드 허용
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb-sg"
    }
  )
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.alb_name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  # AWS Load Balancer Controller가 이 ALB를 관리하도록 태그 설정
  # cluster_name은 hard-code (EKS를 올렸다/내렸다 해도 동일한 이름 사용)
  tags = merge(
    var.tags,
    {
      Name                                                 = var.alb_name
      "kubernetes.io/cluster/${var.cluster_name_hardcode}" = "owned"
      "elbv2.k8s.aws/cluster"                              = var.cluster_name_hardcode
      "ingress.k8s.aws/stack"                              = "${var.name_prefix}-ingress"
      "ingress.k8s.aws/resource"	                       = "LoadBalancer"
    }
  )
}