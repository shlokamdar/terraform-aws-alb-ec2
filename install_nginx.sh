#!/bin/bash
set -xe

# Send all output to logs for debugging
exec > /var/log/user-data.log 2>&1

echo "===== User data started at $(date) ====="

# Update system
yum update -y

# Install nginx
yum install -y nginx

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Simple test page
echo "<h1>Nginx installed via EC2 User Data </h1>" > /usr/share/nginx/html/index.html

echo "===== User data completed at $(date) ====="
