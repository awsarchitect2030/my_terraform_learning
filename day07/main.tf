# Using datasource to use the existing default VPC, subnet and ami to create EC2 instance.
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet" "subnet_shared"{
  vpc_id = data.aws_vpc.default_vpc.id

  filter {
    name = "availability-zone"
    values = ["ap-south-1b"]
  }
}

data "aws_ami" "ubuntu" {
  
  most_recent      = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "my_ubuntu_ds_instance" {
  subnet_id = data.aws_subnet.subnet_shared.id
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    environment = "test"
  }
  
}