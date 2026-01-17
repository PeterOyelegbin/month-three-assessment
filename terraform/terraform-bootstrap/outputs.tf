output "terraform_state_bucket" {
  description = "Terraform remote state bucket name"
  value       = aws_s3_bucket.tf_state.bucket
}

output "terraform_lock_table" {
  description = "Terraform remote locks table name"
  value       = aws_dynamodb_table.tf_locks.name
}
