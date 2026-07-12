output "bucket_name" {
  value = local.bucket_name
}

output "s3_tag_info" {
  value = aws_s3_bucket.my_bucket.tags
}

output "sg_rules" {
  value = local.sg_rules
}

output "allowed_ports" {
  value = local.port_list
}

 output "formatted_ports" {
  value       = local.formatted_ports
}