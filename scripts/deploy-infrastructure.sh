#!/bin/bash

set -euo pipefail

# Set environment
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform"

echo "Initializing Terraform..."
cd "$APP_DIR"
terraform init

echo "Running Terraform plan..."
terraform plan -out=tfplan

echo "Applying Terraform plan..."
terraform apply tfplan

terraform output -json > outputs.json

echo "Infrastructure deployment completed successfully!"
