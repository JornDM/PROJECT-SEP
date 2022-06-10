#! /bin/bash




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





# Stop het script bij een onbestaande variabele

### Algemene variabelen wrden eerst gedefinieerd
# De map waarin je op zoek gaat naar het opgegeven type bestanden
SEARCH_DIR=/etc/alternatives
# De map waar je de documenten gaat opslaan
HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
BACKUP_TEMP_DIR=$HOME/BackupDir
       #/home/vagrant/BackupDir
BACKUP_DIR=/var/www/backups

mkdir -p ${BACKUP_TEMP_DIR}

### --- functions ---

# installeer de webserver, ook al zou de service al geïnstalleerd zijn. 
# Gebruik idempotente commando's waar mogelijk.
function install_nginx {
  # Ga na of de map voor de web-inhoud bestaat. Indien niet, maak ze aan
  if [ ! -d $BACKUP_DIR ]; then
    mkdir -p $BACKUP_DIR
  fi

  # Installeer de webserver software 
    dnf install -y nginx &> /dev/null
    systemctl enable --now nginx
  # Pas de configuratie van de webserver aan
    sed 's|/usr/share/nginx/html|/var/www/backups|g' /etc/nginx/nginx.conf

  # Herstart de service
    systemctl restart nginx
  # Firewall ... 
    systemctl enable --now firewalld
  
    firewall-cmd --zone=public --permanent --add-service=http

    firewall-cmd --zone=public --permanent --add-service=https

    firewall-cmd --reload
}

# kopieer de symbolisch gelinkte bestanden van de zoekmap naar de backupmap, inclusief indexbestand
function copy_symlink_files {
  local WorkDIR=$1
  local DestDIR=$2

  if [ ! -d $DestDIR ]; then
    echo "Directory bestaat niet"
    exit 1
  fi

  # Hint: werk met find en schrijf naar een tijdelijk bestand pamd_index.txt
    find ${WorkDIR} -type l| cut -d/ -f4 | sort | grep ^[e-n] | tee ${DestDIR}/pamd_index.txt &> /dev/null
  #  kopieer alle bestanden uit het indexbestand met een loop
  while read line
  do
        cp -R ${WorkDIR}/$line $DestDIR &> /dev/null #-R staat voor recursive anders heb je enkel een leeg naam en niet die eronder
	done < ${DestDIR}/pamd_index.txt # Hier kan je het tijdelijk bestand inlezen in een loop 

    mv ${DestDIR}/pamd_index.txt "${BACKUP_TEMP_DIR}/indexbestand" &> /dev/null

    #Hier komt nog een output melding die er niet hoort
}

function rename_mtaMTA {
  # Zorg er voor dat er _geen_ output is van deze functie!
    for d in ${BACKUP_TEMP_DIR}/mta-*;
    do
            #rename "mta-" "MTA-" $d

            mv $d $(echo $d | sed 's/mta-/MTA-/g')
        done 
}

function readonly_permissions {

    for d in ${BACKUP_TEMP_DIR}/*;
    do
            chmod 400 $d
        done 

}

function create_tarball {
  local WorkDIR=$1
  local FileName=$2
  
     # maak de tarbal aan
    cd
    tar --exclude=indexbestand -czf ${FileName}.tgz ${BACKUP_TEMP_DIR} 
    # kopieer de tarball naar de doelmap
    cp ${FileName}.tgz ${WorkDIR}
    # geef de inhoud van de tarbal weer
    printf "Inhoud van ${WorkDIR}/${FileName}.tgz:"
    cd ${WorkDIR}
    tar -tf ${FileName}.tgz | cut -d/ -f4 | sort
}

### --- main script ---
### Voer de opeenvolgende taken uit

# installeer nginx, ook al is het reeds geïnstalleerd. 

install_nginx &> /dev/null

# geef de datum weer van vandaag, gebruik deze globale variabele
DATUM=$(date -I)
printf "\nVandaag is het ${DATUM}.\n\n"

# leegmaken doelmap

copy_symlink_files ${SEARCH_DIR} ${BACKUP_TEMP_DIR} 2> /dev/null

rename_mtaMTA

readonly_permissions

create_tarball ${BACKUP_DIR} "alternatives_${DATUM}" 2> /dev/null

# Einde script