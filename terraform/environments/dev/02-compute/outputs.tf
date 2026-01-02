output "eks_cluster_id" {
  description = "EKS 클러스터 ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS 클러스터 ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터 API 서버 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS 클러스터 인증서 데이터"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_version" {
  description = "EKS 클러스터 버전"
  value       = module.eks.cluster_version
}

output "eks_cluster_iam_role_arn" {
  description = "EKS 클러스터 IAM Role ARN"
  value       = module.eks.cluster_iam_role_arn
}

output "eks_node_group_id" {
  description = "EKS 노드 그룹 ID"
  value       = module.eks.node_group_id
}

output "eks_node_group_arn" {
  description = "EKS 노드 그룹 ARN"
  value       = module.eks.node_group_arn
}

output "eks_node_group_status" {
  description = "EKS 노드 그룹 상태"
  value       = module.eks.node_group_status
}

output "eks_node_group_iam_role_arn" {
  description = "EKS 노드 그룹 IAM Role ARN"
  value       = module.eks.node_group_iam_role_arn
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN (IRSA용)"
  value       = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  description = "EKS OIDC Provider URL (IRSA용)"
  value       = module.eks.oidc_provider_url
}

output "eks_aws_load_balancer_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value       = module.eks.aws_load_balancer_controller_role_arn
}