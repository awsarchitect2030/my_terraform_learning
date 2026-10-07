variable dashboard_name {
  description = "The name of the CloudWatch dashboard."
  type        = string
}

variable function_name {
  description = "The name of the Lambda function to monitor."
  type        = string
}

variable metric_name {
  description = "The name of the CloudWatch metric to create."
  type        = string
}

variable metric_namespace {
  description = "The namespace of the CloudWatch metric."
  type        = string
}

variable success_metric_name {
  description = "The name of the CloudWatch metric to create for success."
  type        = string
}

variable success_metric_namespace {
  description = "The namespace of the CloudWatch metric for success."
  type        = string
}