output "load_balancer_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.load_balancer.alb_dns_name
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  value       = module.redis.redis_primary_endpoint
}

output "distribution_id" {
  description = "Cloudfront distribution id"
  value = module.cloudfront.distribution_id
}

output "cloudfront_url" {
  description = "Cloudfront public url"
  value = module.cloudfront.cdn_url
}
