#!/bin/bash

set -euo pipefail

# Update server
sudo yum update -y

# Install dependencies
sudo amazon-linux-extras install -y docker
sudo yum install -y amazon-cloudwatch-agent jq

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user

# Create application directory
sudo mkdir -p /app
sudo chown ec2-user:ec2-user /app

# Write CloudWatch agent config
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
sudo tee amazon-cloudwatch-agent.json > /dev/null <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "${LOG_GROUP_NAME}",
            "log_stream_name": "{instance_id}/docker",
            "timezone": "UTC"
          },
          {
            "file_path": "/app/application.log",
            "log_group_name": "${LOG_GROUP_NAME}",
            "log_stream_name": "{instance_id}/application",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["*"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

sudo mv amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/

# Start CloudWatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
