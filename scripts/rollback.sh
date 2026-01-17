#!/bin/bash

set -euo pipefail

# Set environment
AWS_REGION="us-east-1"
PROJECT_NAME="starttech"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform"

echo "Delete deployed frontend content in the S3 bucket..."
aws s3 rm s3://${PROJECT_NAME}-frontend-bkt --recursive

echo "Deleting ECR images..."
IMAGE_DATA=$(aws ecr list-images --repository-name ${PROJECT_NAME}-ecr --region $AWS_REGION --query 'imageIds' --output json 2>/dev/null || echo "[]")
[[ "$IMAGE_DATA" != "[]" ]] && aws ecr batch-delete-image --repository-name ${PROJECT_NAME}-ecr --region $AWS_REGION --image-ids "$IMAGE_DATA" || echo "No images to delete"

echo "Destroying infrastructure..."
cd "$APP_DIR"
terraform destroy -auto-approve

echo "Infrastructure destroyed successfully!"
