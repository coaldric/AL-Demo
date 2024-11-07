# https://github.com/AutomatedLab/AutomatedLab/releases
# https://automatedlab.org/en/latest/Wiki/Basic/install/

Install-Module -Name AutomatedLab -AllowClobber -SkipPublisherCheck -Force

New-LabSourcesFolder -DriveLetter D:

Get-LabAvailableOperatingSystem