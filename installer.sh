#!/bin/bash
# main script

info "Provision-script user: `whoami`"

export DEBIAN_FRONTEND=noninteractive

info "Prepare root password for MySQL"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password \"''\""
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password \"''\""
echo "Done!"

info "Update to php7.1"
add-apt-repository ppa:ondrej/php

info "Add ElasticSearch source"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list

info "Update OS software"
apt-get update
apt-get upgrade -y

info "Install Redis-server"
apt-get install redis-server -y

info "Install supervisor"
apt-get install supervisor -y

info "Install JDK"
apt-get install default-jdk -y

info "Install ElasticSearch"
apt-get install apt-transport-https
apt-get install elasticsearch -y
sed -i 's/-Xms1g/-Xms64m/' /etc/elasticsearch/jvm.options
sed -i 's/-Xmx1g/-Xmx64m/' /etc/elasticsearch/jvm.options
sed -i 's/network.host: 192.168.0.1/network.host: 192.168.0.1/' /etc/elasticsearch/elasticsearch.yml
systemctl daemon-reload
systemctl enable elasticsearch.service

info "Install additional software"
apt-get install -y php7.1-curl php7.1-cli php7.1-intl php7.1-mysqlnd php7.1-gd php7.1-fpm php7.1-mbstring php7.1-xml unzip nginx mysql-server-5.7 php.xdebug

info "Configure MySQL"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -uroot <<< "CREATE USER 'root'@'%' IDENTIFIED BY ''"
mysql -uroot <<< "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'"
mysql -uroot <<< "DROP USER 'root'@'localhost'"
mysql -uroot <<< "FLUSH PRIVILEGES"
echo "Done!"

info "Configure PHP-FPM"
sed -i 's/user = www-data/user = vagrant/g' /etc/php/7.1/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = vagrant/g' /etc/php/7.1/fpm/pool.d/www.conf
sed -i 's/owner = www-data/owner = vagrant/g' /etc/php/7.1/fpm/pool.d/www.conf
cat << EOF > /etc/php/7.1/mods-available/xdebug.ini
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_autostart=1
EOF
echo "Done!"

info "Configure NGINX"
sed -i 's/user www-data/user vagrant/g' /etc/nginx/nginx.conf
echo "Done!"

info "Initailize databases for MySQL"
mysql -uroot <<< "CREATE DATABASE shopscript"
mysql -uroot <<< "CREATE DATABASE shopscript_test"
echo "Done!"

info "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer