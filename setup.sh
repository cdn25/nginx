#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the package list
echo "Updating package list..."
sudo apt update

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx

# Enable Nginx to start on boot
echo "Enabling Nginx to start on boot..."
sudo systemctl enable nginx

# Start Nginx service
echo "Starting Nginx..."
sudo systemctl start nginx

# Print the status of Nginx
echo "Nginx status:"
sudo systemctl status nginx | grep Active

echo "Nginx installation completed!"

cp /root/nginx/domain.sh /usr/local/bin/domain.sh
