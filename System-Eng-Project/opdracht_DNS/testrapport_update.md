# Testrapport Opdracht x: (titel)

## Test 1: SSH test
Na enkele wijzigingen en fixes aan het script lukte het dit keer wel om via SSH in te loggen op de DNS server via CMD.  
![ssh-solved](img/ssh_solved.png)

Uitvoerder(s) test: Jorn De Meyer
Uitgevoerd op: 16/03/2022
Github commit:  COMMIT HASH

## Test 2: DNS de authorised server van thematrix.local
Bij de vorige test probeerden we te nslookupen naar 192.168.76.98.  
We wijzigen dit naar het adres 192.168.76.97. Dit is het adres van de AD-Server.  
![nslookup_solved1](img/nslookup_solved_1.png)


## Test 3: A, AAA en PTR records in de gepaste zonebestanden?

Hierbij slaagden de eerste en tweede test niet. Laten we deze hernemen:  
* `dig @192.168.76.98 thematrix.local`  
![dig1_solved](img/dig-1_solved.png)  

* `Dig @192.168.76.98 thematrix.local ‘AAA’`  
![dig2_solved](img/dig2_solved.png)

## Test 4: Geschikte CNAME en overige records?
De laatste tests worden nu opnieuw herbekeken.
* `nslookup dns.thematrix.local`  
![nslookup_dns](img/nslook_dns_ok.png)  

* `nslookup dns.thematrix.local`
![nslookup_ad](img/nslookup_ad_ok.png)

## Besluit
Alle problemen werden goed opgelost. Goed gedaan, team-DNS! 

Uitvoerder(s) test: Jorn De Meyer  
Uitgevoerd op: 15/03/2022  
Github commit:  518a4c2f2fbc478268adb0cc322f589eaecab247
