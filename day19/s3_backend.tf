terraform {
  backend "s3" {
    bucket = "my-terraform-state-22102026"
    key    = "day19/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
    region = "ap-south-1"
  }
}
