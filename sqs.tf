resource "aws_sqs_queue" "image" {
  name                       = "${var.project_name}-image-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  tags = {
    Name = "${var.project_name}-image-queue"
  }
}

resource "aws_sqs_queue_policy" "image" {
  queue_url = aws_sqs_queue.image.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.image.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.image.arn
          }
        }
      }
    ]
  })
}
