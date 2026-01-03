#!/bin/bash

set -e

# Update server
apt update && apt upgrade -y

# Install nginx
apt install nginx -y

# Start nginx
systemctl start nginx
