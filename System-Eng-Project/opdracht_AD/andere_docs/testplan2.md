# Testplan Opdracht 1: DNS Server

Auteur(s) testplan: Jorn De Meyer

# DNS

### Preconditie

- Een Virtuele Machine (SERVER) die Operating System Windows Server 2019 draait. De ISO hiervoor kan je installeren via: [https://www.academicsoftware.eu/software/316/1305](https://www.academicsoftware.eu/software/316/1305)
- Zorg er voor dat deze VM 2 adapters heeft: De default NAT-adapter en dan ook nog een LAN adapter die verbonden is met het internal network.
- Een Virtuele Machine (CLIENT) die zal fungeren als de Windows Client. Neem hiervoor de Windows Pro editie ISO, te verkrijgen op Academic Software: [https://www.academicsoftware.eu/software/316/1305](https://www.academicsoftware.eu/software/316/1305).  
  Zorg ervoor dat deze client lid is van het domein en kijk na of je op de verschillende users kan inloggen en wat hun rechten zijn.

### Postconditie

- Hostname juist ingesteld.
- Active Directory installed.
- Server promoted naar DC.
- OU's aangemaakt binnen AD-structuur.
- AD-users aanwezig binnen OU's.
- Werkstations aanwezig binnen OU's.
- GPO's juist ingesteld (control panel, games link, adapter-properties)
- File system DFS ok ("shared folder" tussen server & client)

## Hostname PC

Kijk na of de hostname juist werd ingesteld via het commando: `$env:COMPUTERNAME`  
Resultaat: **AGENTSMITH**

## Installatie Active Directory

Ga na of Active Directory installed is via het onderstaande commando:
```powershell
Get-WindowsFeature | where{$_.InstallState -eq "Installed"}
```
Resultaat: Active Directory Domain Services bevindt zich in de output.  

## Promoveren Server naar Domein Controller

Hierna gaan we de server promoveren tot Domein Controller. Om na te gaan of hieraan voldaan is, moet je de server manager openen. Als je rechtsbovenin bij het vlaggetje geen uitroepingsteken/warning-sign ziet staan, dan wil dit zeggen dat na installatie de server succesvol werd gepromote tot DC!  
![server_promotion_DC](https://cdn.discordapp.com/attachments/746033773115736176/951137837233885224/unknown.png)

Ga hierbij ook na of de naam het domein correct werd ingesteld. De correcte naam zou **thematrix** moeten zijn. Dit kan je opvragen via het volgende powershell-commando:  
![domain_ok](https://cdn.discordapp.com/attachments/746033773115736176/954802794320265317/unknown.png)

## Aanmaken OU's binnen AD-structuur

Open via Windows Verkenner "Active Directory Users And Computers" en kijk na of je onder het domein _thematrix.local_ de volgende OU structuur terug kan vinden:  
* Afdelingen
    * IT administratie
    * Ontwikkeling
    * Administratie
    * Directie
    * Verkoop 

### Aanmaken AD-users

Kijk per sub-ou (It-administratie, ontwikkeling, ...) na of er in elke OU **een user** aanwezig is.  
Als dit het geval is, dan is dit onderdeel OK.  

### Aanmaken Werkstations

Ga ook na of er per sub-ou een werkstation aanwezig is. Naam van het werkstation is hier niet van belang.  

### GPO's 
Log in op de client en controleer of het volgende mogelijk is:
* Client heeft **geen toegang** tot control panel (sluit vanzelf).
* Client ziet Games Link menu **niet default staan** bij openen Windows Verkenner.
* Client kan de properties van LAN-adapter **niet** openenen.

### File System DFS
Open Verkenner. Browse naar het volgende pad op de Server: `\\thematrix.local\NameSpace1`.  
Hier zouden 2 folders aanwezig moeten zijn. Voeg iets toe in de Client folder (.txt bestand bv).  
Log nu in op de client en kijk na of je toegang hebt tot dit bestand.  
Indien dit het geval is, dan is DFS ok.  

