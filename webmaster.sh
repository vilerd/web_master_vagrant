#!/bin/bash

cat baner

echo -e "\e[1;36m~~~Please! Read before installing README!~~~\e[0m"

echo -n -e "\e[1;32mEnter SSH port:\e[0m"
read -s SSH
echo
echo -n -e "\e[1;32mEnter password for root user mysql:\e[0m"
read -s MYSQL
echo
echo -n -e "\e[1;32mEnter name wordpress database:\e[0m"
read -s BASENAME
echo
echo -n -e "\e[1;32mEnter name user database:\e[0m"
read -s USERNAME
echo
echo -n -e "\e[1;32mEnter password for database:\e[0m"
read -s PASSWD
echo

echo -e "\e[1;34mSSH port ='$SSH'\e[0m"
echo -e "\e[1;34mMySQL-password ='$MYSQL'\e[0m"
echo -e "\e[1;34mName wordpress database = '$BASENAME'\e[0m"
echo -e "\e[1;34mName user database = '$USERNAME'\e[0m"
echo -e "\e[1;34mPassword database = '$PASSWD'\e[0m"

echo "Are the entered data correct? (y/N) "
read item
case "$item" in
    y|Y) echo -e "\e[1;32mGO!\e[0m"
        ;;
    n|N) echo -e "\e[1;31mGoodbye!\e[0m" && exit
        exit 0
        ;;
    *) echo -e "\e[1;31mError!!! Incorrect choice! Try again!\e[0m" && exit
        ;;
esac

mkdir /tmp/bootlog

echo -e "\e[1;34mLogging is performed in /tmp/bootlog/logboot.txt\e[0m"
echo "Start" >> /tmp/bootlog/logboot.txt
echo -e "\e[1;32mDirectory for logging created!\e[0m"

ADDRESS="google.com.ua"
if ping -c 1 -s 1 -W 1 $ADDRESS
then
echo -e "\e[1;32mConnection OK!\e[0m"
echo "Network OK!" >> /tmp/bootlog/logboot.txt
else
echo -e "\e[1;31mConnection Lost!!!\e[0m"
echo -e "\e[1;33mCheck network connection!\e[0m"
echo "Network faill" >> /tmp/bootlog/logboot.txt
exit
fi

sudo apt-get update && apt-get upgrade -y
echo -e "\e[1;32mSystem updated\e[0m"
echo "System updated" >> /tmp/bootlog/logboot.txt


sudo apt-get install ssh -y
sed -i '/Port 22/c\Port '$SSH'' /etc/ssh/sshd_config
sed -i '/#ListenAddress 0.0.0.0/c\ListenAddress 0.0.0.0' /etc/ssh/sshd_config
echo -e "\e[1;32mThe SSH package is installed The connection port is specified\e[0m"
/etc/init.d/ssh restart
echo "Install SSH Port=$SSH" >> /tmp/bootlog/logboot.txt

sudo mv demonforiptables /etc/init.d/iptables
sudo chmod +x /etc/init.d/iptables
sudo mkdir /etc/iptables.d
sed -i '/-A PREROUTING -p tcp --dport 22 -j REDIRECT --to-ports 2202/c\-A PREROUTING -p tcp --dport 22 -j REDIRECT --to-ports '$SSH'' iptablesactive
sleep 1s
sudo  mv iptablesactive /etc/iptables.d/active
sleep 1s
sudo mv iptablesinactive /etc/iptables.d/inactive
sleep 1s
/etc/init.d/iptables start
iptables-save
echo "#! /sbin/iptables-restore" > /etc/network/if-up.d/iptables-rules
iptables-save >> /etc/network/if-up.d/iptables-rules
sudo chmod +x /etc/network/if-up.d/iptables-rules
sudo ls -lA /etc/network/if-up.d/ipt*
echo -e "\e[1;32mIPtables active\e[0m"
echo "Iptables active!" >> /tmp/bootlog/logboot.txt

sudo apt-get install fail2ban -y
sed -i '/port     = 2202/c\port     = '$SSH'' /tmp/web_master/fail2ban2
sed -i '/action   = iptables/c\action   = iptables[name=SSH, port='$SSH', protocol=tcp]' /tmp/web_master/fail2ban2
mv fail2ban2 /etc/fail2ban/jail.local
/etc/init.d/fail2ban restart
echo -e "\e[1;32mFail2ban istall\e[0m"
echo "Fail2ban install | Fail2ban active!" >> /tmp/bootlog/logboot.txt

sudo apt-get install vim -y
echo -e "\e[1;32mInstall vim\e[0m"
echo "Install vim" >> /tmp/bootlog/logboot.txt

sudo apt-get install mc -y
echo -e "\e[1;32mInstall mc\e[0m"
echo "Install mc" >> /tmp/bootlog/logboot.txt

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

echo -e "\e[1;34mSSH port ='$SSH'\e[0m"
echo -e "\e[1;34mMySQL-password ='$MYSQL'\e[0m"
echo -e "\e[1;34mName wordpress database = '$BASENAME'\e[0m"
echo -e "\e[1;34mName user database = '$USERNAME'\e[0m"
echo -e "\e[1;34mPassword database = '$PASSWD'\e[0m"

echo "SSH port = $SSH" >> /tmp/bootlog/logboot.txt
echo "MySQL-pass = $MYSQL" >> /tmp/bootlog/logboot.txt
echo "Name wordpress database = $BASENAME" >> /tmp/bootlog/logboot.txt
echo "Name user database = $USERNAME" >> /tmp/bootlog/logboot.txt
echo "Password database = $PASSWD" >> /tmp/bootlog/logboot.txt

echo "Created by ~vilerd©~  | Version 2.0" >> /tmp/bootlog/logboot.txt
echo -e "\e[1;33mCreated by ~vilerd©~ | Version 2.0\e[0m"
echo -e "\e[1;33m~~~BYE~~~\e[0m"
