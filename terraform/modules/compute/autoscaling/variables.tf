variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for autoscaling group"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_sg_id" {
  description = "Security group ID for the instances"
  type        = string
}

variable "desired_capacity" {
  description = "Desired capacity for the autoscaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum size for the autoscaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum size for the autoscaling group"
  type        = number
}
