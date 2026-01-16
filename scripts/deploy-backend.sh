#!/bin/bash

set -euo pipefail

# ********** Local build settings **********
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../Server/MuchToDo"
DOCKER_REPO_NAME="peteroyelegbin"
IMAGE_NAME="starttech-backend"
IMAGE_TAG="latest"

# ********** AWS / SSM settings **********
AWS_REGION="us-east-1"
SSM_DOCUMENT="AWS-RunShellScript"

# Use INSTANCE IDS, not IPs
INSTANCE_IDS=("i-00555cb9ce19605b3" "i-0965728739f73867e")

REDIS_ENDPOINT="starttech-redis.c7x96g.ng.0001.use1.cache.amazonaws.com"


# ********** Build and push Docker image **********
echo "Building Docker image..."
cd "$APP_DIR"
docker build -t "$DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG" .

echo "Pushing image to Docker Hub..."
docker push "$DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG"


# ********** Read .env file **********
ENV_CONTENT=$(sed 's/"/\\"/g' "$APP_DIR/.env")


# ********** Deploy using SSM **********
for INSTANCE_ID in "${INSTANCE_IDS[@]}"; do
  echo "Deploying to instance $INSTANCE_ID via SSM..."

  aws ssm send-command --region "$AWS_REGION" --document-name "$SSM_DOCUMENT" \
    --targets "Key=instanceids,Values=$INSTANCE_ID" \
    --comment "Deploy backend container" \
    --parameters commands="[
      \"set -euo pipefail\",
      \"echo '$ENV_CONTENT' | sudo tee /app/.env\",
      \"sudo docker pull $DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG\",
      \"sudo docker rm -f backend || true\",
      \"echo 'Testing Redis endpoint'\",
      \"redis-cli -h $REDIS_ENDPOINT -p 6379 PING\",
      \"sudo systemctl stop nginx || true\",
      \"sudo docker run -d --name backend --restart always -p 80:8080 \
         -v /app/.env:/app/.env \
         -v /app/application.log:/app/application.log \
         $DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG\"
    ]" \
    --output text
done

echo "Backend application deployed successfully via SSM!"
