terraform {
  backend "s3" {
    bucket       = "my-terraform-state-24102026"
    key          = "day20/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
    region       = "ap-south-1"
  }
}
