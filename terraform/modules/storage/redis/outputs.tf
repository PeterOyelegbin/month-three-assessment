output "redis_primary_endpoint" {
  description = "Primary Redis endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}
