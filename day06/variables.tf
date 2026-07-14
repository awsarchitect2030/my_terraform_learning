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

variable "instance_type_validation" {
  description = "The instance type for the EC2 instance with validation"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = length(var.instance_type_validation) > 0 && can(regex("^[a-zA-Z0-9.]+$",var.instance_type_validation))
    error_message = "The instance type must be a non-empty string and match the regex pattern."
  }
}

variable "log_level" {
  description = "To test the endswith function"
  type        = string
  default     = "DEBUG.log"

  validation {
    condition     = endswith(var.log_level, ".log")
    error_message = "The log level must be one of the following: DEBUG, INFO, WARN, ERROR."
  }
}

variable "secrets" {
  description = "To test the sensitive variable"
  type        = string
  default     = "asdfjasdf"
  sensitive = true
  }

  variable "edge_locations" {
    description = "List of edge locations for the CloudFront distribution"
    type        = list(string)
    default     = ["us-east-1", "us-west-2", "eu-west-1"]
  }

  variable "Preferred_edge_location" {
    description = "Preferred edge location for the CloudFront distribution"
    type        = list(string)
    default     = ["us-east-1"]
  }