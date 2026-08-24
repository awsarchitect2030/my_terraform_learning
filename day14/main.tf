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


resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]
  key_name               = var.key_name
  count                  = 1
  
 connection {
  type = "ssh"
  user = "ubuntu"
  private_key = file(var.private_key_path)
  host = self.public_ip
}

  tags = {
    Name = "Provisioner_ec2"
  }

provisioner "local-exec" {
    command = "echo The server's IP address is ${self.private_ip}"
  } 

provisioner "file" {
  source      = "${path.module}/scripts/test_python.py"
  destination = "/tmp/test_python.py"
}

provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "echo 'Hello from remote-exec' | sudo tee /tmp/remote_exec.txt",
    "sudo chmod +x /tmp/test_python.py"
  ]
}

}