data "aws_availability_zones" "primary" {
  provider = aws.primary
  state = "available"
}

data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state = "available"
}

data "aws_ami" "primary_ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-20**"]
  }
}

data "aws_ami" "secondary_ec2_ami" {
  provider = aws.secondary
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}