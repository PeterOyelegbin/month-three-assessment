output "distribution_id" {
  description = "Cloudfront distribution id"
  value = aws_cloudfront_distribution.frontend.id
}

output "distribution_arn" {
  description = "Cloudfront distribution ARN"
  value = aws_cloudfront_distribution.frontend.arn
}

output "distribution_domain_name" {
  description = "Cloudfront distribution domain name"
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "cdn_url" {
  description = "Cloudfront public url"
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}
