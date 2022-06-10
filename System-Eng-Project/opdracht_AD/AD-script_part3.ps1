 # ====================================================================== # 
 # ============== AD-Script 3: Configuration and Structure Active Directory  ============== # 
 # ====================================================================== # 

 # ===== AD structuur aanmaken ===== #

 [string]$domain = $env:USERDOMAIN
 [string] $OU_afdelingen_path = “OU=Afdelingen,DC=$domain,DC=Local"

# => main OU: AFDELINGEN
New-ADOrganizationalUnit -Name "Afdelingen" -Path "DC=$domain,DC=local"

# => sub-OU's onder AFDELINGEN
write-host "Aanmaken SUB-ou's..." -BackgroundColor White -ForegroundColor Red 

New-ADOrganizationalUnit -Name "IT Administratie" -Path $OU_afdelingen_path 
New-ADOrganizationalUnit -Name "Verkoop" -Path $OU_afdelingen_path
New-ADOrganizationalUnit -Name "Administratie" -Path $OU_afdelingen_path
New-ADOrganizationalUnit -Name "Ontwikkeling" -Path $OU_afdelingen_path
New-ADOrganizationalUnit -Name "Directie" -Path $OU_afdelingen_path


 # ===== Gebruikers importeren via CSV  ===== #
 $onderdelen = @('Verkoop','IT Administratie','Administratie', 'Ontwikkeling', 'Directie')
 $teller = 0
 
 $users = Import-Csv -Path '.\Desktop\users.csv'  -Delimiter ";"        # -> best da t we het CSV bestand online pushen en hiervan de data halen denk ik
 foreach($user in $users) {
     [string] $firstname = $user.firstname
     [string] $lastname = $user.lastname
     [string] $full_name = "$firstname $lastname"  
     [string] $OU_afdelingen_path = "OU=$($onderdelen[$teller]),OU=afdelingen,DC=$domain,DC=Local"
 
 
     # Folder maken voor iedereen
     mkdir C:\Share\$full_name 
 
     New-ADuser -Name $full_name -Path $OU_afdelingen_path -AccountPassword (Read-Host "Geef wachtwoord van $full_name" -AsSecureString "AccountPassword") -PasswordNeverExpires $true -Enabled $true -ProfilePath "C:\Share\$full_name" -ChangePasswordAtLogon $false `
        -UserPrincipalName "$firstname.$lastname@$domain.local" 


     write-host "Gebruiker $full_name werd aangemaakt." -BackgroundColor White -ForegroundColor Red
     
     $teller++
     }

 # ===== Werkstations (computers) toevoegen aan OUs  ===== #
 [string]$domain = $env:USERDOMAIN
 [string] $OU_afdelingen_path = “OU=Afdelingen,DC=$domain,DC=Local"

 [string]$naam_pc1 = read-host "Geef de naam in voor de computer in OU: IT Administratie"
 New-ADComputer -Name "$naam_pc1" -Path "OU=IT Administratie,$OU_afdelingen_path" 
 write-host "Computer $naam_pc1 werd succesvol aangemaakt in IT Administratie!" -BackgroundColor White -ForegroundColor Red 

 [string]$naam_pc2 = read-host "Geef de naam in voor de computer in OU: Ontwikkeling"
 New-ADComputer -Name "$naam_pc2" -Path "OU=Ontwikkeling,$OU_afdelingen_path" 
 write-host "Computer $naam_pc1 werd succesvol aangemaakt in Ontwikkeling!" -BackgroundColor White -ForegroundColor Red 


 [string]$naam_pc3 = read-host "Geef de naam in voor de computer in OU: Verkoop"
 New-ADComputer -Name "$naam_pc3" -Path "OU=Verkoop,$OU_afdelingen_path"
 write-host "Computer $naam_pc1 werd succesvol aangemaakt in Verkoop!" -BackgroundColor White -ForegroundColor Red 


 [string]$naam_pc4 = read-host "Geef de naam in voor de computer in OU: Administratie"
 New-ADComputer -Name "$naam_pc4" -Path "OU=Administratie,$OU_afdelingen_path"
 write-host "Computer $naam_pc1 werd succesvol aangemaakt in Administratie!" -BackgroundColor White -ForegroundColor Red 


 [string]$naam_pc5 = read-host "Geef de naam in voor de computer in OU: Directie"
 New-ADComputer -Name "$naam_pc5" -Path "OU=Directie,$OU_afdelingen_path"
 write-host "Computer $naam_pc1 werd succesvol aangemaakt in Directie!" -BackgroundColor White -ForegroundColor Red 


# ===== Beleidsregels toevoegen voor OUs  ===== #

Import-Module GroupPolicy 

# -> Weigeren toegang tot Control Panel 
New-GPO -Name NoControlPanel

$gpo_ControlPanel = Get-GPO -Name NoControlPanel

 New-GPLink -Name NoControlPanel -Target "OU=Ontwikkeling,$OU_afdelingen_path"  -linkEnabled yes
 New-GPLink -Name NoControlPanel -Target "OU=Verkoop,$OU_afdelingen_path" -linkEnabled yes
 New-GPLink -Name NoControlPanel -Target "OU=Administratie,$OU_afdelingen_path" -linkEnabled yes
 New-GPLink -Name NoControlPanel -Target "OU=Directie,$OU_afdelingen_path" -linkEnabled yes

$gpo_ControlPanel | Set-GPRegistryValue -Key HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -ValueName NoControlPanel -Type String -Value 0 

# -> Verwijderen games link menu ("Xbox game bar")
New-GPO -Name NoStartMenuMyGames

$gpo_GamesBar = Get-GPO -Name NoStartMenuMyGames

# Link de GPO met de juiste OU's
New-GPLink -Name NoStartMenuMyGames -Target "OU=Ontwikkeling,$OU_afdelingen_path" -linkEnabled yes
New-GPLink -Name NoStartMenuMyGames -Target "OU=Verkoop,$OU_afdelingen_path" -linkEnabled yes
New-GPLink -Name NoStartMenuMyGames -Target "OU=Administratie,$OU_afdelingen_path" -linkEnabled yes
New-GPLink -Name NoStartMenuMyGames -Target "OU=Directie,$OU_afdelingen_path" -linkEnabled yes
New-GPLink -Name NoStartMenuMyGames -Target "OU=IT Administratie,$OU_afdelingen_path" -linkEnabled yes

$gpo_GamesBar | Set-GPRegistryValue -Key HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -ValueName NoStartMenuMyGames -Type DWord -Value 1 


# -> Verwijderen toegang properties-field van LAN-adapter
New-GPO -Name NC_LanProperties

$gpo_LANproperties = Get-gpo -Name NC_LanProperties

# Link de GPO met de juiste OU's
New-GPLink -Name NC_LanProperties -target "OU=Administratie,$OU_afdelingen_path" -linkEnabled yes
New-GPLink -Name NC_LanProperties -target "OU=Verkoop,$OU_afdelingen_path" -linkEnabled yes

$gpo_LANproperties | Set-GPRegistryValue -key "HKCU\Software\Policies\Microsoft\Windows\Network Connections" -ValueName NC_LanProperties -Value 0 -Type DWord


# ===== File System: DFS ===== #
write-host "Installing DFS File System" -ForegroundColor Red -BackgroundColor White 
Install-WindowsFeature FS-DFS-Namespace, RSAT-DFS-Mgmt-Con

# Installeren DFS 
install-windowsFeature FS-DFS-Namespace, FS-DFS-Replication -IncludeManagementTools

# Aanmaken DFS root map + namespace directory
mkdir C:\DFSRoot\NameSpace1 

# Aanmaken van een nieuwe share
new-smbShare -name NameSpace1$ -Path C:\DFSRoot\NameSpace1 -FullAccess "Authenticated Users"

# Aanmaken nieuwe DFS root
New-DfsnRoot -TargetPath "\\agentsmith\NameSpace1$" -Type DomainV2 -Path "\\thematrix.local\NameSpace1"

# === USER ===

# Aanmaken map voor de user
mkdir C:\NameSpace1\Client1 

# Share voor Client
new-SmbShare -Name Client1$ -Path C:\NameSpace1\Client1 -FullAccess "Authenticated Users"

# Nieuwe DFS folder voor Client
New-DfsnFolder -Path "\\thematrix.local\NameSpace1\Client1" -TargetPath "\\agentsmith\Client1$" -EnableTargetFailback $true

# === SERVER === 
mkdir C:\NameSpace1\Server1 

New-SmbShare -Name Server1$ -Path C:\NameSpace1\Server1 -FullAccess "Authenticated Users"

New-dfsnFolder -Path "\\thematrix.local\NameSpace1\Server1" -TargetPath "\\agentsmith\Server1$" -EnableTargetFailback $true

write-host "Controleer of dit allemaal goed is verlopen door op de server/client in file explorer te gaan naar het pad \\thematrix.local\NameSpace1.
Hier zou je 2 folders moeten zien staan. Test uit door het toevoegen van een bestand of dit bestand ook te zien is aan de server/client-kant!" -ForegroundColor Red -BackgroundColor White

# Aanmaken container voor exchange 2016
New-ADObject -Name "System Management" -Type "container" -Path "CN=System,DC=thematrix,DC=Local" 

New-ADuser -Name "email_admin" -Path "OU=IT Administratie,$OU_afdelingen_path" -AccountPassword (Read-Host "Geef wachtwoord van email_admin" -AsSecureString "AccountPassword") -PasswordNeverExpires $true -Enabled $true -ProfilePath "C:\Share\email_admin" -ChangePasswordAtLogon $false `
-UserPrincipalName "email_admin@thematrix.local" 


$groepen = @("Administrators", "Domain Admins", "Domain Users", "Enterprise Admins", "Group Policy Creator Owners", "Organization Management", "Schema Admins")

[int] $counter = 0
foreach($groep in $groepen) {
   Add-ADGroupmember -Identity "$($groepen[$counter])" -Members "email_admin"
  [int] $counter++
}

write-host "Vergeet de user niet verder te configureren! zie youtube" -BackgroundColor White -ForegroundColor Red

# ==== EXTENDEN VAN AD SCHEMA ==== 
$dest = "./Desktop/SCCM.exe"
$url = "https://download.microsoft.com/download/8/8/8/888d525d-5523-46ba-aca8-4709f54affa8/MEM_Configmgr_2103.exe"

Invoke-WebRequest -Uri $url -OutFile $dest 
Start-Process -FilePath $dest /quiet

# Aanmaken DNS Delegation
write-host "Aanmaken DNS Delegation..." -ForegroundColor Red -BackgroundColor White 
Add-DnsServerZoneDelegation -NameServer "morpheus.thematrix.local" -IPAddress "192.168.76.98" -Name "thematrix.local" -ChildZoneName "morpheus" -PassThru -Verbose 

# Van de AD-server een router maken (INTERNET OP ANDERE VM's)
write-host "Installeren van Remote Access Role..." -BackgroundColor White -ForegroundColor Red 
Install-WindowsFeature RemoteAccess -IncludeManagementTools

write-host "Installeren Powershell-commando's voor Remote Acces..." -BackgroundColor White -ForegroundColor Red 
Install-WindowsFeature RSAT-RemoteAccess-Powershell

Write-Host "Installeren van de routing role..."
Install-WindowsFeature Routing -Restart

# === DHCP ===

# Installeren DHCP role
write-host "Installeren DHCP Role..." -BackgroundColor White -ForegroundColor Red 
Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools 

# DHCP Service restarten
write-host "Heropstarten DHCP server..." -BackgroundColor White -ForegroundColor Red 
Restart-Service dhcpserver 

# Autoriseren DHCP server binnen AD
#Add-DhcpServerInDC -DnsName agentsmith.thematrix.local -IPAddress 192.168.76.97

# Activeren DHCP op adapter LAN

   # Ophalen interface
   $nic = Get-NetAdapter -Name LAN

   # Verwijder 'oude' gateway
   $nic | Remove-netRoute -Confirm:$false 

   # DHCP activeren
   $nic | Set-NetIPInterface -dhcp Enabled 

   # DNS severs instellen via DHCP
   $nic | Set-DnsClientServerAddress -ResetServerAddress 


# Aanmaken DHCP server scope
write-host "Aanmaken DHCP Scope..." -BackgroundColor White -ForegroundColor Red 
Add-DhcpServerV4Scope -Name "DHCP Scope" -StartRange 192.168.76.3 -EndRange 192.168.76.250 -SubnetMask 255.255.255.0 -State Active 

# Aanmaken reservatie voor EXCHANGE
$mac_exchange = read-host "Geef hier het mac-adres van de exchange server"
Add-DhcpServerv4Reservation -ScopeId 192.168.76.0 -IPAddress 192.168.76.101 -ClientId $mac_exchange

# Aanmaken reservatie voor CLIENT
$mac_client = read-host "Geef hier het mac-adres van de client in"
Add-DhcpServerv4Reservation -ScopeId 192.168.76.0 -IPAddress 192.168.76.102 -ClientId $mac_client

# Dns toevoegen
set-dhcpserverv4optionvalue -ScopeId 192.168.76.98 -DnsDomain "thematrix.local" -Router 192.168.76.1 

# Lease duration 
set-DhcpServerv4Scope -ScopeId 192.168.76.0 -LeaseDuration 8:00:00:00