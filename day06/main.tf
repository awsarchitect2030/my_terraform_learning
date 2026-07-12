# Using substr, replace, lower functions for S3 bucket naming convention

locals {
  bucket_name = substr(replace(lower(var.aws_bucket_name)," ","-"),0,24)

# Using split, join and for expressions to create a list of security group rules and formatted ports
  port_list = split(",", var.allowed_ports)

  sg_rules = [for port in local.port_list : {
    name        = "allow_port_${port}"
    port        = port
    description = "Allow traffic on port ${port}"

}]

formatted_ports = join("-", [for port in local.port_list : "port-${port}"])

}

resource "aws_s3_bucket" "my_bucket" {
  bucket = local.bucket_name

# Using merge function to combine tags from variable and local values. Environment tag in local value will override the Environment tag in variable if both are present.

  tags = merge(var.s3_tag, {
    Name        = local.bucket_name
    Environment = "Staging"
  }
  )
}

# Using lookup function to get the instance type based on the environment variable.

resource "aws_instance" "lookup_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = lookup(var.instance_type, var.env) # Using lookup function to get the instance type based on the environment

  tags = {
    Name        = "My EC2 Instance"
    Environment = var.env
  }
}