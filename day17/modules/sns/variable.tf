variable "endpoint" {
  description = "The endpoint of the SNS topic."
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}