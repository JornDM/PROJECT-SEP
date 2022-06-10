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
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

#iteratie 1

# log "installeer bind"
# sudo dnf install -y bind
# log "wijzig zodat hij naar alle interfaces luisterd en zodat iedereen toegang heeft"
# sed -i 's/127.0.0.1/any/' /etc/named.conf
# sed -i 's/localhost/any/' /etc/named.conf

# log "geef toegang aan poort 53 die door BIND gebruikt wordt"
# sudo firewall-cmd --permanent --add-port 53/udp
# log "reload de firewall"
# sudo firewall-cmd --reload
# log "start de service"
# sudo systemctl start named
# log "enable de service"
# sudo systemctl enable named

# #iteratie 2

# log "installeer bind"
# sudo dnf install -y bind
# log "wijzig zodat hij naar alle interfaces luisterd en zodat iedereen toegang heeft"
# sudo sed -i 's/127.0.0.1/any/' /etc/named.conf
# sudo sed -i 's/localhost/any/' /etc/named.conf

# log "wijzig zodat recursion af staat en dat er een zone gemaakt wordt"
# sudo sed -i 's/recursion yes/recursion no/' /etc/named.conf
# sudo sed -zi 's/zone "." IN {\n\ttype hint;\n\tfile "named.ca";\n};/zone "linux.lan" IN {\n\ttype master;\n\tfile "linux.lan";\n\tnotify yes;\n\tallow-update { none; };\n};/' /etc/named.conf

# log "copy inhoud van zone file"
# sudo cp "${PROVISIONING_SCRIPTS}/files/${HOSTNAME}/linux.lan" /var/named

# log "geef toegang aan poort 53 die door BIND gebruikt wordt"
# sudo firewall-cmd --permanent --add-port 53/udp
# log "reload de firewall"
# sudo firewall-cmd --reload
# log "start de service"
# sudo systemctl start named
# log "enable de service"
# sudo systemctl enable named

# #iteratie 3

# log "installeer bind"
# sudo dnf install -y bind
# log "wijzig zodat hij naar alle interfaces luisterd en zodat iedereen toegang heeft"
# sudo sed -i 's/127.0.0.1/any/' /etc/named.conf
# sudo sed -i 's/localhost/any/' /etc/named.conf

# log "wijzig zodat recursion af staat en dat er een zone gemaakt wordt"
# sudo sed -i 's/recursion yes/recursion no/' /etc/named.conf
# sudo sed -zi 's/zone "." IN {\n\ttype hint;\n\tfile "named.ca";\n};/zone "76.168.192.in-addr.arpa" IN {\n\ttype master;\n\tfile "76.168.192.in-addr.arpa";\n\tnotify yes;\n\tallow-update { none; };\n};/' /etc/named.conf

# log "copy inhoud van zone file"
# sudo cp "${PROVISIONING_SCRIPTS}/files/${HOSTNAME}/76.168.192.in-addr.arpa" /var/named

# log "geef toegang aan poort 53 die door BIND gebruikt wordt"
# sudo firewall-cmd --permanent --add-port 53/udp
# log "reload de firewall"
# sudo firewall-cmd --reload
# log "start de service"
# sudo systemctl start named
# log "enable de service"
# sudo systemctl enable named

# #iteratie 4 combineren van reverse en forward lookup zones zodat beide gecheckt kunnen worden

# log "installeer bind"
# sudo dnf install -y bind
# log "wijzig zodat hij naar alle interfaces luisterd en zodat iedereen toegang heeft"
# sudo sed -i 's/127.0.0.1/any/' /etc/named.conf
# sudo sed -i 's/localhost/any/' /etc/named.conf

# log "wijzig zodat recursion af staat en dat er een zone gemaakt wordt reverse en normal lookup zone"
# sudo sed -i 's/recursion yes/recursion no/' /etc/named.conf
# sudo sed -zi 's/zone "." IN {\n\ttype hint;\n\tfile "named.ca";\n};/zone "76.168.192.in-addr.arpa" IN {\n\ttype master;\n\tfile "76.168.192.in-addr.arpa";\n\tnotify yes;\n\tallow-update { none; };\n};/' /etc/named.conf
# sudo sed -zi 's/allow-update { none; };\n};/allow-update { none; };\n};\nzone "linux.lan" IN {\n\ttype master;\n\tfile "linux.lan";\n\tnotify yes;\n\tallow-update { none; };\n};/' /etc/named.conf

