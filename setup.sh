#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install NGINX
echo "Installing NGINX..."
sudo apt install nginx -y

# Install PHP and required extensions
echo "Installing PHP and extensions..."
sudo apt install php-fpm php-cli php-mysql php-curl php-xml php-mbstring -y

# Start and enable NGINX service
echo "Starting and enabling NGINX..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Copy domain.sh to /usr/local/bin/
echo "Copying domain.sh to /usr/local/bin/..."
cp /root/nginx/domain.sh /usr/local/bin/domain.sh
chmod +x /usr/local/bin/domain.sh

echo "domain.sh copied and made executable at /usr/local/bin/"

# Reload NGINX service
echo "Reloading NGINX service..."
sudo systemctl reload nginx

echo "Setup complete! NGINX and PHP installed, and domain.sh is ready to use."
