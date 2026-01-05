# SNS Topic
resource "aws_sns_topic" "this" {
  name         = "${var.name_prefix}-topic"
  display_name = var.display_name != "" ? var.display_name : "${var.name_prefix}-topic"

  kms_master_key_id = var.kms_master_key_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-topic"
    }
  )
}

# Email Subscriptions
resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_subscriptions)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_subscriptions[count.index]
}
