#!/bin/bash

set -e

# Update server
yum update -y

# Install dependencies
amazon-linux-extras enable nginx1 redis6
amazon-linux-extras install -y docker
yum install -y amazon-ssm-agent nginx amazon-cloudwatch-agent jq redis

# Enable and start SSM agent
systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Start Nginx and Docker
systemctl start nginx
systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user

# Create application directory
mkdir -p /app
chown ec2-user:ec2-user /app

# Write CloudWatch agent config
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOF
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

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
