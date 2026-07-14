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

output "log_level" {
  value = local.log_level
}

output "credentials" {
  value = local.credentials
  sensitive   = true
}

output "file_status" {
  value = local.file_status
}

output "Dir_status" {
  value = local.file_dir
}

output "Edge_location" {
  value = local.Unique_edge_location
}

output "All_Edge_location" {
  value = local.All_edge_location
}

output "Current_timestamp"{
  value = local.current_timestamp
}

output "Resource_creation_time"{
  value = local.resource_creation_time
}

output "Resource_name"{
  value = local.resource_name
}

output "config_file_exists" {
  value       = local.fileexists_status
}

output "config_data" {
  value       = { for k, v in local.config_data : k => v if k != "password" }
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.secret.arn
}

output "secret_info" {
  value = local.config_data.database 
}

output "current_region" {
  value = data.aws_region.current.region
}

output "aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
}

output "available_azs" {
  value       = data.aws_availability_zones.available.names
}