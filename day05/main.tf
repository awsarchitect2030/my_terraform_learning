# Conditional Expressions to choose instance type based on environment variable
resource "aws_instance" "webserver" {
  ami           = "ami-0912f71e06545ad88"
  count         = var.instance_count
#  instance_type = "c6a.2xlarge"
  instance_type = var.env == "prod" ? "t3.micro" : "t2.micro"

  tags = var.custom_tags
}

# dynamic block - Create a security group with dynamic ingress rules based on the provided variable
resource "aws_security_group" "ingress_sg" {
  name        = "ingress-sg"
  description = "Security group for ingress rules"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

# Splat expression to get the public IPs of all instances

output "instance_public_ips" {
  value = aws_instance.webserver[*].public_ip
}