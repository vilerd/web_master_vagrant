#!/bin/bash

MYSQL = 1993
BASENAME = wordpress
USERNAME = vilerd
PASSWD = 1993

echo -e "\e[1;34mMySQL-password ='$MYSQL'\e[0m"
echo -e "\e[1;34mName wordpress database = '$BASENAME'\e[0m"
echo -e "\e[1;34mName user database = '$USERNAME'\e[0m"
echo -e "\e[1;34mPassword database = '$PASSWD'\e[0m"

mkdir /tmp/bootlog

echo -e "\e[1;34mLogging is performed in /tmp/bootlog/logboot.txt\e[0m"
echo "Start" >> /tmp/bootlog/logboot.txt
echo -e "\e[1;32mDirectory for logging created!\e[0m"


sudo apt-get update && apt-get upgrade -y

sudo apt-get install vim -y
echo -e "\e[1;32mInstall vim\e[0m"
echo "Install vim" >> /tmp/bootlog/logboot.txt

sudo apt-get install ntp -y
echo -e "\e[1;32mInstall ntp\e[0m"
echo "Install ntp" >> /tmp/bootlog/logboot.txt

sudo apt install curl -y
echo -e "\e[1;32mInstall curl\e[0m"
echo "Install curl" >> /tmp/bootlog/logboot.txt

sudo apt install mycli -y
echo -e "\e[1;32mInstall mycli\e[0m"
echo "Install mycli" >> /tmp/bootlog/logboot.txt

sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password '$MYSQL''
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password '$MYSQL''
sudo apt-get install -y mysql-server mysql-client
echo -e "\e[1;32mInstall MySQL\e[0m"
echo "Install MySQL" >> /tmp/bootlog/logboot.txt

mysql -u root -p$MYSQL <<EOF
CREATE DATABASE $BASENAME;
CREATE USER $USERNAME@localhost IDENTIFIED BY '$PASSWD';
grant all privileges on $BASENAME.* to '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
EOF
echo -e "\e[1;32mDatabase WordPress created\e[0m"

sudo apt install nginx -y
echo -e "\e[1;32mInstall nginx\e[0m"
echo "Install nginx" >> /tmp/bootlog/logboot.txt

sudo apt install -y php7.0-fpm php7.0-mysql php7.0-mbstring php7.0-xml php7.0-curl php7.0-zip php7.0-gd php7.0-xmlrpc
sudo cp  /etc/php/7.0/fpm/php.ini  /etc/php/7.0/fpm/php.ini.orig
sudo cp  /etc/php/7.0/fpm/pool.d/www.conf  /etc/php/7.0/fpm/pool.d/www.conf.orig
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/'  /etc/php/7.0/fpm/php.ini
sudo sed -i 's|listen = /run/php/php7.0-fpm.sock|listen =127.0.0.1:9000|g' /etc/php/7.0/fpm/pool.d/www.conf
echo -e "\e[1;32mInstall php modules\e[0m"
echo "Install php modules" >> /tmp/bootlog/logboot.txt

sudo rm /var/www/html/index.nginx-debian.html
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

sudo mv virtualhostwp /etc/nginx/sites-available/wordpress
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

wget http://wordpress.org/latest.tar.gz -q -P /tmp/boot
tar xzfC /tmp/boot/latest.tar.gz /tmp/boot
sudo cp /tmp/boot/wordpress/wp-config-sample.php  /tmp/boot/wordpress/wp-config.php
echo -e "\e[1;32mDownload Wordpress and its preparation\e[0m"
echo "Download Wordpress and its preparation" >> /tmp/bootlog/logboot.txt

sudo sed -i "s/database_name_here/$BASENAME/"  /tmp/boot/wordpress/wp-config.php
sudo sed -i "s/username_here/$USERNAME/"       /tmp/boot/wordpress/wp-config.php
sudo sed -i "s/password_here/$PASSWD/"   /tmp/boot/wordpress/wp-config.php
sudo sed -i "s/wp_/wnotp_/"               /tmp/boot/wordpress/wp-config.php

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
sudo printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /tmp/boot/wordpress/wp-config.php
sudo cp -a /tmp/boot/wordpress/. /var/www/html/
sudo chown -R www-data: /var/www/html
echo -e "\e[1;32mWordpress prepared\e[0m"
echo "Wordpress prepared" >> /tmp/bootlog/logboot.txt

/etc/init.d/nginx restart
/etc/init.d/php7.0-fpm restart
echo -e "\e[1;32mnginx & php restart\e[0m"
echo "nginx & php restart" >> /tmp/bootlog/logboot.txt

wite=`curl http://smart-ip.net/myip | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"`
echo -e "\e[1;36mYour external IP=$wite\e[0m"
localip=`ip route show | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"`
echo "$localip" >> /tmp/boot/ip.txt
ip=`cat /tmp/boot/ip.txt | sed -n '3p' | awk '{print $1}'`
echo -e "\e[1;36mYour local IP=$ip\e[0m"

rm -r /tmp/boot
echo -e "\e[1;31mGarage remove\e[0m"
echo "Garbage remove" >> /tmp/bootlog/logboot.txt

echo "MySQL-pass = $MYSQL" >> /tmp/bootlog/logboot.txt
echo "Name wordpress database = $BASENAME" >> /tmp/bootlog/logboot.txt
echo "Name user database = $USERNAME" >> /tmp/bootlog/logboot.txt
echo "Password database = $PASSWD" >> /tmp/bootlog/logboot.txt

echo "Created by ~vilerd©~  | Version 2.0" >> /tmp/bootlog/logboot.txt
echo -e "\e[1;33mCreated by ~vilerd©~ | Version 2.0\e[0m"
echo -e "\e[1;33m~~~BYE~~~\e[0m"
