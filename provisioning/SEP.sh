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
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}opdracht_DNS/${HOSTNAME}"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

# ssh-keygen-t rsa 
# cat .ssh/id_rsa.pub | ssh vagrant@192.168.76.70 ‘cat >> .ssh/authorized_keys’
HOSTNAME="morpheus"

log "installeer bind"
dnf install -y bind

log "Hostname aanpassen"
hostnamectl set-hostname $HOSTNAME.thematrix.local

log "start de BIND service"
systemctl start named

log "enable de BIND service"
systemctl enable named

log "import configuratie in named.conf"
cp "${PROVISIONING_FILES}/named.conf" /etc

log "import configuratie van de forwarder"
cp "${PROVISIONING_FILES}/fwd.morpheus.thematrix.local" /var/named

log "import configuratie van de reversed forwarder"
cp "${PROVISIONING_FILES}/rev.morpheus.thematrix.local" /var/named

log "import configuratie van de reversed forwarder"
cp "${PROVISIONING_FILES}/rev.ip6.morpheus.thematrix.local" /var/named

log "import configuratie in resolv.conf"
#mv /etc/resolv.conf /etc/resolv.conf.old
#cp "${PROVISIONING_FILES}/resolv.conf" /etc
sed -i 's/search hogent.be thematrix.local/search thematrix.local/' /etc/resolv.conf
sed -i 's/search home thematrix.local/search thematrix.local/' /etc/resolv.conf
sed -i 's/nameserver 10.0.2.3/nameserver 192.168.76.98/' /etc/resolv.conf

log "geef toegang aan poort 53 die door BIND gebruikt wordt"
firewall-cmd --permanent --add-port 53/udp
firewall-cmd --permanent --add-port 22/tcp

log "reload de firewall"
firewall-cmd --reload

log "reload de BIND service"
systemctl reload named

log "Change ssh options"
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

systemctl restart sshd

log "no more ssh password"
cp "${PROVISIONING_FILES}/authorized_keys" /home/vagrant/.ssh/authorized_keys

log "resolv.conf permanent maken"
sudo chattr +i /etc/resolv.conf

log "Default gateway instellen"
sudo ip route add default via 192.168.76.1