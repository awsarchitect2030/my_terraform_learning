resource "aws_launch_template" "webtier_launch_template" {
  name = "webtier_launch_template"

  ebs_optimized = true

  image_id = "ami-0c7632fb77f35db43"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  key_name = "EC2Keypair"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.webtier_ec2_sg.id, aws_security_group.allow_ssh.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "webtier_instance"
    }
  }

  user_data = base64encode(templatefile("${path.module}/frontend/frontend_user_data.sh", {
    backend_internal_url = "http://${aws_lb.internal_alb.dns_name}:8080"
    docker_image         = var.frontend_docker_image
  }))

}


resource "aws_autoscaling_group" "webtier_asg_group" {
  name                      = "webtier_asg_group"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = [
  for subnet in aws_subnet.webtier_subnet : subnet.id]

  target_group_arns = [aws_lb_target_group.external_lb_tg.arn]

  launch_template {
    id      = aws_launch_template.webtier_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "webtier_instance"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "webtier_AverageCPUUtilizationPolicy" {
  autoscaling_group_name = aws_autoscaling_group.webtier_asg_group.name
  name                   = "webtier_cpu_target_tracking"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}