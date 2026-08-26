resource "aws_instance" "ec2_instance_ubuntu" {
  ami                    = var.ami_id_value
  instance_type          = var.instance_type_value
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt install -y apache2
  sudo systemctl enable apache2
  sudo systemctl start apache2
  echo "<html><body><h1>Hello this is from ubuntu EC2 module</h1></body></html>" > /var/www/html/index.html
  EOF

}