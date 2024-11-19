# 12:55:01|04:02:11|02:57:06.443| Setting up the lab took 4 hours, 2 minutes and 11 seconds
# 12:55:01|04:02:11|02:57:06.446| Lab name is 'D2GCC' and is hosted on 'Azure'. There are 10 machine(s) and 1 network(s) defined.

Import-Module AutomatedLab, Az

# Set the default values for the AutomatedLab module
# Set-PSFConfig -Module AutomatedLab -Name AzureRetryCount -Value '10'
# Set-PSFConfig -Module AutomatedLab -Name InvokeLabCommandRetries -Value '5'
# Set-PSFConfig -Module AutomatedLab -Name InvokeLabCommandRetryIntervalInSeconds -Value 15
# Set-PSFConfig -Module AutomatedLab -Name Timeout_TestPortInSeconds -Value 15

#Get rid of the azure storage secrets warning
Update-AzConfig -DisplaySecretsWarning $false

# Create the automated lab sources folder if it does not exist
# New-LabSourcesFolder -DriveLetter E

# Create the Azure Lab Sources Storage (will skip if already exists)
# New-LabAzureLabSourcesStorage -LocationName "Central US"

# Sync the lab sources to the Azure Storage Account, skip isos, not needed for Hyper-V
# Sync-LabAzureLabSources

$labname = "D2BGCC" #the lab name contains invalid characters. Only A-Z, a-z and 0-9 are allowed.
$domain = "dev.contoso.com"
$addressspace = '13.13.0.0/16'
$firsttwooctets = $addressspace.Substring(0,5)

New-LabDefinition -name $labname -DefaultVirtualizationEngine Azure

Add-LabAzureSubscription -Environment 'AzureCloud' -DefaultLocationName 'Central US' -SubscriptionName 'yoursubscriptionname' 

Add-LabVirtualNetworkDefinition -Name $labname -AddressSpace $addressspace

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:Memory' = 2048MB
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2019 Datacenter (Desktop Experience)'
    'Add-LabMachineDefinition:DomainName' = $domain
    'Add-LabMachineDefinition:DnsServer1' = "$firsttwooctets.10.10"
    'Add-LabMachineDefinition:AzureProperties' = @{
        AutoshutdownTime          =   '2000'
        AutoshutdownTimeZoneID    =   'UTC'
        }
    'Add-LabMachineDefinition:AzureRoleSize' = 'Standard_D2_v5' # Will likely need to define property for use on Azure GCC/GCCH

}                                                                                                                           

$ROOT = Get-LabMachineRoleDefinition -Role RootDC @{
    DomainFunctionalLevel = 'Win2012R2'
    ForestFunctionalLevel = 'Win2012R2'
    SiteName = 'Seattle'
    SiteSubnet = "$firsttwooctets.10.0/24"
}

$FRA = Get-LabMachineRoleDefinition -Role DC @{
    SiteName = 'Frankfurt'
    SiteSubnet = "$firsttwooctets.20.0/24"
}

$TOK = Get-LabMachineRoleDefinition -Role DC @{
    SiteName = 'Tokyo'
    SiteSubnet = "$firsttwooctets.30.0/24"
}
#DCs
Add-LabMachineDefinition -name $labname-SEADC1 -Roles $ROOT -IpAddress "$firsttwooctets.10.10" -DnsServer2 "$firsttwooctets.10.11"
Add-LabMachineDefinition -name $labname-SEADC2 -OperatingSystem "Windows Server 2022 Datacenter"  -Roles DC -IpAddress "$firsttwooctets.10.11" -DnsServer1 "$firsttwooctets.10.11" -DnsServer2 "$firsttwooctets.10.10" 
Add-LabMachineDefinition -name $labname-FRADC1 -Roles $FRA -IpAddress "$firsttwooctets.20.10" -DnsServer1 "$firsttwooctets.20.10" -DnsServer2 "$firsttwooctets.10.10"
Add-LabMachineDefinition -name $labname-FRADC2 -Roles $FRA -IpAddress "$firsttwooctets.20.11" -DnsServer1 "$firsttwooctets.20.11" -DnsServer2 "$firsttwooctets.10.10"
Add-LabMachineDefinition -name $labname-TOKDC1 -Roles $TOK -IpAddress "$firsttwooctets.30.10" -DnsServer1 "$firsttwooctets.30.10" -DnsServer2 "$firsttwooctets.10.10"
Add-LabMachineDefinition -name $labname-TOKDC2 -Roles $TOK -IpAddress "$firsttwooctets.30.11" -DnsServer1 "$firsttwooctets.30.11" -DnsServer2 "$firsttwooctets.10.10"

#FSs
Add-LabMachineDefinition -name $labname-FRAFS1 -Roles FileServer -IpAddress "$firsttwooctets.20.30" -DnsServer2 "$firsttwooctets.20.11"

#SQL
Add-LabMachineDefinition -name $labname-FRASQL -Roles SQLServer2019 -IpAddress "$firsttwooctets.20.31" -DnsServer2 "$firsttwooctets.20.11"

#Clients
Add-LabMachineDefinition -name $labname-SEAWK1 -OperatingSystem 'Windows 10 Enterprise' -IpAddress "$firsttwooctets.10.100" -IsDomainJoined -DnsServer2 "$firsttwooctets.10.11" -Memory 1024MB
Add-LabMachineDefinition -name $labname-TOKWK2 -OperatingSystem 'Windows 11 Enterprise' -IpAddress "$firsttwooctets.30.101" -IsDomainJoined -DnsServer2 "$firsttwooctets.30.11" -Memory 1024MB

#install the lab
Install-Lab

Show-LabDeploymentSummary -Detailed
