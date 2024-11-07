# 14:39:20|02:48:53|00:00:45.495| Setting up the lab took 2 hours, 48 minutes and 53 seconds                              
# 14:39:20|02:48:53|00:00:45.497| Lab name is 'D1BSL6' and is hosted on 'HyperV'. There are 10 machine(s) and 1 network(s) defined.

$labname = "D1BSL6" #lab name can only contain characters A-Z, a-z and 0-9.
$domain = "dev.contoso.com"
$addressspace = '13.14.0.0/16'
$firsttwooctets = $addressspace.Substring(0,5)

Import-Module AutomatedLab

New-LabDefinition -name $labname -DefaultVirtualizationEngine HyperV -VmPath C:\AutomatedLab-VMs

Add-LabVirtualNetworkDefinition -Name $labname -AddressSpace $addressspace

Add-LabIsoImageDefinition -Name SQLServer2019 -Path $labSources\ISOs\en_sql_server_2019_standard_x64_dvd_814b57aa.iso

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:Memory' = 2048MB
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2019 Datacenter (Desktop Experience)'
    'Add-LabMachineDefinition:DomainName' = $domain
    'Add-LabMachineDefinition:DnsServer1' = "$firsttwooctets.10.10"
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