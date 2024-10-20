#!/bin/bash

read -p "Enter your domain (example: yourdomain.com): " domain

echo "Select connection options:"
echo "1. HTTPS (Let's Encrypt)"
echo "2. HTTP (without SSL)"
read -p "Enter your choice [1/2]: " opsi

sudo apt update
sudo apt install -y php8.1-fpm wget unzip

mkdir -p /var/www/phpmyadmin/tmp && cd /var/www/phpmyadmin

wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
tar xvzf phpMyAdmin-latest-english.tar.gz
mv phpMyAdmin-*-english/* /var/www/phpmyadmin
rm phpMyAdmin-latest-english.tar.gz

chown -R www-data:www-data /var/www/phpmyadmin
mkdir /var/www/phpmyadmin/config
chmod o+rw /var/www/phpmyadmin/config
cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config/config.inc.php
chmod o+w /var/www/phpmyadmin/config/config.inc.php

if [ "$opsi" -eq 1 ]; then
    sudo apt install -y certbot python3-certbot-nginx

    cat <<EOL | sudo tee /etc/nginx/sites-available/phpmyadmin.conf
server {
    listen 80;
    server_name $domain;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domain;

    root /var/www/phpmyadmin;
    index index.php;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;

    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

    sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
    sudo systemctl restart nginx
    sudo certbot --nginx -d $domain --non-interactive --agree-tos --email admin@$domain

elif [ "$opsi" -eq 2 ]; then
    cat <<EOL | sudo tee /etc/nginx/sites-available/phpmyadmin.conf
server {
    listen 80;
    server_name $domain;

    root /var/www/phpmyadmin;
    index index.php;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

    sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
    sudo systemctl restart nginx
else
    echo "Invalid selection, process terminated."
    exit 1
fi

echo "phpMyAdmin setup completed!"
