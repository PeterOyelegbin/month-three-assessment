# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "frontend" {
    name                              = "${var.project_name}-oac"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
}

# CloudFront Distribution (SPA-friendly)
resource "aws_cloudfront_distribution" "frontend" {
    enabled             = true
    default_root_object = var.default_root_object

    origin {
        domain_name              = var.s3_bucket_regional_domain_name
        origin_id                = var.origin_id
        origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
    }

    default_cache_behavior {
        target_origin_id       = var.origin_id
        viewer_protocol_policy = "redirect-to-https"

        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }

    custom_error_response {
        error_code         = 403
        response_code      = 200
        response_page_path = var.error_response_page_path
    }

    custom_error_response {
        error_code         = 404
        response_code      = 200
        response_page_path = var.error_response_page_path
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = {
        Name      = "${var.project_name}-frontend-cdn"
        ManagedBy = "terraform"
    }
}
