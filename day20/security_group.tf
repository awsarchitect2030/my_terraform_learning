resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb_sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb_sg"
    Environment = var.environment
  }

}

resource "aws_security_group" "application_sg" {
  name        = "${var.environment}-application_sg"
  description = "Security group for Application instances"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description     = "HTTP from Internet"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "HTTPS from Internet"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound (NAT Traffic)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-application_sg"
    Environment = var.environment
  }

}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.environment}-allow-ssh"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-allow-ssh"
    Environment = var.environment
  }
}