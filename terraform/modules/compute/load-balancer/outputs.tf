# Output the ALB DNS name
output "alb_dns_name" {
    description = "ALB DNS name"
    value = aws_lb.alb.dns_name
}

# Output the ALB target group ARN
output "alb_tg_arn" {
    description = "ALB target group ARN"
    value = aws_lb_target_group.target-group.arn
}
