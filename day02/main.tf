# Using Variables 
resource "aws_s3_bucket" "amazon-s3-demo-712026" {
  bucket = "my-tf-test-bucket-${var.environment}-s3-demo-712026"

  tags = {
    Name        = "My s3 bucket"
    Environment = var.environment
  }

  
}
