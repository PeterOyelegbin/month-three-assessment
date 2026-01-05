variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "redis_cloudwatch_retention_in_days" {
  description = "Number of day to retain logs for redis Cloudwatch"
  type = number
}
