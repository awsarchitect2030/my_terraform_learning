resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu-web-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP "
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow All traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ubuntu-security-group"
  }
}


module "ec2_module_linux" {
  source = "./module/linux_ec2"
  instance_type_value="t3.micro"
  ami_id_value="ami-0ac7b260cf76d8865"
  security_group_id = aws_security_group.ubuntu_sg.id
}

module "ec2_module_ubuntu" {
  source = "./module/ubuntu_ec2"
  instance_type_value="t3.micro"
  ami_id_value="ami-01a00762f46d584a1"
  security_group_id = aws_security_group.ubuntu_sg.id
}