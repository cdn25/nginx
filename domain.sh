#!/bin/bash

# Define the function to add a domain
add_domain() {
  DOMAIN=$1

  if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 domain.com"
    exit 1
  fi

  # Define directories
  ROOT_DIR="/var/www/$DOMAIN"
  SITES_AVAILABLE="/etc/nginx/sites-available/$DOMAIN"
  SITES_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"

  # Check if the domain already has a configuration
  if [ -f "$SITES_AVAILABLE" ]; then
    echo "Domain $DOMAIN is already configured. Updating site configuration only..."
  else
    # Ensure the root directory exists
    if [ ! -d "$ROOT_DIR" ]; then
      echo "Directory $ROOT_DIR does not exist. Creating it..."
      mkdir -p "$ROOT_DIR"
    else
      echo "Directory $ROOT_DIR already exists. Skipping creation."
    fi

    # Set permissions for the directory
    echo "Setting permissions for $ROOT_DIR..."
    chown -R www-data:www-data "$ROOT_DIR"
    chmod -R 755 "$ROOT_DIR"

    # Create Nginx site configuration
    echo "Creating Nginx configuration for $DOMAIN..."
    cat <<EOF >"$SITES_AVAILABLE"
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $ROOT_DIR;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
  fi

  # Enable site
  echo "Enabling site $DOMAIN..."
  ln -sf "$SITES_AVAILABLE" "$SITES_ENABLED"

  # Test Nginx configuration
  echo "Testing Nginx configuration..."
  nginx -t
  if [ $? -eq 0 ]; then
    echo "Reloading Nginx..."
    systemctl reload nginx
    echo "Domain $DOMAIN is set up successfully!"
  else
    echo "Error in Nginx configuration. Check the configuration file."
    exit 1
  fi
}

# Main script execution
if [ $# -eq 0 ]; then
  echo "Usage: $0 domain.com"
  exit 1
fi

for DOMAIN in "$@"; do
  add_domain "$DOMAIN"
done
