variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "alb_sg_id" {
    description = "Security Group ID for the ALB"
    type        = string
}

variable "public_subnet_ids" {
    description = "List of Public Subnet IDs for the ALB"
    type        = list(string)
}

variable "vpc_id" {
    description = "VPC ID where the ALB will be deployed"
    type        = string
}