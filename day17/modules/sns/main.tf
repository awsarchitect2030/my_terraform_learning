resource "aws_sns_topic" "critical_alerts" {
  name = "critical-alerts-topic"

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-critical-alerts"
      AlertType = "Critical"
    }
  )

}

resource "aws_sns_topic_subscription" "critical_alerts" {
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "email"
  endpoint  = var.endpoint
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.critical_alerts.arn

  policy = data.aws_iam_policy_document.sns_critical_alerts_policy.json
}

