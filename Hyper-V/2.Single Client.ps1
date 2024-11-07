<#
Deployment Metrics for this script:

Surface Laptop 6 w/ SSD
    7 min w/ new baseimage
    3 min w/ existing baseimage

Crucial X9 SSD (removable)
    16 min w/ new basimage
    7 min w/ existing baseimage

YMMV
#>

New-LabDefinition -Name SingleClient -DefaultVirtualizationEngine HyperV -vmpath C:\AutomatedLab-VMs

Add-LabMachineDefinition -Name Client1 -Memory 1GB -OperatingSystem 'Windows 10 Enterprise'

Install-Lab

Show-LabDeploymentSummary -Detailed