resource "aws_instance" "ec2_instance" {
  ami                    = var.ami_id_value
  instance_type          = var.instance_type_value
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
  #!/bin/bash
  dnf update -y
  dnf install -y httpd
  systemctl enable httpd
  systemctl start httpd
  echo "<html><body><h1>Hello this is from Linux EC2 module</h1></body></html>" > /var/www/html/index.html
  EOF
}