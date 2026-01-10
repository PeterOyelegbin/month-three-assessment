#!/bin/bash

set -euo pipefail

# Set environment
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../Client"
PROJECT_NAME=starttech
DISTRIBUTION_ID=E5U8IALRX8Q40

echo "Building the app..."
cd "$APP_DIR"
npm install
npm run build

echo "Syncing with S3..."
aws s3 sync dist/ s3://${PROJECT_NAME}-frontend-bkt/ --delete

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths "/*"

echo "Frontend application deployment completed successfully!"
