# Defines AWS S3 buckets using different methods: `count`, `depends_on`.
resource "aws_s3_bucket" "my_bucket" {
  count = 3
  bucket = var.bucket_name[count.index]
  
  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
  depends_on = [aws_s3_bucket.my_bucket1]
}

resource "aws_s3_bucket" "my_bucket1" {
  bucket = "my-depends-on-bucket-name-55555"
  
  tags = var.custom_tags
}

# Enabling bucket versioning for the S3 bucket created above.
resource "aws_s3_bucket_versioning" "my_bucket_verssion"{
  bucket = aws_s3_bucket.my_bucket1.id
versioning_configuration {
    status = "Enabled"
  }
}

# Defines AWS S3 buckets using different methods: for_each
resource "aws_s3_bucket" "my_bucket_for_each" {
  for_each = var.bucket_name_for_each
  bucket = each.value
  
  tags = var.custom_tags
}

# create_before_destroy, prevent_destroy, ignore_changes example
resource "aws_instance" "webserver" {
  ami           = "ami-0d7b208dc5b0fe76a"
  instance_type = "t3.micro"

lifecycle {
  create_before_destroy = true
  prevent_destroy       = false # Set to true to prevent accidental deletion of the resource
  ignore_changes        = [ami] # Ignore changes to the AMI attribute
}
}

# precondition & postcondition example
resource "aws_instance" "webserver_with_condition" {
  ami           = "ami-0d7b208dc5b0fe76a"
  instance_type = var.instance_type
  tags          = var.tags

# Below condition throws errors if instance type is not t3.micro
  lifecycle {
    precondition {
      condition     = var.instance_type == "t3.micro"
      error_message = "The instance type must be t3.micro."
    }

# Error: Resource postcondition failed message will be thrown if the Environment tag is not present in the tags map.
      postcondition {
      condition = contains(keys(self.tags), "Environment")
      error_message = "The 'Environment' tag must be present in the tags."
    }
  
  }
}