resource "aws_iam_role" "example" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_s3_access" {
  name   = "lambda_s3_access_policy"
  policy = data.aws_iam_policy_document.assume_s3_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

resource "aws_iam_policy" "lambda_cloudwatch_access" {
  name   = "lambda_cloudwatch_access_policy"
  policy = data.aws_iam_policy_document.cloudwatch_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_access.arn
}

# Lambda function
resource "aws_lambda_function" "image_processor" {
  filename      = data.archive_file.example.output_path
  function_name = "image_processor"
  role          = aws_iam_role.example.arn
  handler       = "image_processor.lambda_handler"
  code_sha256   = data.archive_file.example.output_base64sha256

  runtime = "python3.14"

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_lambda_file_system.bucket
    }
  }
}

resource "aws_s3_bucket" "upload_lambda_file_system" {
  bucket           = "source-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_versioning" "upload_lambda_file_system" {
  bucket = aws_s3_bucket.upload_lambda_file_system.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "processed_lambda_file_system" {
  bucket           = "processed-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_versioning" "processed_lambda_file_system" {
  bucket = aws_s3_bucket.processed_lambda_file_system.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_lambda_permission" "lambda_s3_permission" {
  statement_id  = "AllowExecutionFromS3_lambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_lambda_file_system.arn
}


resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.upload_lambda_file_system.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpeg"
  }

  depends_on = [aws_lambda_permission.lambda_s3_permission]
}
