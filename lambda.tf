# 1. 이미지 가공 람다 패키징 (파일 경로 주의!)
data "archive_file" "image_lambda" {
  type = "zip"
  # 💡 중요: 수정한 파이썬 파일이 실제로 'lambda_packages' 폴더 안에 있는지 확인하세요!
  source_file = "${path.module}/lambda_packages/lambda_function.py"
  output_path = "${path.module}/lambda_packages/image_lambda.zip"
}

# 2. 가입 알림 람다 패키징
data "archive_file" "auth_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda_packages/auth_notifier.py"
  output_path = "${path.module}/lambda_packages/auth_lambda.zip"
}

# [리소스 A] 이미지 가공 람다 함수
resource "aws_lambda_function" "image_worker" {
  filename      = data.archive_file.image_lambda.output_path
  function_name = "${var.project_name}-image-worker-iac"
  role          = aws_iam_role.image_worker_role.arn
  handler       = "lambda_function.lambda_handler"
  # 💡 핵심: 이 해시값이 있어야 테라폼이 파이썬 코드 수정을 감지하고 배포합니다.
  source_code_hash = data.archive_file.image_lambda.output_base64sha256
  runtime          = "python3.12"
  timeout          = 30
  memory_size      = 512

  layers = [var.lambda_layer_arn]

  environment {
    variables = {
      # 💡 코드 수정 없이 테라폼에서 버킷명을 주입합니다.
      DEST_BUCKET = aws_s3_bucket.processed.id
    }
  }

  tags = { Name = "${var.project_name}-image-worker" }
}

# SQS 트리거 설정
resource "aws_lambda_event_source_mapping" "image_sqs" {
  event_source_arn = aws_sqs_queue.image.arn
  function_name    = aws_lambda_function.image_worker.arn
  batch_size       = 1
}

# [리소스 B] 가입 알림 람다 함수 (사용자님의 소중한 가입 알림 로직 보존!)
resource "aws_lambda_function" "auth_notifier" {
  filename         = data.archive_file.auth_lambda.output_path
  function_name    = "${var.project_name}-auth-notifier"
  role             = aws_iam_role.auth_notifier_role.arn
  handler          = "auth_notifier.lambda_handler"
  source_code_hash = data.archive_file.auth_lambda.output_base64sha256
  runtime          = "python3.12"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.auth.arn
    }
  }

  tags = { Name = "${var.project_name}-auth-notifier" }
}