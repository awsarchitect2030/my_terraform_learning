variable "bucket_name" {
    type        = list(string)
    description = "List of S3 bucket names"
    default     = ["my-unique-bucket-name-12340", "my-unique-bucket-name-67891", "my-unique-bucket-name-54322"]
}

variable "custom_tags" {
    type        = map(string)
    description = "Custom tags for the S3 buckets"
    default     = {
        Name        = "MyBucket"
        Environment = "Dev"
    }
}

variable "bucket_name_for_each" {
    type        = set(string)
    description = "List of S3 bucket names for for_each"
    default     = ["my-unique-bucket-name-11111", "my-unique-bucket-name-22222", "my-unique-bucket-name-33333"]
}