#!/bin/bash

# Exit immediately if a command fails
set -e

# Check if the user provided a domain name
#!/bin/bash

# Check if a domain name is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <domain_name>"
    exit 1
fi

# Variables
DOMAIN_NAME=$1
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_CONF_ENABLED="/etc/nginx/sites-enabled"
WEB_ROOT="/var/www/$DOMAIN_NAME"

# Check if the configuration file exists in sites-available
if [ ! -f "$NGINX_CONF_DIR/$DOMAIN_NAME" ]; then
    echo "Error: Configuration file $NGINX_CONF_DIR/$DOMAIN_NAME does not exist."
    exit 1
fi

# Check if the symbolic link already exists
if [ -e "$NGINX_CONF_ENABLED/$DOMAIN_NAME" ]; then
    echo "Symbolic link for $DOMAIN_NAME already exists. Skipping."
else
    ln -s "$NGINX_CONF_DIR/$DOMAIN_NAME" "$NGINX_CONF_ENABLED/$DOMAIN_NAME"
    echo "Symbolic link created for $DOMAIN_NAME."
fi

# Create a web root directory
echo "Creating web root directory at $WEB_ROOT..."
sudo mkdir -p "$WEB_ROOT"
sudo chown -R $USER:$USER "$WEB_ROOT"
sudo chmod -R 755 "$WEB_ROOT"

# Create a sample index.html file
echo "Creating sample index.html file..."
echo "<!DOCTYPE html>
<html>
<head>
    <title>Welcome to $DOMAIN_NAME!</title>
</head>
<body>
    <h1>Success! The $DOMAIN_NAME server block is working!</h1>
</body>
</html>" | sudo tee "$WEB_ROOT/index.html"

# Create the Nginx server block configuration file
CONFIG_FILE="$NGINX_CONF_DIR/$DOMAIN_NAME"
echo "Creating Nginx server block configuration file at $CONFIG_FILE..."
sudo bash -c "cat > $CONFIG_FILE" <<EOL
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;

    root $WEB_ROOT;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}

EOL

# Enable the configuration
echo "Enabling the server block configuration..."
sudo ln -s "$CONFIG_FILE" "$NGINX_CONF_ENABLED"

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx to apply changes
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "Domain $DOMAIN_NAME has been configured and is ready to use."

