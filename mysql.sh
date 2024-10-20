#!/bin/bash

MYSQL_CONFIG_FILE="/etc/mysql/my.cnf"

if [ ! -f "$MYSQL_CONFIG_FILE" ]; then
  MYSQL_CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
fi

if [ -f "$MYSQL_CONFIG_FILE" ]; then
  sudo sed -i 's/bind-address\s*=.*127.0.0.1/bind-address = 0.0.0.0/' "$MYSQL_CONFIG_FILE"
  echo "MySQL configuration changed: bind-address is now 0.0.0.0."
else
  echo "MySQL configuration file not found."
  exit 1
fi

sudo systemctl restart mysql
echo "MySQL service restarted."

if sudo ufw status | grep -q "3306.*DENY"; then
  sudo ufw allow 3306
  echo "Port 3306 is opened in the firewall."
else
  echo "Port 3306 is already open in the firewall."
fi

mysql -u root -p -e "
CREATE USER 'admindb'@'%' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON *.* TO 'admindb'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"

echo "User 'admindb' with root access has been successfully created."
