resource "aws_cloudwatch_log_group" "redis_slow" {
    name              = "/elasticache/${var.project_name}/redis/slowlog"
    retention_in_days = var.redis_cloudwatch_retention_in_days
}
