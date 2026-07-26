terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  alias = "primary"
  region = var.primary_region
}

provider "aws" {
  alias = "secondary"
  region = var.secondary_region
}