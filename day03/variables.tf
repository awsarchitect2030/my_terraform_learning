variable "instance_count" {
  type    = number
  default = 1
}

variable "Environment" {
  type    = string
  default = "Dev"
}

variable "tag_name" {
  type    = string
  default = "HelloWorld"
}

variable "monitoring"{
    type    = bool
    default = true
}

variable "Instance_type_list"{
    type    = list(string)
    default = ["t3.micro", "t3.small", "t3.medium"]
}

variable "AZ_set"{
    type    = set(string)
    default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "tag_map" {
  type    = map(string)
  default = {
    owner = "Terraform"
    project = "Terraform-Training-course"
  }
}

variable "SG_config"{
    type = tuple([number, string, number])
    default = [443, "tcp", 443]
}

variable "sg_config_tag"{
    type = object({
        Name = string
        description = string
    })
    default = {
        Name = "allow_tls"
        description = "Allow TLS inbound traffic and all outbound traffic"
    }
}