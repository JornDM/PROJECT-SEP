# Dit is het configuratie-script dat je moet runnen op de Windows Client zodat hij het domein kan joinen.
# Na het uitvoeren van dit script zal de Client-VM het domein gejoined zijn.
clear

# ===== Configuratie ===== #

# => variabelen IP-adressen
[string] $ipv4 = "192.168.76.102"
[string] $ipv6 = "2001:db8:1:3::97"
[string] $prefix = "24"
[string] $gateway = "192.168.76.97" # -> Deze wordt het ip van de ad server zodat hij internet krijgt.
[string] $DNS = "192.168.76.97"

Get-NetAdapter "Ethernet 2" | Rename-NetAdapter -NewName "LAN"

$lan_adapter_iface_index = (Get-NetAdapter -Name "LAN").ifIndex

New-NetIPAddress -AddressFamily IPv4 -IPAddress $ipv4 -PrefixLength $prefix -InterfaceIndex $lan_adapter_iface_index -DefaultGateway $gateway 
New-NetIPAddress -InterfaceIndex $lan_adapter_iface_index -AddressFamily IPv6 -IPAddress $ipv6 -PrefixLength 64 
Set-DnsClientServerAddress -InterfaceIndex $lan_adapter_iface_index -ServerAddresses ("$DNS", "192.168.76.102")

# Hernoemen van de computer en restart forceren.
[string] $hostname = read-host "Geef de hostname voor deze client in"

Rename-Computer -NewName $hostname 

# Client toevoegen aan het domein.
[string] $domain = read-host "Geef het domein in dat je wenst te joinen"

add-computer -DomainName $domain -Credential "$domain\Administrator" -Restart -Force


