#!/bin/bash

set -e

# Update server
# sudo apt update && sudo apt upgrade -y
sudo yum update -y

# Install nginx
# sudo apt install nginx -y
sudo amazon-linux-extras install nginx1 -y

# Start nginx
sudo systemctl start nginx
