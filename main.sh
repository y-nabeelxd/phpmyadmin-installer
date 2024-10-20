#!/bin/bash

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}############################################################${NC}"
echo -e "${CYAN}#                                                          #${NC}"
echo -e "${CYAN}#                   Welcome to PHPMyAdmin Installer                #${NC}"
echo -e "${CYAN}#                  Script Created by NabeelXD           #${NC}"
echo -e "${CYAN}#                                                          #${NC}"
echo -e "${CYAN}############################################################${NC}"
echo

echo -e "${YELLOW}Choose an option:${NC}"
echo -e "${GREEN}0) Install phpMyAdmin with a domain${NC}"
echo -e "${GREEN}1) Install phpMyAdmin with a domain behind Cloudflare proxy${NC}"
echo -e "${GREEN}2) Install phpMyAdmin without a domain${NC}"
echo -e "${GREEN}3) Install phpMyAdmin and MySQL with a domain${NC}"
echo -e "${GREEN}4) Install phpMyAdmin and MySQL with a domain behind Cloudflare proxy${NC}"
echo -e "${GREEN}5) Install phpMyAdmin and MySQL without a domain${NC}"
echo -e "${GREEN}6) Remove Cloudflare proxy settings${NC}"
echo -e "${GREEN}7) Uninstall phpMyAdmin${NC}"
echo -e "${GREEN}8) Cancel or Exit${NC}"
echo
read -p "Enter your choice [0-8]: " choice

