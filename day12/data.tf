# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Package the Lambda function code
data "archive_file" "example" {
  type        = "zip"
  source_file = "${path.module}/test_python.py"
  output_path = "${path.module}/test_python.zip"
}
