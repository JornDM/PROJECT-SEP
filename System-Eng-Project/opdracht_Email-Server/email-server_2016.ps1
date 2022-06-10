 # ====================================================================== # 
 # ============== Setting up Email Server ============== # 
 # ====================================================================== # 

 clear
 
  # ===== Variabelen ===== #
  $hostname = read-host -Prompt "Enter the hostname for this server"

 [string] $ipv4 = "192.168.76.101"
 [string] $ipv6 = "2001:db8:1:3::101"
 [string] $prefix = "24"
 [string] $gateway = "192.168.76.97" # => Aangepast, zodat emailserver op internet kan.
 [string] $DNS = "192.168.76.97"
 
# ===== Configuratie ===== #
 
# => Instellen statische IP-adressen
Get-NetAdapter -Name "Ethernet 2" | Rename-NetAdapter -NewName "LAN"

$lan_adapter_iface_index = (Get-NetAdapter -Name "LAN").ifIndex

New-NetIPAddress -AddressFamily IPv4 -IPAddress $ipv4 -PrefixLength $prefix -InterfaceIndex $lan_adapter_iface_index -DefaultGateway $gateway 
New-NetIPAddress -InterfaceIndex $lan_adapter_iface_index -AddressFamily IPv6 -IPAddress $ipv6 -PrefixLength 64 
Set-DnsClientServerAddress -InterfaceIndex $lan_adapter_iface_index -ServerAddresses ("$DNS", "192.168.76.102")

# 1. => Wijzigen naam toestel
write-host "Renaming this computer to: $hostname" -ForegroundColor Red -BackgroundColor White
Rename-Computer -NewName $hostname -Restart -Force

# 2. => Domein joinen
write-host "NOTE: LOG IN thematrix\administrator NA HET JOINEN VAN HET DOMEIN!!!" -BackgroundColor White -ForegroundColor Red
$domain = read-host -Prompt "Enter the domain you wish to join"
add-computer -DomainName $domain -Credential "$domain\Administrator" -Restart -Force

# Items kopieëren van shared folder naar map op desktop.
write-host "Kopieëren items van shared folder naar dekstop..." -ForegroundColor red -BackgroundColor white 
Copy-Item \\VBOXSVR\installation_files_exchange_2016 -Destination .\Desktop\shared -Recurse

# 3. => Installeren .NET Framework 4.8
# Plaats deze in een shared folder. Deze kan NIET worden opgehaald van online!
# Zorg er ook voor dat de naam "NETFRAMEWORK" van het bestand is, anders problemen met het script!
Write-Host "Installeren NETFRAMEWORK 4.8..." -BackgroundColor White -ForegroundColor Red 
$dest1 = ".\Desktop\shared\NETFRAMEWORK.exe"
Start-Process -FilePath $dest1 /quiet


# 4. Installeren WindowsFeature RSAT-ADDS
Write-Host "Installeren WindowsFeature RSAT-ADDS" -BackgroundColor White -ForegroundColor Red
Install-WindowsFeature RSAT-ADDS

# 5. Installeren Prerequisites voor Exchange Mailbox Server Role
Write-Host "Installeren prerequisites voor Exchange Mailbox Server Role..." -BackgroundColor White -ForegroundColor Red 
Install-WindowsFeature NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS, ADLDS

# 6. Installeren Prerequiites voor Edge Server Role
Write-Host "Installeren prerequisites voor Edge Server Role..." -BackgroundColor White -ForegroundColor Red 
Install-WindowsFeature ADLDS 

# -> Pc zal hier restarten.  (nieuw deel!)

# 7. => Installeren Unified Communications Managed API 4.0
write-host "Installeren Unified Communication Managed API (versie 4.0)..." -BackgroundColor White -ForegroundColor Red 
$dest2 = ".\Desktop\shared\UcmaRuntimeSetup.exe"
Start-Process -FilePath $dest2 /quiet

# 8. => Installeren c++ 2012 pack
write-host "Installeren c++ 2012 package" -BackgroundColor White -ForegroundColor Red 
$dest4 = ".\Desktop\shared\c++12.exe"
Start-Process -FilePath $dest4 /quiet

# 9. => Installeren c++ 2013 pack
write-host "Installeren c++ 2013 package" -BackgroundColor White -ForegroundColor Red 
$dest5 = ".\Desktop\shared\c++13.exe"
Start-Process -FilePath $dest5 /quiet

# 10. => Installeren IIS URL rewrite module
write-host "Installeren IIS URL rewrite module..." -BackgroundColor White -ForegroundColor Red 
$dest6 = ".\Desktop\shared\urlrewrite2.exe" 
Start-Process -FilePath $dest6  

# Snelle restart - nodige voor volgende deel.
restart-computer

# 11. => Extend AD schema
write-host "Mounten van de ISO (E:\)" -BackgroundColor White -ForegroundColor Red 
.\Desktop\shared\exchange_2016.ISO 
set-location E:\ # -> probleem dat hij de locatie niet veranderd in één keer. 

