terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "my-tf-test-bucket-amazon-s3-demo-712026"
    key          = "prod/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
    region       = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}