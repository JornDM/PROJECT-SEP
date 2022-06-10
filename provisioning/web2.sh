#! /bin/bash
#
# Provisioning script for server www

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # do not mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}${HOSTNAME}"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "Hostname aanpassen"
hostnamectl set-hostname trinity.thematrix.local

log "Change ssh options"
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

log "no more ssh password"
cp "${PROVISIONING_FILES}/authorized_keys" /home/vagrant/.ssh/authorized_keys

log "INSTALLEREN Apache..."
dnf install -y httpd

systemctl start httpd
systemctl enable httpd

log "firewall in orde brengen"
dnf install -y firewalld
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

log "restarten Apache"
systemctl restart httpd



log "PHPv7.4 installen"
sudo dnf install -y php
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module -y reset php
sudo dnf module install -y php:remi-7.4
sudo dnf -y install php php-mysqlnd php-cli
php --version

log "MariaDB server"
sudo dnf install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

# Database root password
readonly db_root_password='root'

# Database name
readonly db_name=wordpress

# Database table
readonly db_table=wordpress

# Database user
readonly db_user=wordpress_user

# Database password
readonly db_password='root'

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

# Predicate that returns exit status 0 if the database root password
# is not set, a nonzero exit status otherwise.
is_mysql_root_password_empty() {
  mysqladmin --user=root status > /dev/null 2>&1
}

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "Securing the database"

if is_mysql_root_password_empty; then
mysql --user=root <<_EOF_
  UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
fi

log "Creating database and user"

mysql --user=root --password="${db_root_password}" << _EOF_
CREATE DATABASE IF NOT EXISTS ${db_name};
GRANT ALL ON ${db_name}.* TO '${db_user}'@'%' IDENTIFIED BY '${db_password}';
FLUSH PRIVILEGES;
_EOF_

log "Wordpress op de server zetten"
sudo wget https://wordpress.org/latest.tar.gz -P /var/www/html
sudo tar -xzvf /var/www/html/latest.tar.gz -C /var/www/html
sudo mv /var/www/html/wordpress/* /var/www/html
sudo rm -r /var/www/html/wordpress
sudo rm /var/www/html/latest.tar.gz
sudo systemctl restart httpd
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sudo sed -i 's/database_name_here/wordpress/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/wordpress_user/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/root/' /var/www/html/wp-config.php

sudo dnf install -y mod_ssl openssl

sudo openssl genrsa -out ca.key 2048
sudo openssl req -new -key ca.key -out ca.csr -subj "/C=SI/ST=thematrix/L=thematrix/O=Security/OU=IT Department/CN=www.thematrix.local"
sudo openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt

sudo cp ca.crt /etc/pki/tls/certs
sudo cp ca.key /etc/pki/tls/private/ca.key
sudo cp ca.csr /etc/pki/tls/private/ca.csr

sudo sed -i 's+/etc/pki/tls/certs/localhost.crt+/etc/pki/tls/certs/ca.crt+' /etc/httpd/conf.d/ssl.conf
sudo sed -i 's+/etc/pki/tls/private/localhost.key+/etc/pki/tls/private/ca.key+' /etc/httpd/conf.d/ssl.conf

sudo systemctl restart httpd

sudo mkdir -p /etc/httpd/sites-available
sudo mkdir -p /etc/httpd/sites-enabled

sudo echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
sudo touch /etc/httpd/sites-available/thematrix.local.conf
cp "${PROVISIONING_FILES}/thematrix.conf" /etc/httpd/sites-available/thematrix.local.conf
sudo ln -s /etc/httpd/sites-available/thematrix.local.conf /etc/httpd/sites-enabled/thematrix.local.conf

sudo touch /var/www/html/.htaccess
cp "${PROVISIONING_FILES}/.htaccess" /var/www/html/.htaccess

sudo echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf
sudo echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf

sudo systemctl restart httpd

sudo sed -i 's+expose_php = On+expose_php = Off+' /etc/php.ini
sudo systemctl restart php-fpm

