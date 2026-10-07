variable "metric_filter_name" {
  description = "The name of the CloudWatch metric to create."
  type        = string
}

variable "metric_pattern" {
  description = "The pattern to match in the CloudWatch logs."
  type        = string
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group."
  type        = string
}

variable "metric_name" {
  description = "The name of the CloudWatch metric to create."
  type        = string
}

variable "metric_namespace" {
  description = "The namespace of the CloudWatch metric."
  type        = string
}

variable "success_metric_filter_name" {
  description = "The name of the CloudWatch metric to create for success."
  type        = string
}

variable "success_metric_pattern" {
  description = "The pattern to match in the CloudWatch logs for success."
  type        = string
}

variable "success_metric_name" {
  description = "The name of the CloudWatch metric to create for success."
  type        = string
}

variable "success_metric_namespace" {
  description = "The namespace of the CloudWatch metric for success."
  type        = string
}
