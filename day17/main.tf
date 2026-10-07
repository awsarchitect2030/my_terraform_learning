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

  memory_size = 512
  timeout     = 30

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

resource "aws_cloudwatch_log_group" "image_processor" {
  name = "/aws/lambda/image_processor"
}

module "cloudwatch_monitoring" {
  source = "./modules/cloudwatch_monitoring"

  metric_filter_name = "ImageProcessingtimeout"
  metric_pattern     = "\"Status: timeout\""
  log_group_name     = aws_cloudwatch_log_group.image_processor.name
  metric_name        = "ImageProcessingTimeout"
  metric_namespace   = "ImageProcessing"

  success_metric_filter_name = "ImageProcessingSuccess"
  success_metric_pattern     = "\"PNG uploaded successfully\""
  success_metric_name        = "ImageProcessingSuccess"
  success_metric_namespace   = "SucessfulImageProcessing"
}

module "sns" {
  source = "./modules/sns"

  project_name = "image-processor"
  endpoint     = "your_email@example.com"

  tags = {
    Environment = "dev"
    Owner       = "MyTeam"
  }
}

module "cloudwatch_alarm" {
  source = "./modules/cloudwatch_alarm"

  function_name        = aws_lambda_function.image_processor.function_name
  evaluation_periods   = 1
  period               = 60
  threshold            = 2
  invocation_threshold = 5
  throttle_threshold   = 3
  topic_arn            = module.sns.critical_alerts_topic_arn
}

module "cloudwatch_dashboard" {
  source = "./modules/cloudwatch_dashboard"

  dashboard_name           = "image-processor-dashboard"
  function_name            = aws_lambda_function.image_processor.function_name
  metric_name              = module.cloudwatch_monitoring.metric_name
  metric_namespace         = module.cloudwatch_monitoring.metric_namespace
  success_metric_name      = module.cloudwatch_monitoring.success_metric_name
  success_metric_namespace = module.cloudwatch_monitoring.success_metric_namespace
}