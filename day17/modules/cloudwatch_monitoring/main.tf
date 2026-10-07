resource "aws_cloudwatch_log_metric_filter" "Image_processing_timeout" {
  name           = var.metric_filter_name
  pattern        = var.metric_pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name      = var.metric_name
    namespace = var.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "ImageProcessingSuccess" {
  name           = var.success_metric_filter_name
  pattern        = var.success_metric_pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name      = var.success_metric_name
    namespace = var.success_metric_namespace
    value     = "1"
  }
}
