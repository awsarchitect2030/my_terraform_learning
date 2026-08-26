output "linux_public_ip" {
  value = module.ec2_module_linux.instance_public_ip
}

output "ubuntu_public_ip" {
  value = module.ec2_module_ubuntu.instance_public_ip
}