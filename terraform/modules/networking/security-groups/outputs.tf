output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "instance_sg_id" {
  description = "ID of the instance security group"
  value       = aws_security_group.instance_sg.id
}

output "redis_sg_id" {
  description = "ID of the redis security group"
  value       = aws_security_group.redis.id
}
