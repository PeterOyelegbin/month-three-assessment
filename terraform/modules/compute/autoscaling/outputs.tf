# Output instance IDs
output "instance_ids" {
  description = "ID of instances in the Auto Scaling Group"
  value       = data.aws_instances.asg_instances.ids
}
