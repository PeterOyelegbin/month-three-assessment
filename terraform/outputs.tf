output "load_balancer_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.load_balancer.alb_dns_name
}
