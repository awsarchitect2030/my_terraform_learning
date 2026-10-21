resource "aws_lb" "my-app-lb" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_access_logs.id
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "app-load-balancer"
  }

  depends_on = [
    aws_s3_bucket_policy.allow_access_from_alb
  ]

}

resource "aws_lb_target_group" "lb-tgtgrp" {
  name     = "django-tgtgrp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-target-group"
  }
}

resource "aws_lb_listener" "my_app_lb_listener" {
  load_balancer_arn = aws_lb.my-app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tgtgrp.arn
  }
}

