variable "primary_region" {
 description = "Primary AWS region for the first VPC"
 type        = string
 default     = "ap-south-1"
}

variable "secondary_region" {
 description = "Secondary AWS region for the first VPC"
 type        = string
 default     = "us-west-2"
}

variable "primary_vpc_cidr" {
 description = "CIDR range of Primary VPC"
 type        = string
 default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
 description = "CIDR range of secondary VPC"
 type        = string
 default     = "10.1.0.0/16"
}

variable "primary_subnet" {
 description = "CIDR range of Primary subnet"
 type        = string
 default     = "10.0.1.0/24"
}

variable "secondary_subnet" {
 description = "CIDR range of secondary subnet"
 type        = string
 default     = "10.1.1.0/24"
}

variable "ec2_type" {
 description = "EC2_instance_type"
 type        = string
 default     = "t3.micro"
}