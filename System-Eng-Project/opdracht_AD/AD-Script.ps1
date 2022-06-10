 # ====================================================================== # 
 # ============== Setting up Active Directory Script ============== # 
 # ====================================================================== # 

 # ====================================================================== # 
 # ============== AD-Script 1: Changing Hostname & Static IP's ============== # 
 # ====================================================================== # 

 clear

 # ===== Configuratie ===== #
 
 # => variabelen IP-adressen
 [string] $ipv4 = "192.168.76.97"
 [string] $ipv6 = "2001:db8:1:3::97"
 [string] $prefix = "24"
 [string] $gateway = "192.168.76.1"
 [string] $DNS = "192.168.76.97"
 
 # => Instellen statische IP-adressen
 $lan_adapter_iface_index = (Get-NetAdapter -Name "LAN").ifIndex
 
 New-NetIPAddress -AddressFamily IPv4 -IPAddress $ipv4 -PrefixLength $prefix -InterfaceIndex $lan_adapter_iface_index -DefaultGateway $gateway 
 New-NetIPAddress -InterfaceIndex $lan_adapter_iface_index -AddressFamily IPv6 -IPAddress $ipv6 -PrefixLength 64 
 Set-DnsClientServerAddress -InterfaceIndex $lan_adapter_iface_index -ServerAddresses ("$DNS", "192.168.76.98")
 
 # => wijzigen naam computer 
 [string] $hostname = Read-Host  'Enter the hostname for this server' -BackgroundColor White -ForegroundColor Red 
 write-host "Renaming this PC to the desired hostname..." -ForegroundColor Red -BackgroundColor White 
 Rename-Computer -NewName $hostname -Force -Restart

 # ====================================================================== # 
 # ============== AD-Script 2: Installing AD & Promotion to DC ============== # 
 # ====================================================================== # 
 
 # => Installeren Domein Controller , Configuratie Forest & Promotie DC
 [string] $domain = Read-Host -Prompt 'Enter the domain-name' 

 write-host "Installing Active Directory..." -ForegroundColor Red -BackgroundColor White 
 Add-WindowsFeature AD-Domain-Services -includeManagementTools
 
 Import-Module ADDSDeployment 

 write-host "Promoting this PC to Domain Controller..." -ForegroundColor Red -BackgroundColor White
 write-host "Restarting computer, promotion complete..." -ForegroundColor Red -BackgroundColor White 
 Install-ADDSForest -DomainName "$domain.local" -DomainNetbiosName $domain -installDNS:$false 

Restart-Computer -Force 


 # ====================================================================== # 
 # ============== AD-Script 3: Configuration and Structure Active Directory  ============== # 
 # ====================================================================== # 

 # ===== AD structuur aanmaken ===== #

 [string]$domain = $env:USERDOMAIN
 [string] $OU_afdelingen_path = “OU=Afdelingen,DC=$domain,DC=Local"

# => main OU: AFDELINGEN
New-ADOrganizationalUnit -Name "Afdelingen" -Path "DC=$domain,DC=local"

# => sub-OU's onder AFDELINGEN

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
 write-host "Het werkstation werd succesvol toegevoegd!"

 [string]$naam_pc2 = read-host "Geef de naam in voor de computer in OU: Ontwikkeling"
 New-ADComputer -Name "$naam_pc2" -Path "OU=Ontwikkeling,$OU_afdelingen_path" 

 [string]$naam_pc3 = read-host "Geef de naam in voor de computer in OU: Verkoop"
 New-ADComputer -Name "$naam_pc3" -Path "OU=Verkoop,$OU_afdelingen_path"

 [string]$naam_pc4 = read-host "Geef de naam in voor de computer in OU: Administratie"
 New-ADComputer -Name "$naam_pc4" -Path "OU=Administratie,$OU_afdelingen_path"

 [string]$naam_pc5 = read-host "Geef de naam in voor de computer in OU: Directie"
 New-ADComputer -Name "$naam_pc5" -Path "OU=Directie,$OU_afdelingen_path"

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

## Zoeken naar DFS Namespaces
 $Domein = 'thematrix.local'
 (Get-DfsnRoot -Domain $Domein).Where({$.State -eq 'Online'}) | Select-Object -ExpandProperty Path

 Get-DfsnFolder -Path "\\$Domein\AppRoot\*" | Select-Object -ExpandProperty Path
 Get-DfsnFolder -Path "\\$Domein\DFSRoot\*" | Select-Object -ExpandProperty Path

## Het maken van DFS Link folders
try {
    Get-DfsnFolderTarget -Path "\\$Domein\AppRoot\PowerShell" -ErrorAction Stop
} catch {
    Write-Host "Geen pad gevonde, je kan doordoen" -ForegroundColor Green
}

$NewDFSFolder = @{
    Path = "\\$Domein\AppRoot\PowerShell"
    State = 'Online'
    TargetPath = '\\datacenter\FileShare\PowerShell'
    TargetState = 'Online'
    ReferralPriorityClass = 'globalhigh'
}

New-DfsnFolder @NewDFSFolder

# Kijken of folder bestaat:
Get-DfsnFolderTarget -Path "\\$Domein\AppRoot\PowerShell"

# Nakijken of de nieuwe DFS link werkt in Explorer
Invoke-Expression "explorer '\\$Domein\AppRoot\PowerShell\'"

# Creeër een DFS Folder Target

$NewTPS = @{
    Path = "\$Domein\AppRoot\Powershell"
    TargetPath = '\FileServer01\FileShare\PowerShell'
    State = 'Online'
}

New-DfsnFolderTarget @NewTPS

# Geef members rechten in DFS

Set-DfsrMembership -Groupname " " -Foldername "Folder" -ComputerName "Kevin Benoit" -ReadOnly "True/False"



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

write-host "Vergeet de user niet verder te configureren! zie youtube" -BackgroundColor Whtie -ForegroundColor Red

# ==== EXTENDEN VAN AD SCHEMA ==== 
$dest = ./Desktop/SCCM.exe
$url = "https://download.microsoft.com/download/8/8/8/888d525d-5523-46ba-aca8-4709f54affa8/MEM_Configmgr_2103.exe"

Invoke-WebRequest -Uri $url -OutFile $dest 
Start-Process -FilePath $dest 