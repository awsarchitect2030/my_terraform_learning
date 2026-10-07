variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "evaluation_periods" {
  description = "Number of periods over which data is compared to the specified threshold"
  type        = number
}

variable "period" {
  description = "The period, in seconds, over which the specified statistic is applied"
  type        = number
}

variable "threshold" {
  description = "The value against which the specified statistic is compared"
  type        = number
}

variable "topic_arn" {
  description = "ARN of the SNS topic to send alarm notifications"
  type        = string
}

variable "invocation_threshold" {
  description = "The value against which the invocation count is compared"
  type        = number
}

variable "throttle_threshold" {
  description = "The value against which the throttle count is compared"
  type        = number
}