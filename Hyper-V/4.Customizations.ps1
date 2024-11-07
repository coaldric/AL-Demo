Get-Lab -List

Get-LabVMStatus

Install-LabSoftwarePackage -Path $global:labSources\SoftwarePackages\VSCodeSetup-x64-1.94.2.exe -ComputerName D1SL6-MAINWK1 -CommandLine /VERYSILENT

# Enter-PSSession vs Enter-LabPSSession 
Enter-PSSession -ComputerName D1SL6-MAINDC1
Enter-LabPSSession -ComputerName D1SL6-MAINDC1

Invoke-LabCommand -ComputerName D1SL6-MAINDC1 -ScriptBlock {  (Get-ComputerInfo).csname  } -PassThru

$Var = 'Hello'
Invoke-LabCommand -ComputerName D1SL6-MAINDC1 -ScriptBlock {  "$Var World"  } -PassThru #local variable not available
Invoke-LabCommand -ComputerName D1SL6-MAINDC1 -ScriptBlock {  "$using:Var World"  } -PassThru #can't locally debug!
Invoke-LabCommand -ComputerName D1SL6-MAINDC1 -ScriptBlock {  "$Var World"  } -PassThru -Variable (Get-Variable -name Var) #we can pass variables instead