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
 Install-ADDSForest -DomainName "$domain.local" -DomainNetbiosName $domain -installDNS:$true 
 

  






