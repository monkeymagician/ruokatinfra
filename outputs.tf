output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "original_bucket_name" {
  description = "Original S3 bucket name"
  value       = aws_s3_bucket.original.id
}

output "processed_bucket_name" {
  description = "Processed S3 bucket name"
  value       = aws_s3_bucket.processed.id
}

output "image_topic_arn" {
  description = "Image SNS topic ARN"
  value       = aws_sns_topic.image.arn
}

output "auth_topic_arn" {
  description = "Auth SNS topic ARN"
  value       = aws_sns_topic.auth.arn
}

output "image_queue_url" {
  description = "Image SQS queue URL"
  value       = aws_sqs_queue.image.url
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "image_lambda_function_name" {
  description = "Image Lambda function name"
  value       = aws_lambda_function.image_worker.function_name
}

output "auth_lambda_function_name" {
  description = "Auth Lambda function name"
  value       = aws_lambda_function.auth_notifier.function_name
}
