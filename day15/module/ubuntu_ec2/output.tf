output "instance_public_ip" {
  value       = aws_instance.ec2_instance_ubuntu.public_ip
  description = "The public IP address of the Ubuntu server"
}