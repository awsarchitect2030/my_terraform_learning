locals {
  # User data template for Primary instance
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable --now nginx
    echo "<h1>Hello from my Ubuntu EC2 Instance!</h1>" > /var/www/html/index.html
  EOF
}