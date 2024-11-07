# Connect-AzAccount

# Get-LabAzureAvailableRoleSize -DisplayName 'Central US' | where {($_.gen2supported -eq $true) -and ($_.Name -like "Standard_D*5")}
# Successful Validation:
# 31minutes: Add-LabMachineDefinition -Name Server1 -Memory 4GB -OperatingSystem 'Windows Server 2019 Datacenter (Desktop Experience)' -AzureRoleSize Standard_D2_v5 

Import-Module AutomatedLab, Az

New-LabDefinition -Name 'D3BSL6' -DefaultVirtualizationEngine Azure

Add-LabAzureSubscription -Environment 'AzureCloud' -DefaultLocationName 'Central US' -SubscriptionName 'yoursubscriptionname' 

Add-LabMachineDefinition -Name Server1 -OperatingSystem 'Windows Server 2019 Datacenter (Desktop Experience)' -AzureRoleSize Standard_D2_v5  -Roles RootDC -DomainName 'fabrikam.com'
Add-LabMachineDefinition -Name Server2 -OperatingSystem 'Windows Server 2019 Datacenter (Desktop Experience)' -AzureRoleSize Standard_D2_v5  -Roles FileServer -IsDomainJoined

Install-Lab

