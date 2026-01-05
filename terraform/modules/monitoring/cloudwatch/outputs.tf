output "redis_cloudwatch_log_grp_name" {
    description = "Cloudwatch log group name"
    value = aws_cloudwatch_log_group.redis_slow.name
}
