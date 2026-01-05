output "sns_topic_arns" {
  description = "각 서비스별 SNS Topic ARN Map"
  value       = { for k, v in module.sns_topics : k => v.topic_arn }
}

output "sqs_queue_urls" {
  description = "각 서비스별 SQS Queue URL Map"
  value       = { for k, v in module.sqs_queues : k => v.queue_id }
}

output "sqs_queue_arns" {
  description = "각 서비스별 SQS Queue ARN Map"
  value       = { for k, v in module.sqs_queues : k => v.queue_arn }
}

output "messaging_iam_role_arn" {
  description = "SNS/SQS 접근을 위한 IAM Role ARN (IRSA용)"
  value       = aws_iam_role.messaging_eks_access.arn
}
