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

# Using length, can, regex functions in variable section and added as instance type

resource "aws_instance" "validate_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type_validation

  tags = {
    Name        = "My EC2 Instance"
    Environment = var.env
  }
}

# Using endswith and sensitive data handling in variable section and added as log level and credentials

locals {
  log_level = var.log_level
  credentials = var.secrets
}

# Using fileexists and dirname functions to check the existence of files and get their directory names

locals{
  config_file = [
    "./main.tf",
    "./variables.tf",
    "./output.tf"
    ]
  
file_status = { 
  for file in local.config_file:
    file => fileexists(file) 
  }

file_dir = { 
  for file in local.config_file:
    file => dirname(file) 
  }
}

# USing concat, distinct and toset functions.

locals{
  All_edge_location = concat(var.edge_locations, var.Preferred_edge_location)
  Unique_edge_location = distinct(local.All_edge_location)
  # Unique_edge_location = toset(local.All_edge_location) -> Conver to set to remove duplicates, but the output will be in set format, so using distinct function to get unique values in list format.
}

# Using timestamp and formatdate functions. 

locals{
  current_timestamp = timestamp()

  resource_creation_time = formatdate("YYYYMMDD", local.current_timestamp)

  resource_name = "my-s3-resource-${local.resource_creation_time}"

}

resource "aws_s3_bucket" "timestamped_bucket" {
  bucket = local.resource_name

  tags = {
    Name        = local.resource_name
    Environment = var.env
  }
}

# File handling functions. Create config.json before proceeding.
# # Example config.json:
# # {
# #   "database": {
# #     "host": "db.example.com",
# #     "port": 5432,
# #     "username": "admin"
# #   }
# # }

locals{
  fileexists_status = fileexists("./config.json")

  config_data = local.fileexists_status ? jsondecode(file("./config.json")) : {
    database = {
      host = "db.example.com"
      port = 5432
      username = "default"
    }
   }
}

# Store sensitive configuration in AWS Secrets Manager
resource "aws_secretsmanager_secret" "secret" {
  name = "app-configuration-${formatdate("YYYYMMDD",timestamp())}"
  description = "App configuration"
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(local.config_data)
}

# Using datasources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
  

