resource "aws_sns_topic" "image" {
  name = "${var.project_name}-image-topic"

  tags = {
    Name = "${var.project_name}-image-topic"
  }
}

resource "aws_sns_topic" "auth" {
  name = "${var.project_name}-auth-topic"

  tags = {
    Name = "${var.project_name}-auth-topic"
  }
}

resource "aws_sns_topic_subscription" "auth_email" {
  topic_arn = aws_sns_topic.auth.arn
  protocol  = "email"
  endpoint  = var.admin_email
}

resource "aws_sns_topic_policy" "image" {
  arn = aws_sns_topic.image.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.image.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.original.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "image_to_sqs" {
  topic_arn = aws_sns_topic.image.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.image.arn
}
