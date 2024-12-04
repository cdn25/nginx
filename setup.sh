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

# Generate RSA SSH key pair if not already exists
echo "Checking for existing RSA key pair..."
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "No RSA key found, generating one..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" # Empty passphrase
else
    echo "RSA key pair already exists."
fi

# Ensure the .ssh directory exists and has correct permissions
echo "Setting up .ssh directory..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Add the public key to authorized_keys
echo "Adding public key to authorized_keys..."
cat "$HOME/.ssh/id_rsa.pub" >> "$HOME/.ssh/authorized_keys"

# Set permissions for authorized_keys
chmod 600 "$HOME/.ssh/authorized_keys"
chown -R $USER:$USER "$HOME/.ssh"

# Optionally, restart SSH service (ensure SSH is installed and running)
echo "Restarting SSH service to apply changes..."
sudo systemctl restart ssh

echo "SFTP login setup completed with RSA key authentication!"
