output "metric_name" {
  value = aws_cloudwatch_log_metric_filter.Image_processing_timeout.metric_transformation[0].name
}

output "metric_namespace" {
  value = aws_cloudwatch_log_metric_filter.Image_processing_timeout.metric_transformation[0].namespace
}

output "success_metric_name" {
  value = aws_cloudwatch_log_metric_filter.ImageProcessingSuccess.metric_transformation[0].name
}

output "success_metric_namespace" {
  value = aws_cloudwatch_log_metric_filter.ImageProcessingSuccess.metric_transformation[0].namespace
}