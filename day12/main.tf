resource "aws_iam_role" "example" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Lambda function
resource "aws_lambda_function" "test_lambda_function" {
  filename      = data.archive_file.example.output_path
  function_name = "test_lambda_function"
  role          = aws_iam_role.example.arn
  handler       = "test_python.lambda_handler"
  code_sha256   = data.archive_file.example.output_base64sha256

  runtime = "python3.14"

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "production"
    Application = "example"
  }
}

/* resource "aws_lambda_function_url" "example" {
  function_name      = aws_lambda_function.test_lambda_function.function_name
  authorization_type = "NONE"
} */

resource "aws_lambda_function_url" "example" {
  function_name      = aws_lambda_function.test_lambda_function.function_name
  authorization_type = "AWS_IAM"
  invoke_mode        = "RESPONSE_STREAM"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}