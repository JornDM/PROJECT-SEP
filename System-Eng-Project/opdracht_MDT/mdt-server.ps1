
# Nieuwe Deployment Share maken

New-Item -Path "C:\DeploymentShare" -ItemType directory
New-SmbShare -Name "DeploymentShare$" -Path "C:\DeploymentShare" -FullAccess Administrators
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "C:\DeploymentShare" -Description "MDT Deployment Share" -NetworkPath "\\WIN-U3CFGD8CP1U\DeploymentShare$" -Verbose | add-MDTPersistentDrive -Verbose

# Importeer Operating Systeem
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "C:\DeploymentShare"
import-mdtoperatingsystem -path "DS001:\Operating Systems" -SourcePath "F:\" -DestinationFolder "Windows 10 Education x64" -Verbose


# Verwijderen van alle andere OS behalve Windows 10 Education N
remove-item -path "DS001:\Operating Systems\Windows 10 Education in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Enterprise in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Enterprise N in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Pro Education in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Pro Education N in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Pro for Workstations in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Pro in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Pro N for Workstations in Windows 10 Education x64 install.wim" -force -verbose
remove-item -path "DS001:\Operating Systems\Windows 10 Pro N in Windows 10 Education x64 install.wim" -force -verbose

# Nieuwe Task Sequence aanmaken
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "C:\DeploymentShare"
import-mdttasksequence -path "DS001:\Task Sequences" -Name "W10CLIENT" -Template "Client.xml" -Comments "Installatie Win Client" -ID "1" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 10 Education N in Windows 10 Education x64 install.wim" -FullName "Windows User" -OrgName "G12" -HomePage "about:blank" -ProductKey "7NXM9-RCB8F-48R7X-KQKQ8-2GYMY" -AdminPassword "21Admin22" -Verbose

# Updaten van Deployment Share
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "C:\DeploymentShare"
update-MDTDeploymentShare -path "DS001:" -Verbose