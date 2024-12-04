#!/bin/bash

# Check if domain name is provided
if [ -z "$1" ]; then
    echo "Usage: domain.sh <domain-name>"
    exit 1
fi

DOMAIN=$1
WEB_ROOT="/var/www/$DOMAIN"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
NGINX_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"

# Create web root directory
if [ ! -d "$WEB_ROOT" ]; then
    sudo mkdir -p $WEB_ROOT
    sudo chown -R $USER:$USER $WEB_ROOT
    echo "<?php echo 'Hello from $DOMAIN'; ?>" > $WEB_ROOT/index.php
    echo "Web root created at $WEB_ROOT"
else
    echo "Web root already exists at $WEB_ROOT"
fi

# Create NGINX configuration
if [ ! -f "$NGINX_CONF" ]; then
    cat <<EOL | sudo tee $NGINX_CONF
server {
    listen 80;
    server_name $DOMAIN;

    root $WEB_ROOT;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

    sudo ln -s $NGINX_CONF $NGINX_ENABLED
    echo "NGINX configuration created and enabled for $DOMAIN"
else
    echo "NGINX configuration already exists for $DOMAIN"
fi

# Test and reload NGINX
sudo nginx -t && sudo systemctl reload nginx
echo "NGINX reloaded successfully!"
