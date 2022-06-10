# Testplan Opdracht 3: Web Server 
[] hostname "Trinity"
[] inloggen zonder wachtwoord via SSH
[] inloggen als root gebruiker niet mogelijk.

We hebben hier bewust gekozen om niet te werken met nginx. We zijn te werk gegaan met een LAMP (Linux , Apache, MySql , php) stack voor de configuratie van onze webserver. Tijdens onze research werd ons duidelijk dat de combinatie nginx met postgreSQL 
niet de beste combinatie om dit te doen werken met wordpress. Vandaar hebben we bewust gekozen voor Apache in combinatie met Mysql in plaats van Postgresql.

[] draait op apache
[] mysql is geinstalleerd
[] wordpress werkt en is gelinkt aan de databank
[] https werkt
[] http naar https (redirect werkt)
[] HTTP/2 werkt. Kan bekeken worden via element inspecteren in browser
[] Je kan vanaf elk toestel surfen via de URL. DNS moet aanstaan
[] Je kan via wordpress een artikel deployen
[] Een nmap scan geeft geen informatie weer over de versie van apache

