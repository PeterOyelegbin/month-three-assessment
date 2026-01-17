resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-ecr"
  image_tag_mutability = "IMMUTABLE"   # Prevent overwriting tags

  image_scanning_configuration {
    scan_on_push = true                # Auto scan for vulnerabilities
  }

  encryption_configuration {
    encryption_type = "AES256"         # Default AWS-managed encryption
  }

  tags = {
    Name      = "${var.project_name}-ecr"
    ManagedBy = "terraform"
  }
}

resource "aws_ecr_lifecycle_policy" "backend_policy" {
  repository = aws_ecr_repository.backend.name

  policy = <<POLICY
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last ${var.ecr_image_retention_count} images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": ${var.ecr_image_retention_count}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
POLICY
}
