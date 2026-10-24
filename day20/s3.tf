resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "alb_access_logs" {
  bucket = "${var.environment}-alb-access-logs-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.environment}-alb-access-logs-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_alb" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = data.aws_iam_policy_document.allow_alb_access.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_alb_access" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.alb_access_logs.arn}/${var.environment}-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
  }
}