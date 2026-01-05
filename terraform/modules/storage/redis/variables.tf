variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "private_subnet_ids" {
    description = "The IDs of the private subnet"
    type = list(string)
}

variable "redis_engine_version" {
    description = "Redis engine version"
    type = string
}

variable "redis_node_type" {
    description = "Redis node type"
    type = string
}

variable "redis_num_node_grps" {
    description = "Redis number of node groups"
    type = number
}

variable "redis_replicas_per_node_grp" {
    description = "Redis number of replicas per node group"
    type = number
}

variable "redis_sg_id" {
    description = "Redis security group id"
    type = string
}

variable "redis_snapshot_retention_limit" {
    description = "Redis number of snapshot retention limit"
    type = number
}

variable "redis_snapshot_window" {
    description = "Redis snapshot date range"
    type = string
}

variable "redis_maintenance_window" {
    description = "Redis maintenance date range"
    type = string
}

variable "cloudwatch_log_grp_name" {
  description = "cloudwatch log group name maintenance date range"
  type = string
}
