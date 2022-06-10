# Testrapport Opdracht x: (titel)

(Een testrapport is het verslag van de uitvoering van het testplan door een teamlid (iemand anders dan de auteur van het testplan!). Deze noteert bij elke stap in het testplan of het bekomen resultaat overeenstemt met wat verwacht werd. Indien niet, dan is het belangrijk om gedetailleerd op te geven wat er misloopt, wat het effectieve resultaat was, welke foutboodschappen gegenereerd werden, enz. De tester kan meteen een Github issue aanmaken en er vanuit het testrapport naar verwijzen. Wanneer het probleem opgelost werdt, wordt een nieuwe test uitgevoerd, met een nieuw verslag.)

## Test AD

Uitvoerder(s) test: Tibbe
Uitgevoerd op: 21/3
Github commit: COMMIT HASH ?

## Algemene benodigdheden

Alles verliep volgens plan

## Wijzigen Hostname PC

Geen errors, hostname correct veranderd

## Installatie Active Directory

AD DS staat bij rollen, dns is niet geconfigureerd dit klopt.

### Promoveren Server naar Domein Controller

Er staat geen vlaggetje, promotie is correct gelukt

### Aanmaken OU's binnen AD-structuur

OU's zijn correct aangemaakt

### Aanmaken AD-users

Users correct aangemaakt via csv bestand

### GPO Control Panel

Rechten zijn correct aangepast

### GPO Game Link Menu

AD users hebben geen toegang tot het game link menu

### GPO LAN properties

Dit klopt, getest op de client

### File System DFS

Share correct aangemaakt

### Algemeen

Het script 2x moeten uitvoeren op dezelfde server lukt moeizaam. Dit kan gebeuren door een te kort wachtwoord of als er iets misloopt.
