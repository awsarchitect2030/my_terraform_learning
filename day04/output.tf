output "bucket_name_list" {
  description = "S3 bucket names created using count"
  value = [for i in aws_s3_bucket.my_bucket : i.bucket]
}

output "bucket_name_for_each" {
  description = "S3 bucket names created using for_each"
  value = [for i in aws_s3_bucket.my_bucket_for_each : i.bucket]
}

output "bucket_name_depends_on" {
  description = "S3 bucket name created using depends_on"
  value = aws_s3_bucket.my_bucket1.bucket
}