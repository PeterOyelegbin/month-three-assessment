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
INSTANCE_IDS=("i-0abc123456789def0" "i-0def123456789abc0")

REDIS_ENDPOINT="starttech-redis.d2jdsa.ng.0001.use1.cache.amazonaws.com"

# SSH_OPTS="-o StrictHostKeyChecking=accept-new"
# KEY_PAIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform/starttech-key.pem"
# SERVER_USERNAME="ec2-user"
# SERVERS=("44.201.194.182" "44.203.205.149") # Replace with real IPs

# ********** Build and push Docker image **********
echo "Building Docker image..."
cd "$APP_DIR"
docker build -t "$DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG" .

echo "Pushing image to Docker Hub..."
docker push "$DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG"


# # ********** Deploy to remote servers **********
# for SERVER in "${SERVERS[@]}"; do
#     echo "Copying .env to $SERVER..."
#     scp $SSH_OPTS -i "$KEY_PAIR" "$APP_DIR/.env" \
#         "$SERVER_USERNAME@$SERVER:/app/.env"

#     echo "Deploying to $SERVER..."
#     ssh $SSH_OPTS -i "$KEY_PAIR" -o UserKnownHostsFile="$HOME/.ssh/known_hosts" \
#     "$SERVER_USERNAME@$SERVER" bash -s <<EOF
#         set -euo pipefail

#         echo "Pulling Docker image..."
#         sudo docker pull $DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG

#         echo "Stopping old container if exists..."
#         sudo docker rm -f backend || true

#         echo "Testing redis endpiont..."
#         redis-cli -h $REDIS_ENDPOINT -p 6379 PING

#         echo "Stopping nginx..."
#         sudo systemctl stop nginx || true

#         echo "Running new container..."
#         sudo docker run -d --name backend --restart always -p 80:8080 \
#             -v /app/.env:/app/.env \
#             -v /app/application.log:/app/application.log \
#             $DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG

#         echo "Deployment on $SERVER completed!"
# EOF
# done



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
