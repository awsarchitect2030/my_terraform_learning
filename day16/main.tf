resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route_table_association" "Public-RT-Association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public-RT.id
}

resource "aws_security_group" "primary_sg" {
  name        = "Primary_SG"
  description = "Security group for Primary - EC2"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "Primary_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_rule" {
  security_group_id = aws_security_group.primary_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "http_rule" {
  security_group_id = aws_security_group.primary_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound_rule" {
  security_group_id = aws_security_group.primary_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.primary_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.iam_instance_profile.name
  user_data                   = local.user_data

  tags = {
    Name = "Ubuntu-EC2"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "RDS_SG"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "RDS_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_connectivity_rule" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_security_group.primary_sg.id

  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_db_instance" "logindb" {
  identifier                  = "logindb"
  instance_class              = "db.t3.micro"
  allocated_storage           = 5
  engine                      = "mysql"
  engine_version              = "8.0"
  username                    = "admin"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  publicly_accessible         = false
  skip_final_snapshot         = true
}

resource "aws_iam_policy" "rds_ec2_policy" {
  name        = "rds_ec2_policy"
  path        = "/"
  description = "rds_ec2_policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:ap-south-1:931628309022:secret:rds!db-3ec02d17-9d03-498d-8e63-fed5286860a8-fj650v"
      },
    ]
  })
}

resource "aws_iam_role" "rds_ec2_role" {
  name = "rds_ec2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "rds-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_ec2_role_policy_attachment" {
  role       = aws_iam_role.rds_ec2_role.name
  policy_arn = aws_iam_policy.rds_ec2_policy.arn
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "rds_ec2_instance_profile"
  role = aws_iam_role.rds_ec2_role.name
}
