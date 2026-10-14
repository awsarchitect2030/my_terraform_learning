#!/bin/bash

# Update the package repository
dnf update -y

# Install Docker
dnf install -y docker

# Start and enable Docker service
systemctl enable --now docker

# Pull and run the Django application container
# Mapping Host Port 80 (ALB traffic) to Container Port 8000 (Django default)
docker run -d \
  --name django-app \
  --restart always \
  -p 80:8000 \
  itsbaivab/django-app