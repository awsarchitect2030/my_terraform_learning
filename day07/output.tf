output "vpc_name"{
  value = data.aws_vpc.default_vpc.id
}

output "shared_subnet" {
  value = data.aws_subnet.subnet_shared.id
}

output "AMI_id" {
  value = data.aws_ami.ubuntu.image_id
}