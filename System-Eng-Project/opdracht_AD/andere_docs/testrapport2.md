# Testrapport Opdracht AD: (AD Testrapport 2)

(Een testrapport is het verslag van de uitvoering van het testplan door een teamlid (iemand anders dan de auteur van het testplan!). Deze noteert bij elke stap in het testplan of het bekomen resultaat overeenstemt met wat verwacht werd. Indien niet, dan is het belangrijk om gedetailleerd op te geven wat er misloopt, wat het effectieve resultaat was, welke foutboodschappen gegenereerd werden, enz. De tester kan meteen een Github issue aanmaken en er vanuit het testrapport naar verwijzen. Wanneer het probleem opgelost werdt, wordt een nieuwe test uitgevoerd, met een nieuw verslag.)

## Test AD

Uitvoerder(s) test: Kevin
Uitgevoerd op: 30/03
Github commit: COMMIT HASH ?

## Algemene benodigdheden

Alles is correct, alles verliep volgens plan

## Wijzigen Hostname PC

De hostname is correct

## Installatie Active Director

DNS is niet geconfigureerd, dit is juist. AD DS staat tussen de rollen.

### Promoveren Server naar Domein Controller

Er staat geen uitroepteken of een warning bij het vlaggetje bij Server Manager, dit is dus juist

### Aanmaken OU's binnen AD-structuur

De OU's zijn juist aangemaakt, en zijn te vinden in de "Active Directory Users and Computers"

### Aanmaken AD-users

Bij elke sub-ou is er een user aanwezig en aangemaakt.

### GPO Control Panel

Dit is correct, control panel sluit vanzelf af op de client.

### GPO Game Link Menu

Dit is correct, ik heb geen toegang tot de game link menu.

### GPO LAN properties

Dit is correct, ik heb geen rechten om de properties te bekijken

### File System DFS

De DFS werkt, een nieuw bestand maken en deze op de server en op de client zien is mogelijk.

### Algemeen

Het script 2x moeten uitvoeren op dezelfde server lukt moeizaam. Dit kan gebeuren door een te kort wachtwoord of als er iets misloopt.
