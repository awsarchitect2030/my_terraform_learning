variable "aws_bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
  default     = "My Terraform Bucket 7658 staging environment"
}

variable "s3_tag" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {
    Environment = "Development"
    Owner       = "Terraform User"
  }
}

variable "allowed_ports" {
  description = "List of allowed ports for security group"
  type        = string
  default     = "22,80,443"
}

variable "env" {
  description = "The environment for the resources"
  type        = string
  default     = "prod"
  }

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = map(string)
  default     = {
    "prod" = "t3.micro"
    "staging" = "t2.small"
    "dev" = "t2.medium"
  }
}
