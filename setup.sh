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

# Check if the root user has an RSA key
echo "Checking for existing RSA key for root user..."
if [ ! -f "/root/.ssh/id_rsa" ]; then
    echo "No RSA key found for root user, generating one..."
    ssh-keygen -t rsa -b 4096 -f "/root/.ssh/id_rsa" -N "" # Empty passphrase
else
    echo "RSA key pair already exists for root user."
fi

# Ensure the .ssh directory exists and has correct permissions for root
echo "Setting up .ssh directory for root user..."
mkdir -p "/root/.ssh"
chmod 700 "/root/.ssh"

# Add the public key to authorized_keys for root user
echo "Adding public key to root's authorized_keys..."
cat "/root/.ssh/id_rsa.pub" >> "/root/.ssh/authorized_keys"

# Set permissions for root's authorized_keys
chmod 600 "/root/.ssh/authorized_keys"
chown -R root:root "/root/.ssh"

# Allow root login using key-based authentication
echo "Ensuring root login with key authentication is allowed..."
sudo sed -i 's/^PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

# Restart SSH service to apply the configuration changes
echo "Restarting SSH service to apply changes..."
sudo systemctl restart ssh

# Optionally, restart SSH service to ensure configuration changes are active
echo "SFTP login for root user set up using RSA key authentication."
