output "critical_alerts_topic_arn" {
  description = "ARN of the SNS topic used for critical alerts"
  value       = aws_sns_topic.critical_alerts.arn
}