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
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/${HOSTNAME}"

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
systemctl restart sshd

log "no more ssh password"
cp "${PROVISIONING_FILES}/authorized_keys" /home/vagrant/.ssh/authorized_keys

log "INSTALLEREN NGINX..."
dnf install -y nginx

systemctl start nginx
systemctl enable nginx

log "firewall in orde brengen"
dnf install -y firewalld
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

log "restarten nginx"
systemctl restart nginx

log "Installeren postgresql"
dnf install -y postgresql-server

log "configureren postgresql"
postgresql-setup --initdb

log "opstarten postgres"
systemctl start postgresql
systemctl enable postgresql

log "nieuwe role maken"
sudo -u postgres createuser wordpress -s

log "nieuwe databank maken"
sudo -u postgres createdb wordpress

log "gebruiker wordpress aanmaken"
adduser wordpress

