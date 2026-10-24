variable "environment" {
  type = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0cede6fe40e6ac719" # Replace with a valid AMI ID for your region
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}