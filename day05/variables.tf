variable custom_tags{
  type = map(string)
  default = {
    Name        = "tf-instance"
    Environment = "dev"
    created_by  = "Terraform"
  }
}

variable instance_count {
  type    = number
  default = 2
}

variable env {
  type    = string
  default = "staging"
}

variable ingress_rules {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "http"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "https"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}