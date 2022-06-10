
# Stop het script bij een onbestaande variabele

### Algemene variabelen wrden eerst gedefinieerd
# De map waarin je op zoek gaat naar het opgegeven type bestanden
SEARCH_DIR=/etc/alternatives
# De map waar je de documenten gaat opslaan
HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
BACKUP_TEMP_DIR=$HOME/tmp
       #/home/vagrant/BackupDir
BACKUP_DIR=/var/www/html

mkdir -p ${BACKUP_TEMP_DIR}

### --- functions ---

# installeer de webserver, ook al zou de service al geïnstalleerd zijn. 
# Gebruik idempotente commando's waar mogelijk.
function install_httpd {
  # Ga na of de map voor de web-inhoud bestaat. Indien niet, maak ze aan
  if [ ! -d $BACKUP_DIR ]; then
    mkdir -p $BACKUP_DIR
  fi

  # Installeer de webserver software 
    dnf install -y httpd &> /dev/null
    systemctl enable --now httpd
  # Pas de configuratie van de webserver aan
    sed 's|Listen 80|Listen 8080|g' /etc/httpd/conf/httpd.conf

  # Herstart de service
    systemctl restart httpd
  # Firewall ... 
    systemctl enable --now firewalld
  
    firewall-cmd --zone=public --permanent --add-service=http

    firewall-cmd --zone=public --permanent --add-service=https

    firewall-cmd --zone=public --permanent --add-port 8080/tcp

    firewall-cmd --reload
}

# kopieer de symbolisch gelinkte bestanden van de zoekmap naar de backupmap, inclusief indexbestand
function copy_symlink_files {
  local WorkDIR=$1
  local DestDIR=$2

  if [ "$(ls -A $DestDIR)" ]; then
     echo "Wow, $DestDIR is not Empty"
  else
    cd $DestDIR | rm *
  fi

  if [ ! -d $DestDIR ]; then
    echo "Directory bestaat niet"
    exit 1
  fi

  # Hint: werk met find en schrijf naar een tijdelijk bestand pamd_index.txt
    find ${WorkDIR} -type l| cut -d/ -f4 | sort | grep %p% | tee ${DestDIR}/pamd_index.txt &> /dev/null
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
    for d in ${BACKUP_TEMP_DIR}/*lp*;
    do
            #rename "mta-" "MTA-" $d

            mv $d $(echo $d | sed 's/lp/LP/g')
        done 
}

function readonly_permissions {

    for d in ${BACKUP_TEMP_DIR}/*;
    do
            chmod 610 $d
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

install_httpd &> /dev/null

# geef de datum weer van vandaag, gebruik deze globale variabele
DATUM=$(date +"%Y-%m-%d-%H_%M-%S" )
printf "\nVandaag is het ${DATUM}.\n\n"

# leegmaken doelmap

copy_symlink_files ${SEARCH_DIR} ${BACKUP_TEMP_DIR} 2> /dev/null

rename_mtaMTA

readonly_permissions

create_tarball ${BACKUP_DIR} "alternatives_${DATUM}" 2> /dev/null

# Einde script