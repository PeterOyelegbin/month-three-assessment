variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  type = string
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "error_response_page_path" {
  description = "Path for error response page (typically index.html for SPAs)"
  type        = string
  default     = "/index.html"
}

variable "origin_id" {
  description = "CDN bucket ID"
  type = string
}
