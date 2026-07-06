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

resource "aws_s3_bucket" "my_bucket_for_each" {
  for_each = var.bucket_name_for_each
  bucket = each.value
  
  tags = var.custom_tags
}