write-host "Voorbereiden Email-Server op AD-Schema..." -BackgroundColor White -ForegroundColor Red 
\Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms_DiagnosticDataOn

write-host "Extenden AD schema naar thematrix.local..." -BackgroundColor White -ForegroundColor Red  
\Setup.exe /PrepareAD /OrganizationName: "thematrix” /IAcceptExchangeServerLicenseTerms_DiagnosticDataOn

# 12. => Installeren RSAT-Clustering
write-host "Installeren RSAT-Clustering-CmdInterface..." -BackgroundColor White -ForegroundColor Red 
Install-WindowsFeature RSAT-Clustering-CmdInterface


# Installeren EXCHANGE
\Setup.exe 

write-host "Na installatie van Exchange -> herstarten!" -BackgroundColor White -ForegroundColor Red 

# ============================================
# Configuratie Exchange 2016 (NA INSTALLATIE)
# ============================================

# Note: voer deze commando's uit als je toegang hebt tot het Exchange 2016 administrator center.

# 1. Toegang tot exchange 2016 commando's in powershell
write-host "Inladen Exchange 2016 Powershell commando's..." -ForegroundColor Red -BackgroundColor White 

$s = New-PSSession -ConfigurationName microsoft.exchange -ConnectionUri http://neo.thematrix.local/powershell
Import-PSSession $s

# 2. Aanmaken send connector
write-host "Creating a Send Connector..." -BackgroundColor White -ForegroundColor Red 

New-SendConnector -Internet  -Name "Send Connector" -AddressSpaces * # Of thematrix.local, dit moet ik nog herzien. Nu kan hij naar alle domeinen sturen.

# 3. Aanpassen virtual directories
write-host "Configuring virtual directories..." -BackgroundColor White -ForegroundColor Red 
[string]$domain = $env:USERDOMAIN + ".local"
[string]$server = "neo"
Set-EcpVirtualDirectory "$server\ECP (Default Web Site)" -ExternalUrl ("https://$server.$domain/ecp")
Set-WebServicesVirtualDirectory "$server\EWS (Default Web Site)" -ExternalUrl ("https://$server.$domain/EWS/Exchange.asmx")
Set-ActiveSyncVirtualDirectory "$server\Microsoft-Server-ActiveSync (Default Web Site)" -ExternalUrl ("https://$server.$domain/Microsoft-Server-ActiveSync")
Set-OabVirtualDirectory "$server\OAB (Default Web Site)" -ExternalUrl ("https://$server.$domain/OAB")
Set-OwaVirtualDirectory "$server\OWA (Default Web Site)" -ExternalUrl ("https://$server.$domain/OWA")
Set-PowerShellVirtualDirectory "$server\PowerShell (Default Web Site)" -ExternalUrl ("https://$server.$domain/powershell")

# 4. Aanmaken Postvakken voor de verschillende users [ Vergeet het users.csv bestand niet te importeren! ]
$users = Import-Csv -Path '.\Desktop\shared\users.csv' -Delimiter ";"
foreach($user in $users) {
     [string] $firstname = $user.firstname
     [string] $lastname = $user.lastname
     [string] $domain = "thematrix.local"

     write-host "Postvak aanmaken voor $firstname $lastname..." -ForegroundColor Red -BackgroundColor White 
     New-Mailbox -Name "$firstname $lastname" -Password (Read-host "Geef het wachtwoord op van $firstname $lastname" -AsSecureString "AccountPassword") -UserPrincipalName "$($firstname)_$($lastname)@$domain"
}

# 5. DNS zoekopdrachten laten verlopen via interne netadapter DNS conifg
Get-WmiObject win32_networkadapter -Property "guid"
[string]$guid = Read-Host "Wat is de GUID van de 2de netwerkdapter? (Zie output)"
Set-TransportService -Identity "neo" -InternalDNSAdapterGuid "$guid" -InternalDNSAdapterEnabled:$true

# 6. Installeren en configureren virusscanner
write-host "Installeren en configureren virusscanner..." -ForegroundColor Red -BackgroundColor White 
New-MalwareFilterPolicy -Name "VirusScanner" `
                        -Action DeleteAttachmentAndUseCustomAlert `
                        -CustomAlertText "Het bestand in deze mail werd verwijdert, aangezien er een gevaarlijk bestand werd gevonden." `
                        -EnableInternalSenderAdminNotifications:$true `
                        -InternalSenderAdminAddress "email_admin@thematrix.local" `
                        -EnableInternalSenderNotifications:$true

New-MalwareFilterRule -name "VirusScanner" `
                      -MalwareFilterPolicy "VirusScanner" `
                      -RecipientDomainIs "thematrix.local"

# 7. Installeren en configureren antispamfilter
write-host "Installeren en configureren spamfilter..." -ForegroundColor Red -BackgroundColor White 
Set-SenderFilterConfig -Enabled:$true 
Set-SenderFilterConfig -BlockedDomains @{Add="spammer.com","somejunk.com"}
Set-SenderFilterConfig -BlankSenderBlockingEnabled:$true
