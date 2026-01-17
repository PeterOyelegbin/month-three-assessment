variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "ecr_image_retention_count" {
  description = "Number of ECR images to retain"
  type        = number
}
