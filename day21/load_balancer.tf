resource "aws_lb" "external_alb" {
  name               = "external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_lb_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  tags = {
    Name = "External_ALB"
  }
}

resource "aws_lb_target_group" "external_lb_tg" {
  name     = "external-lb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "external-lb-target-group"
  }
}

resource "aws_lb_listener" "external_lb_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_lb_tg.arn
  }
}

resource "aws_lb" "internal_alb" {
  name               = "alb-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb_sg.id]
  subnets            = [for subnet in aws_subnet.apptier_subnet : subnet.id]

  tags = {
    Name = "Internal_ALB"
  }
}

resource "aws_lb_target_group" "internal_lb_tg" {
  name = "internal-lb-tg"

  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/health"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "internal-lb-target-group"
  }
}

resource "aws_lb_listener" "internal_lb_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_lb_tg.arn
  }
}