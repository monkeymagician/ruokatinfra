# 1. 이미지 가공용 람다 역할
resource "aws_iam_role" "image_worker_role" {
  name = "ruokat-image-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 2. 가입 알림용 람다 역할
resource "aws_iam_role" "auth_notifier_role" {
  name = "ruokat-auth-notifier-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 3. 이미지 가공용 권한 정책 (ListBucket 포함)
resource "aws_iam_role_policy" "image_worker_policy" {
  name = "ruokat-image-worker-policy"
  role = aws_iam_role.image_worker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:ListBucket", "s3:GetBucketLocation", "s3:GetObject", "s3:PutObject"]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::ruokat-original-651109015678",
          "arn:aws:s3:::ruokat-original-651109015678/*",
          "arn:aws:s3:::ruokat-processed-651109015678",
          "arn:aws:s3:::ruokat-processed-651109015678/*"
        ]
      },
      {
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Effect   = "Allow"
        Resource = ["*"] # 실제 환경에선 SQS ARN으로 제한 권장
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
# 4. 가입 알림용 람다 권한 정책 (SNS 게시 + 로그 기록)
resource "aws_iam_role_policy" "auth_notifier_policy" {
  name = "ruokat-auth-notifier-policy"
  role = aws_iam_role.auth_notifier_role.id # 💡 알림용 역할에 연결

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # 💡 핵심: SNS 토픽에 메시지를 보낼 수 있는 권한
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.auth.arn
      },
      {
        # 💡 필수: 람다 실행 로그를 남길 수 있는 권한
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}