variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

data "aws_availability_zones" "az" {
  state = "available"
}

variable "webtier_private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}

variable "webtier_private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "apptier_private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}

variable "apptier_private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.21.0/24", "10.10.22.0/24"]
}

variable "dbtier_private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}

variable "dbtier_private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.31.0/24", "10.10.32.0/24"]
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "backend_docker_image" {
  description = "The Docker image for the backend application"
  type        = string
  default     = "awsarchitect2030/backend:v1"
}

variable "environment" {
  description = "The environment for the deployment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "The project name for the deployment"
  type        = string
  default     = "goalsapp"
}

variable "frontend_docker_image" {
  description = "The Docker image for the frontend application"
  type        = string
  default     = "awsarchitect2030/frontend:v1"
}