# log "copy inhoud van zone file voor de reverse en normal zone"
# sudo cp "${PROVISIONING_SCRIPTS}/files/${HOSTNAME}/76.168.192.in-addr.arpa" /var/named
# sudo cp "${PROVISIONING_SCRIPTS}/files/${HOSTNAME}/linux.lan" /var/named

# log "geef toegang aan poort 53 die door BIND gebruikt wordt"
# sudo firewall-cmd --permanent --add-port 53/udp
# log "reload de firewall"
# sudo firewall-cmd --reload
# log "start de service"
# sudo systemctl start named
# log "enable de service"
# sudo systemctl enable named

#DHCP
# log "installeer bind"
# sudo dnf install -y bind
# log "installeer dhcp"
# sudo dnf install -y dhcp-server

# log "wijzig zodat hij naar alle interfaces luisterd en zodat iedereen toegang heeft"
# sudo sed -i 's/127.0.0.1/any/' /etc/named.conf
# sudo sed -i 's/localhost/any/' /etc/named.conf

# log "wijzig zodat recursion af staat en dat er een zone gemaakt wordt reverse en normal lookup zone"
# sudo sed -i 's/recursion yes/recursion no/' /etc/named.conf
# sudo sed -zi 's/zone "." IN {\n\ttype hint;\n\tfile "named.ca";\n};/zone "76.168.192.in-addr.arpa" IN {\n\ttype master;\n\tfile "76.168.192.in-addr.arpa";\n\tnotify yes;\n\tallow-update { none; };\n};/' /etc/named.conf
# sudo sed -zi 's/allow-update { none; };\n};/allow-update { none; };\n};\nzone "linux.lan" IN {\n\ttype master;\n\tfile "linux.lan";\n\tnotify yes;\n\tallow-update { none; };\n};/' /etc/named.conf

# log "wijzig de config file van dhcp.conf"
# sudo sed -zi 's/#   see dhcpd.conf(5) man page\n#/subnet 192.168.76.0 netmask 255.255.255.0 {\n\trange 192.168.76.100 192.168.76.150;\n\toption domain-name-servers 192.168.76.254;\n\toption domain-name "linux.lan";\n}/' /etc/dhcp/dhcpd.conf

# log "copy inhoud van zone file voor de reverse en normal zone"
# sudo cp "${PROVISIONING_SCRIPTS}/files/${HOSTNAME}/76.168.192.in-addr.arpa" /var/named
# sudo cp "${PROVISIONING_SCRIPTS}/files/${HOSTNAME}/linux.lan" /var/named

# log "geef toegang aan poort 53 die door BIND gebruikt wordt"
# sudo firewall-cmd --permanent --add-port 53/udp
# log "reload de firewall"
# sudo firewall-cmd --reload
# log "start de BIND service"
# sudo systemctl start named
# log "start dhcpd service"
# sudo systemctl start dhcpd
# log "enable de BIND service"
# sudo systemctl enable named
# log "enable de dhcpd service"
# sudo systemctl enable dhcpd

# #of nog beter
log "installeer bind"
dnf install -y bind
log "installeer dhcp"
dnf install -y dhcp-server
log "wijzig zodat hij naar alle interfaces luisterd en zodat iedereen toegang heeft"
sed -i 's/127.0.0.1/any/' /etc/named.conf
sed -i 's/localhost/any/' /etc/named.conf

log "wijzig zodat recursion af staat en dat er een zone gemaakt wordt reverse en normal lookup zone"
sed -i 's/recursion yes/recursion no/' /etc/named.conf
cp "${PROVISIONING_FILES}/named.conf" /etc

log "wijzig de config file van dhcp.conf"
cp "${PROVISIONING_FILES}/dhcpd.conf" /etc/dhcp/

log "copy inhoud van zone file voor de reverse en normal zone"
cp "${PROVISIONING_FILES}/76.168.192.in-addr.arpa" /var/named
cp "${PROVISIONING_FILES}/linux.lan" /var/named

log "geef toegang aan poort 53 die door BIND gebruikt wordt"
firewall-cmd --permanent --add-port 53/udp
log "reload de firewall"
firewall-cmd --reload
log "start de BIND service"
systemctl start named
log "start dhcpd service"
systemctl start dhcpd
log "enable de BIND service"
systemctl enable named
log "enable de dhcpd service"
systemctl enable dhcpd
log "voer best deze commandos uit dhclient -r enp0s8
dhclient enp0s8 zodat de lease ververst wordt"