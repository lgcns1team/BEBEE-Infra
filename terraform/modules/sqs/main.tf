# 메인 큐
resource "aws_sqs_queue" "this" {
  name                       = "${var.name_prefix}-queue"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds # Long Polling

  # DLQ 설정 (옵션)
  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  # 개발 환경에서는 암호화 비활성화 (KMS 권한 이슈 회피)
  # kms_master_key_id                 = "alias/aws/sqs"
  # kms_data_key_reuse_period_seconds = 300

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-queue"
    }
  )
}

# Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0
  name  = "${var.name_prefix}-queue-dlq"

  message_retention_seconds = 1209600 # 14일 (최대값)
  # 개발 환경에서는 암호화 비활성화
  # kms_master_key_id         = "alias/aws/sqs"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-queue-dlq"
      Type = "DLQ"
    }
  )
}
