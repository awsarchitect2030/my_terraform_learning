resource "aws_launch_template" "ASG_launch_template" {
  name          = "${var.environment}-app-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.application_sg.id,
  aws_security_group.allow_ssh.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-django-app-instance"
      Environment = var.environment
    }
  }

  user_data = filebase64("${path.module}/user_data.sh")
}

resource "aws_autoscaling_group" "asg_group" {
  name                      = "${var.environment}-django-app-asg-grp"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = aws_subnet.private_subnet[*].id
  target_group_arns         = [aws_lb_target_group.lb-tgtgrp.arn]
  launch_template {
    id      = aws_launch_template.ASG_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-django-app-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

}


resource "aws_autoscaling_policy" "asg_scale_in_policy" {
  name                   = "${var.environment}-asg-scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}

resource "aws_autoscaling_policy" "asg_scale_out_policy" {
  name                   = "${var.environment}-asg-scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}

resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "${var.environment}-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "${var.environment}-HighCPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.asg_scale_out_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_group.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "${var.environment}-LowCPUUtilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.asg_scale_in_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_group.name
  }
}













