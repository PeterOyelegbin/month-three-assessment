variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

# VPC variables defination
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Autoscaling Group variables defination
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

# Cloudwatch variables defination
variable "redis_cloudwatch_retention_in_days" {
  description = "Cloudwatch log retention period in days"
  type        = number
}

# Redis variables defination
variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
}

variable "redis_num_node_grps" {
  description = "Redis number of node groups"
  type        = number
}

variable "redis_replicas_per_node_grp" {
  description = "Redis number of replicas per node group"
  type        = number
}

variable "redis_snapshot_retention_limit" {
  description = "Redis number of snapshot retention limit"
  type        = number
}

variable "redis_snapshot_window" {
  description = "Redis snapshot date range"
  type        = string
}

variable "redis_maintenance_window" {
  description = "Redis maintenance date range"
  type        = string
}

# ECR variables defination
variable "ecr_image_retention_count" {
  description = "Number of ECR images to retain"
  type        = number
}
