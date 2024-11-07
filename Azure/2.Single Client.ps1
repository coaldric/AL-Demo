Import-Module AutomatedLab, Az

New-LabDefinition -Name SingleClientAzure -DefaultVirtualizationEngine Azure

Add-LabAzureSubscription -Environment 'AzureCloud' -DefaultLocationName 'Central US' -SubscriptionName 'yoursubscriptionname' 

Add-LabMachineDefinition -Name Client1 -Memory 1GB -OperatingSystem 'Windows 10 Enterprise' -AzureRoleSize Standard_D2_v5

Install-Lab

Show-LabDeploymentSummary -Detailed