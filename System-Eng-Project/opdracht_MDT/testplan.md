# Testplan Opdracht 1: MDT Server

Auteur(s) testplan: Kevin Benoit

# MDT



### Postconditie

- Hostname is "theoracle"
- MDT is correct ingesteld
- PXE Boot werkt en is juist ingesteld
## 1.0 Hostname moet "theoracle" zijn

Door op te zoeken wat je Device Name is, zal je je hostnaam te zien krijgen. Dit moet "Theoracle" zijn.

## 1.1 MDT is correct ingesteld

Je moet zorgen dat er op je MDT alles correct is ingesteld:
- WDS met theoracle.thematrix.local als server.
- WDS met de juiste install image
- WDS met de juiste boot image
- Deployment WorkBench met een share
- Deployment WorkBench met een werkende Operating System (Windows (Pro) 10 Edu N)
- Deployment WorkBench met een Task Sequence (Applicatie LibreOffice geïmplenteerd)
- UEFI Detection staat ingesteld in task sequence om errors te voorkomen in PXEBOOT

## 1.2 PXE Boot werkt

- Door op F12 te klikken moet je een scherm krijgen waar je 3 keuzes krijgt (Klik op LAN)
- Je moet nu een connectie krijgen met DHCP en een connectie krijgen met PXEBOOT
- In je PXE Boot moet je het domein kunnen joinen
- Ook moet je de applicatie (LibreOffice) kunnen aanduiden om geïnstalleerd te worden
- In je nieuwe Windows Server (door PXE Boot) moet je LibreOffice kunnen terugvinden
- Je moet 192.168.76.103 kunnen pingen (MDT)

