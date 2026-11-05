resource "aws_launch_template" "apptier_launch_template" {
  name = "apptier_launch_template"

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

  vpc_security_group_ids = [aws_security_group.apptier_ec2_sg.id, aws_security_group.allow_ssh.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "apptier_instance"
    }
  }

  user_data = base64encode(templatefile("${path.module}/backend/backend_user_data.sh", {
    region        = var.aws_region
    db_secret_arn = aws_db_instance.postgres_instance.master_user_secret[0].secret_arn
    db_host       = aws_db_instance.postgres_instance.address
    db_port       = aws_db_instance.postgres_instance.port
    db_name       = aws_db_instance.postgres_instance.db_name
    docker_image  = var.backend_docker_image
    environment   = var.environment
    project       = var.project
  }))
}


resource "aws_autoscaling_group" "apptier_asg_group" {
  name                      = "apptier_asg_group"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = [for subnet in aws_subnet.apptier_subnet : subnet.id]

  target_group_arns = [aws_lb_target_group.internal_lb_tg.arn]

  launch_template {
    id      = aws_launch_template.apptier_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "apptier_instance"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "apptier_AverageCPUUtilizationPolicy" {
  autoscaling_group_name = aws_autoscaling_group.apptier_asg_group.name
  name                   = "apptier_cpu_target_tracking"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

