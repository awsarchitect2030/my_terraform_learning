data "aws_iam_policy_document" "sns_critical_alerts_policy" {

  statement {
     effect = "Allow"

      principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

      actions = [
        "SNS:Publish"
      ]

      resources = [aws_sns_topic.critical_alerts.arn]
    }
}