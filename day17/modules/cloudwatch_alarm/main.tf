resource "aws_cloudwatch_metric_alarm" "error_rate_alarm" {
  alarm_name          = "${var.function_name}-error_rate_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.threshold
  alarm_description   = "Alarm when the error rate exceeds ${var.threshold} for ${var.evaluation_periods} consecutive periods of ${var.period} seconds."
  actions_enabled     = true
  alarm_actions       = [var.topic_arn]
  ok_actions          = [var.topic_arn]

  dimensions = {
    FunctionName = var.function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "invocation_alarm" {
  alarm_name          = "${var.function_name}-invocation_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = var.period
  statistic           = "Sum"

  threshold           = var.invocation_threshold
  alarm_description   = "Alarm when the invocation count exceeds ${var.invocation_threshold} for ${var.evaluation_periods} consecutive periods of ${var.period} seconds."
  actions_enabled     = true

  alarm_actions       = [var.topic_arn]
  ok_actions          = [var.topic_arn]

  dimensions = {
    FunctionName = var.function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "Throttle_alarm" {
  alarm_name          = "${var.function_name}-throttle_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = var.period
  statistic           = "Sum"

  threshold           = var.throttle_threshold
  alarm_description   = "Alarm when the throttle count exceeds ${var.throttle_threshold} for ${var.evaluation_periods} consecutive periods of ${var.period} seconds."
  actions_enabled     = true

  alarm_actions       = [var.topic_arn]
  ok_actions          = [var.topic_arn]

  dimensions = {
    FunctionName = var.function_name
  }
}
