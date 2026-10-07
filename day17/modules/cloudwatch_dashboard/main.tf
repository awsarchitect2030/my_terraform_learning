resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              var.function_name
            ]
          ]

          period = 60
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Lambda Invocations"
        }
      },
      
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              var.function_name
            ]
          ]

          period = 60
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Lambda Errors"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/Lambda",
              "Throttles",
              "FunctionName",
              var.function_name
            ]
          ]

          period = 60
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Lambda Throttles"
        }
      },

    {
            type   = "metric"
            x      = 0
            y      = 12
            width  = 12
            height = 6
    
            properties = {
            metrics = [
                [
                var.metric_namespace,
                var.metric_name
                ]
            ]
    
            period = 60
            stat   = "Sum"
            region = "ap-south-1"
            title  = "Image Processing Timeout"
            }
    },

    {
            type   = "metric"
            x      = 12
            y      = 12
            width  = 12
            height = 6
    
            properties = {
            metrics = [
                [
                var.success_metric_namespace,
                var.success_metric_name
                ]
            ]
    
            period = 60
            stat   = "Sum"
            region = "ap-south-1"
            title  = "Successful Image Processing"
            }
    }

   ]
  })
}