install_with_domain() {
    echo -e "${CYAN}Starting installation with domain...${NC}"
    sleep 2

    sudo apt update -y
    sudo apt upgrade -y

    sudo apt install -y nginx php-fpm php-mysql wget unzip certbot python3-certbot-nginx

    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -O /tmp/phpmyadmin.zip

    sudo unzip /tmp/phpmyadmin.zip -d /usr/share/
    sudo mv /usr/share/phpMyAdmin-5.2.1-all-languages /usr/share/pma

    sudo chown -R www-data:www-data /usr/share/pma
    sudo chmod -R 755 /usr/share/pma

    read -p "Please enter your domain: " domain

    sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $domain;

    root /var/www/html;
    index index.php index.htm index.nginx-debian.html;

    location / {
        rewrite ^/$ /pma permanent;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # phpMyAdmin configuration
    location /pma {
        alias /usr/share/pma;
        index index.php;
        try_files \$uri \$uri/ =404;
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            include fastcgi_params;
        }
    }
}
EOF

    sudo systemctl restart nginx

    sudo certbot --nginx -d $domain

    rm -rf /var/log/apt/*

    echo -e "${GREEN}phpMyAdmin has been installed and is accessible at https://$domain/pma${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
}

install_without_domain() {
    echo -e "${CYAN}Starting installation without domain...${NC}"
    sleep 2

    sudo apt update -y
    sudo apt upgrade -y

    sudo apt install -y nginx php-fpm php-mysql wget unzip

    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -O /tmp/phpmyadmin.zip

    sudo unzip /tmp/phpmyadmin.zip -d /usr/share/
    sudo mv /usr/share/phpMyAdmin-5.2.1-all-languages /usr/share/pma

    sudo chown -R www-data:www-data /usr/share/pma
    sudo chmod -R 755 /usr/share/pma

    ip_vps=$(curl -s http://checkip.amazonaws.com)

    sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $ip_vps;

    root /var/www/html;
    index index.php index.htm index.nginx-debian.html;

    location / {
        rewrite ^/$ /pma permanent;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # phpMyAdmin configuration
    location /pma {
        alias /usr/share/pma;
        index index.php;
        try_files \$uri \$uri/ =404;
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            include fastcgi_params;
        }
    }
}
EOF

    sudo systemctl restart nginx

    rm -rf /var/log/apt/*

    echo -e "${GREEN}phpMyAdmin has been installed and is accessible at http://$ip_vps/pma${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
}

install_with_mysql_domain() {
    echo -e "${CYAN}Starting installation with domain...${NC}"
    sleep 2

    sudo apt update -y
    sudo apt upgrade -y

    sudo apt install -y nginx php-fpm php-mysql mysql-server wget unzip certbot python3-certbot-nginx

    sudo mysql_secure_installation

    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -O /tmp/phpmyadmin.zip

    sudo unzip /tmp/phpmyadmin.zip -d /usr/share/
    sudo mv /usr/share/phpMyAdmin-5.2.1-all-languages /usr/share/pma

    sudo chown -R www-data:www-data /usr/share/pma
    sudo chmod -R 755 /usr/share/pma

    read -p "Please enter your domain: " domain

    sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $domain;

    root /var/www/html;
    index index.php index.htm index.nginx-debian.html;

    location / {
        rewrite ^/$ /pma permanent;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # phpMyAdmin configuration
    location /pma {
        alias /usr/share/pma;
        index index.php;
        try_files \$uri \$uri/ =404;
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            include fastcgi_params;
        }
    }
}
EOF

    sudo systemctl restart nginx

    sudo certbot --nginx -d $domain

    rm -rf /var/log/apt/*

    echo -e "${GREEN}phpMyAdmin and MySQL have been installed and are accessible at https://$domain/pma${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
}

install_without_mysql_domain() {
    echo -e "${CYAN}Starting installation without domain...${NC}"
    sleep 2

    sudo apt update -y
    sudo apt upgrade -y

    sudo apt install -y nginx php-fpm php-mysql mysql-server wget unzip

    sudo mysql_secure_installation

    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -O /tmp/phpmyadmin.zip

    sudo unzip /tmp/phpmyadmin.zip -d /usr/share/
    sudo mv /usr/share/phpMyAdmin-5.2.1-all-languages /usr/share/pma

    sudo chown -R www-data:www-data /usr/share/pma
    sudo chmod -R 755 /usr/share/pma

    ip_vps=$(curl -s http://checkip.amazonaws.com)

    sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $ip_vps;

    root /var/www/html;
    index index.php index.htm index.nginx-debian.html;

    location / {
        rewrite ^/$ /pma permanent;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # phpMyAdmin configuration
    location /pma {
        alias /usr/share/pma;
        index index.php;
        try_files \$uri \$uri/ =404;
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            include fastcgi_params;
        }
    }
}
EOF

    sudo systemctl restart nginx

    rm -rf /var/log/apt/*

    echo -e "${GREEN}phpMyAdmin and MySQL have been installed and are accessible at http://$ip_vps/pma${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
}

uninstall_phpmyadmin() {
    echo -e "${CYAN}Starting uninstallation of phpMyAdmin...${NC}"
    sleep 2

    sudo rm -rf /usr/share/pma
    sudo rm /etc/nginx/sites-available/default
    sudo rm /etc/nginx/sites-enabled/default

    sudo systemctl restart nginx

    echo -e "${GREEN}phpMyAdmin has been uninstalled successfully!${NC}"
}

install_with_domain_cf_proxy() {
    echo -e "${CYAN}Starting installation with domain and Cloudflare proxy...${NC}"
    sleep 2

    install_with_domain

    sudo tee -a /etc/nginx/sites-available/default > /dev/null <<EOF

# Cloudflare Proxy Configuration
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 131.0.72.0/22;
real_ip_header CF-Connecting-IP;
EOF

    sudo systemctl restart nginx

    echo -e "${GREEN}phpMyAdmin with Cloudflare proxy has been installed and is accessible at https://$domain/pma${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
}

install_with_mysql_domain_cf_proxy() {
    echo -e "${CYAN}Starting installation with domain, MySQL, and Cloudflare proxy...${NC}"
    sleep 2

    install_with_mysql_domain

    sudo tee -a /etc/nginx/sites-available/default > /dev/null <<EOF

# Cloudflare Proxy Configuration
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 131.0.72.0/22;
real_ip_header CF-Connecting-IP;
EOF

    sudo systemctl restart nginx

    echo -e "${GREEN}phpMyAdmin with MySQL and Cloudflare proxy has been installed and is accessible at https://$domain/pma${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
}

remove_cf_proxy() {
    echo -e "${CYAN}Removing Cloudflare proxy settings...${NC}"
    sleep 2

    sudo sed -i '/# Cloudflare Proxy Configuration/,+18d' /etc/nginx/sites-available/default

    sudo systemctl restart nginx

    echo -e "${GREEN}Cloudflare proxy settings have been removed!${NC}"
}

case $choice in
    0)
        install_with_domain
        ;;
    1)
        install_with_domain_cf_proxy
        ;;
    2)
        install_without_domain
        ;;
    3)
        install_with_mysql_domain
        ;;
    4)
        install_with_mysql_domain_cf_proxy
        ;;
    5)
        install_without_mysql_domain
        ;;
    6)
        remove_cf_proxy
        ;;
    7)
        uninstall_phpmyadmin
        ;;
    8)
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option! Please choose a valid option.${NC}"
        ;;
esac
