#!/bin/bash

set -e

# Set environment
PROJECT_NAME=StartTech
DISTRIBUTION_ID=

# Build the app
cd Client
npm run build

# Sync with S3 (invalidates CloudFront cache)
aws s3 sync dist/ s3://${PROJECT_NAME}-frontend/ --delete
aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths "/*"
