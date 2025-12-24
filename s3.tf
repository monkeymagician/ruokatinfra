resource "aws_s3_bucket" "original" {
  bucket = "${var.project_name}-original-${var.account_id}"
  tags   = { Name = "${var.project_name}-original-bucket" }
}

resource "aws_s3_bucket" "processed" {
  bucket = "${var.project_name}-processed-${var.account_id}"
  tags   = { Name = "${var.project_name}-processed-bucket" }
}

resource "aws_s3_bucket_notification" "original_notification" {
  bucket = aws_s3_bucket.original.id
  topic {
    topic_arn = aws_sns_topic.image.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sns_topic_policy.image]
}

resource "aws_s3_bucket_lifecycle_configuration" "processed_lifecycle" {
  bucket = aws_s3_bucket.processed.id

  rule {
    id     = "optimized-lifecycle"
    status = "Enabled"

    filter {
      prefix = "optimized/"
    }

    # [수정 완료] 복잡한 제약 조건을 피하기 위해 1일 후 바로 GLACIER로 전환합니다.
    # 이렇게 하면 다른 클래스와의 간격 문제를 신경 쓸 필요 없이 바로 배포가 가능합니다.
    transition {
      days          = 1
      storage_class = "GLACIER"
    }
  }
}