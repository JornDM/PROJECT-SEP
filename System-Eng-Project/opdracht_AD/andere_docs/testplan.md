# Testplan Opdracht 1: Domein Controller

Auteur(s) testplan: Jorn De Meyer

## Algemene benodigdheden

- Een Virtuele Machine (SERVER) die Operating System Windows Server 2019 draait. De ISO hiervoor kan je installeren via: [https://www.academicsoftware.eu/software/316/1305](https://www.academicsoftware.eu/software/316/1305)
- Zorg er voor dat deze VM 2 adapters heeft: De default NAT-adapter en dan ook nog een LAN adapter die verbonden is met het internal network.
- Een Virtuele Machine (CLIENT) die zal fungeren als de Windows Client. Neem hiervoor de Windows Pro editie ISO, te verkrijgen op Academic Software: [https://www.academicsoftware.eu/software/316/1305](https://www.academicsoftware.eu/software/316/1305).  
  Zorg ervoor dat deze client lid is van het domein en kijk na of je op de verschillende users kan inloggen en wat hun rechten zijn.

## Wijzigen Hostname PC

Het eerste wat er in ons script gebeurt is het hernoemen van de computer.
De gebruiker geeft de gewenste naam in, daarna wordt de naam gewijzigd en het systeem opnieuw opgestart.  
De correcte naam voor de server, zoals in de opdracht, is **agentsmith**.  
We kunnen nagaan of dit in orde is door het onderstaande commando in te geven:  
![hostname_ok](https://cdn.discordapp.com/attachments/746033773115736176/954804500152058036/unknown.png)

## Installatie Active Directory

Daarna installeren we Active Directory.  
Of dit succesvol is verlopen, kunnen we nagaan door de Server Manager te openen.  
Daarna controlleer je of er in de linker sidebar "AD DS" staat. Is dit het geval, dan werd Active Directory goed geïnstalleerd!
![img4](https://cdn.discordapp.com/attachments/746033773115736176/950869514340413470/unknown.png)

![img5](https://cdn.discordapp.com/attachments/746033773115736176/950870114947956746/unknown.png)

### Promoveren Server naar Domein Controller

Hierna gaan we de server promoveren tot Domein Controller. Om na te gaan of hieraan voldaan is, moet je de server manager openen. Als je rechtsbovenin bij het vlaggetje geen uitroepingsteken/warning-sign ziet staan, dan wil dit zeggen dat na installatie de server succesvol werd gepromote tot DC!  
![server_promotion_DC](https://cdn.discordapp.com/attachments/746033773115736176/951137837233885224/unknown.png)

Ga hierbij ook na of de naam het domein correct werd ingesteld. De correcte naam zou **thematrix** moeten zijn. Dit kan je opvragen via het volgende powershell-commando:  
![domain_ok](https://cdn.discordapp.com/attachments/746033773115736176/954802794320265317/unknown.png)

### Aanmaken OU's binnen AD-structuur

Voor het controleren van de OU's moet je navigeren naar het "Active Directory Users and Computers". Hier zou je de volgende OU's moeten zien:

- Afdelingen
  - IT administratie
  - Ontwikkeling
  - Administratie
  - Directie
  - Verkoop

![navigeren_OU's](https://cdn.discordapp.com/attachments/746033773115736176/951142392394813480/unknown.png)

![OU-structuur-OK](https://media.discordapp.net/attachments/746033773115736176/951143925295509564/unknown.png)

### Aanmaken AD-users

Om na te gaan of de AD-users succesvol werden aangemaakt, moet je navigeren naar het "Active Directory Users and Computers" venster.  
Hier zou je normaal gezien bij elke OU 1 user moeten zien, die worden geïmporteerd via het .csv-bestand.
![searching_ADusers&comp](https://cdn.discordapp.com/attachments/746033773115736176/951142392394813480/unknown.png)

![resultaat_ad-users](https://cdn.discordapp.com/attachments/756078480864837712/953231820999229460/unknown.png)

### Aanmaken Werkstations

Ga nu na of de werkstations correct werden toegevoegd aan de verschillende OU's. Open de verschillende OU's en kijk na of er voor elke OU een werkstation voorzien is. Dit doen we opnieuw in het venster van "Active Directory Users and Computers".

Note bij de afbeelding -> zorg dat er voor elke OU een workstation voorzien is.  
![werkstations-ok](https://cdn.discordapp.com/attachments/746033773115736176/951146270859337738/unknown.png)

### GPO Control Panel

Het is belangrijk dat de rechten van bepaalde users worden beperkt zodat zij geen schade kunnen toebrengen of het systeem kunnen wijzigen. Controleer dus zeker of users uit elke afdeling **behalve IT administratie** geen toegang hebben tot het control panel.

![control_panel_search](https://cdn.discordapp.com/attachments/746033773115736176/951150011364810782/unknown.png)

_Resultaat dat je zou moeten krijgen voor OU's: verkoop, administratie, ontwikkeling en directie._

![control_panel_warning](https://cdn.discordapp.com/attachments/746033773115736176/951150146228486165/unknown.png)

### GPO Game Link Menu

Ga nu na of de user geen toegang meer heeft tot het Game Link Menu.  
Dit kun je doen door de windows verkenner te openen en te zoeken naar 'Game Link Menu"  
Indien hij dit niet vindt, is het in orde.

### GPO LAN properties

Het is zo dat users uit de OU's administratie en verkoop **geen toegang hebben tot de properties van de netwerkadapter**. Ga na of dit ook het geval is. Gebruik eerst de toetsencombinatie `windows-key + R` en daarna geef je in `ncpa.cpl`.  
![run-screen](https://cdn.discordapp.com/attachments/746033773115736176/951151249741447168/unknown.png)

_Resultaat na het ingeven van het commando `ncpa.cpl`._

![resultaat_ncpa.cpl](https://cdn.discordapp.com/attachments/746033773115736176/951151431744901181/unknown.png)

### File System DFS

Ten slotte gaan we nakijken of het is gelukt om het File System DFS correct te implemnteren. Dit kan je doen door na te gaan of er voor elke user een map staat in de map _C:\Share\\"username"_ op het host systeem van de user.  
![result_dfs](https://cdn.discordapp.com/attachments/746033773115736176/951152902624411719/unknown.png)
