#!/bin/bash

set -euo pipefail

PROJECT_NAME="starttech"
AWS_REGION="us-east-1"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

TF_STATE_BUCKET_NAME="${PROJECT_NAME}-${AWS_ACCOUNT_ID}-tf-state"
TF_LOCK_DB_NAME="${PROJECT_NAME}-tf-locks"

echo "Creating S3 bucket for Terraform remote state..."
aws s3api create-bucket --bucket "$TF_STATE_BUCKET_NAME" --region "$AWS_REGION"

echo "Blocking public access on bucket..."
aws s3api put-public-access-block --bucket "$TF_STATE_BUCKET_NAME" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Enabling versioning..."
aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "Enabling encryption..."
aws s3api put-bucket-encryption --bucket "$TF_STATE_BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table --table-name "$TF_LOCK_DB_NAME" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region "$AWS_REGION"

echo "✅ Terraform remote state setup completed successfully!"
echo "S3 Bucket: $TF_STATE_BUCKET_NAME"
echo "DynamoDB Table: $TF_LOCK_DB_NAME"
