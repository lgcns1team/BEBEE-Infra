output "queue_id" {
  description = "SQS 큐 URL (ID)"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "SQS 큐 ARN"
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "SQS 큐 이름"
  value       = aws_sqs_queue.this.name
}

output "dlq_arn" {
  description = "DLQ ARN"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}
