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
[string] $DNS = "192.168.76.98"

# => Instellen statische IP-adressen
Get-NetAdapter -Name "Ethernet 2" | Rename-NetAdapter -NewName "LAN"

$lan_adapter_iface_index = (Get-NetAdapter -Name "LAN").ifIndex

New-NetIPAddress -AddressFamily IPv4 -IPAddress $ipv4 -PrefixLength $prefix -InterfaceIndex $lan_adapter_iface_index -DefaultGateway $gateway 
New-NetIPAddress -InterfaceIndex $lan_adapter_iface_index -AddressFamily IPv6 -IPAddress $ipv6 -PrefixLength 64 
Set-DnsClientServerAddress -InterfaceIndex $lan_adapter_iface_index -ServerAddresses ("$DNS", "192.168.76.98")

# => wijzigen naam computer 
[string] $hostname = Read-Host  'Enter the hostname for this server' 
write-host "Renaming this PC to the desired hostname..." -ForegroundColor Red -BackgroundColor White 
Rename-Computer -NewName $hostname -Force -Restart