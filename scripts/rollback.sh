#!/bin/bash

set -euo pipefail

# Set environment
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform"

echo "Delete deployed frontend content in the S3 bucket..."
aws s3 rm s3://starttech-frontend-bkt --recursive

echo "Destroying infrastructure..."
cd "$APP_DIR"
terraform destroy -auto-approve

echo "Infrastructure destroyed successfully!"
