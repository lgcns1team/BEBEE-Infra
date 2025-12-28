output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS 클러스터 ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS 클러스터 API 서버 엔드포인트"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 인증서 데이터 (base64 인코딩)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "EKS 클러스터 버전"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "EKS 클러스터 플랫폼 버전"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_status" {
  description = "EKS 클러스터 상태"
  value       = aws_eks_cluster.main.status
}

output "cluster_iam_role_arn" {
  description = "EKS 클러스터 IAM Role ARN"
  value       = aws_iam_role.cluster.arn
}

# ========================================
# Node Group Outputs
# ========================================

output "node_group_id" {
  description = "EKS 노드 그룹 ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "EKS 노드 그룹 ARN"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "EKS 노드 그룹 상태"
  value       = aws_eks_node_group.main.status
}

output "node_group_iam_role_arn" {
  description = "EKS 노드 그룹 IAM Role ARN"
  value       = aws_iam_role.node_group.arn
}

# ========================================
# OIDC Provider Outputs (IRSA용)
# ========================================

output "oidc_provider_arn" {
  description = "EKS OIDC Provider ARN (IRSA용)"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "EKS OIDC Provider URL (IRSA용)"
  value       = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

# ========================================
# AWS Load Balancer Controller Outputs
# ========================================

output "aws_load_balancer_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value       = length(aws_iam_role.aws_load_balancer_controller) > 0 ? aws_iam_role.aws_load_balancer_controller[0].arn : null
}