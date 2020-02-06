#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. nextcloud)?"
read USERNAME
echo "Updating OS................."
sleep 2;
sudo apt-get update

echo "Installing Nginx"
sleep 2;
sudo apt-get install nginx zip unzip pwgen -y
sudo snap install nextcloud

echo "Sit back and relax :) ......"
sleep 2;
cd /etc/nginx/sites-available/
sudo wget -O "$DOMAIN" https://raw.githubusercontent.com/echo-tango-pk22/echo-tango-prk22/master/nginx.conf
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/

echo "Setting up Cloudflare FULL SSL"
sleep 2;
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
sudo wget -O nginx.conf https://goo.gl/n8crcR
sudo mkdir /var/www/"$DOMAIN"
cd ~
sudo wget -O nextcloud.zip https://download.nextcloud.com/server/releases/latest.zip
sudo unzip nextcloud.zip
sudo rsync -avP /root/nextcloud/ /var/www/"$DOMAIN"/
sudo rm -rf nextcloud nextcloud.zip

echo "Nginx server installation completed"
sleep 2;
cd ~
sudo chown www-data:www-data -R /var/www/"$DOMAIN"
sudo systemctl restart nginx.service

echo "lets install php 7.2 and modules"
sleep 2;
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php7.2 php7.2-fpm -y
sudo apt-get -y install php7.2-json php7.2-curl php7.2-intl php7.2-gd php7.2-imap php7.2-readline php7.2-common php7.2-recode php7.2-mysql php7.2-cli php7.2-curl php7.2-mbstring php7.2-bcmath php7.2-mysql php7.2-opcache php7.2-zip php7.2-xml php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack  php7.2-soap

echo "Some php.ini Tweaks"
sleep 2;
sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 3600/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.2/fpm/php.ini


sudo sed -i "s/;clear_env = no/clear_env = no/" /etc/php/7.2/fpm/pool.d/www.conf
sudo sed -i "s/;opcache.enable=0/opcache.enable=1/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;opcache.interned_strings_buffer=4/opcache.interned_strings_buffer=8/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=10000/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;opcache.memory_consumption=64/opcache.memory_consumption=128/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/" /etc/php/7.2/fpm/php.ini

sudo systemctl restart php7.2-fpm.service

echo "Instaling MariaDB"
sleep 2;
sudo apt install mariadb-server mariadb-client php7.2-mysql -y
sudo systemctl restart php7.2-fpm.service
sudo mysql_secure_installation
PASS=`pwgen -s 14 1`

sudo mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Here is the database"
echo "Database:   $USERNAME"
echo "Username:   $USERNAME"
echo "Password:   $PASS"

echo "Installation & configuration succesfully finished.
Twitter: @TeamKloudboy
e-mail: support@kloudboy.com
Bye!"
