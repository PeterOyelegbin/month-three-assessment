#!/bin/bash

set -euo pipefail

# Set environment
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../Server/MuchToDo"
DOCKER_REPO_NAME="peteroyelegbin"
IMAGE_NAME="starttech-backend"
IMAGE_TAG="latest"
SSH_OPTS="-o StrictHostKeyChecking=accept-new"
KEY_PAIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform/start-tech-key.pem"
SERVERS=("54.172.248.25" "44.211.245.191") # Replace with real IPs
SERVER_USERNAME="ec2-user"


# ********** Build and push Docker image **********
echo "Building Docker image..."
cd "$APP_DIR"
docker build -t "$DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG" .

echo "Pushing image to Docker Hub..."
docker push "$DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG"


# ********** Deploy to remote servers **********
for SERVER in "${SERVERS[@]}"; do
    echo "Copying .env to $SERVER..."
    scp $SSH_OPTS -i "$KEY_PAIR" "$APP_DIR/.env" \
        "$SERVER_USERNAME@$SERVER:/app/.env"

    echo "Deploying to $SERVER..."
    ssh $SSH_OPTS -i "$KEY_PAIR" -o UserKnownHostsFile="$HOME/.ssh/known_hosts" \
    "$SERVER_USERNAME@$SERVER" bash -s <<EOF
        set -euo pipefail

        echo "Pulling Docker image..."
        sudo docker pull $DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG

        echo "Stopping old container if exists..."
        sudo docker rm -f backend || true

        echo "Running new container..."
        sudo docker run -d --name backend --restart always -p 80:8080 \
            -v /app/.env:/app/.env \
            -v /app/application.log:/app/application.log \
            $DOCKER_REPO_NAME/$IMAGE_NAME:$IMAGE_TAG

        echo "Deployment on $SERVER completed!"
EOF
done

echo "Backend application deployed successfully on all servers!"
