resource "aws_security_group" "external_lb_sg" {
  name        = "external_lb_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "external_lb_sg"
  }

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
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webtier_ec2_sg" {
  name        = "webtier_ec2_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "webtier_ec2_sg"
  }

  ingress {
    description     = "Inbound External LB traffic"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.external_lb_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_lb_sg" {
  name        = "internal_lb_sg"
  description = "Allow webtier inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "internal_lb_sg"
  }

  ingress {
    description     = "HTTP from Internet"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.webtier_ec2_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "apptier_ec2_sg" {
  name        = "apptier_ec2_sg"
  description = "Allow internal LB inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "apptier_ec2_sg"
  }

  ingress {
    description     = "internal LB traffic"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dbtier_ec2_sg" {
  name        = "dbtier_ec2_sg"
  description = "Allow PostgreSQL inbound traffic from the app tier"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "dbtier_ec2_sg"
  }

  ingress {
    description     = "PostgreSQL from the app tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.apptier_ec2_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh-access"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.my_vpc.id

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
    Name = "allow-ssh-access"
  }
}