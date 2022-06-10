# Testplan Opdracht 1: DNS Server

Auteur(s) testplan: Kevin Benoit

# DNS

### Preconditie

- De server bestaat
- AlmaLinux geïnstalleerd op de server

### Postconditie

- Hostname is "morpheus"
- Server is benaderbaar via SSH (inloggen via ssh-keys, dus zonder wachtwoord)
- De DNS server is de authoritative DNS server voor het domein "thematrix.local"
- Queries voor andere domeinen worden geforward naar correcte externe DNS server
- Er zijn correcte records voorzien in de gepaste zonebestanden (A, AAAA, PTR)
  -Elke host beschikt over een geschikte CNAME-record
  -Overige records zijn aangemaakt

## 1.0 Hostname moet "morpheus" zijn

Door onderstaande commandline uit te voeren moet je in de "Static hostname" gedeelte de hostname "morpheus" vinden

- hostnamectl

## 1.1 SSH-Keys inlogsysteem, hier is de bedoeling dat we kunnen inloggen aan de hand van SSH-keys zonder authenticatie van een wachtwoord.

Door de onderstaande line uit te voeren op je eigen pc, na het toevoegen van jou public key aan de authorized keys ook moet er aan port forwarding gedaan worden in virtual box, zou het mogelijk moeten zijn om in te loggen zonder enige authenticatie. Als onderstaande output is bereikt, is de SSH-keys inlogsyssteem correct

- ssh -p 2222 vagrant@127.0.0.1  
  ![ssh-output](https://cdn.discordapp.com/attachments/795373785699188787/951154050416660560/Schermafbeelding_2022-03-09_172619.png)

## 1.2 DNS de authorised server van thematrix.local

- nslookup 192.168.76.98
- nslookup morpheus.thematrix.local
- probeer de andere apparaten ook te bereiken

## 1.3 Queries voor andere domein geforward naar gepaste externe DNS-server?

Door de nslookup te runnen voor google.com zouden we de DNS server van google.com moeten bereiken en niet die van thematrix.local,
zo controleren we andere domeinen niet geforward worden naar onze DNS server.

- nslookup www.google.com

## 1.4 A, AAA en PTR records in de gepaste zonebestanden?

De standaard record die wordt opgegeven is de A record, alle overige records volgen
met de commandline "Dig @192.168.76.98 thematrix.local 'RECORD'

- Dig @192.168.76.98 thematrix.local
- Dig @192.168.76.98 thematrix.local ‘AAA’
- Dig @192.168.76.98 thematrix.local ‘PTR’

## 1.5 Geschikte CNAME en overige records?

- nslookup dns
- nslookup ad
- probeer de andere CNAMES ook te bereiken
- cat fwd.morpheus.thematrix.local
