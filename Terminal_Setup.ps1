# Misha's Windows Terminal Setup Script

# Part 1: Setting up PowerShell.
# 1.1: Allowing PowerShell to run scripts
Write-Host "Turning on Remote signed scripts in PowerShell."
set-executionpolicy remotesigned
Write-Host "You may now run PowerShell scripts"
# 1.2: Making sure Winget packages work
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

# Part 2: Installing Chocolatey
# I find setting up Winget on a fresh install of Windows can be finicky, so I use the classic PowerShell install method for chocolatey
# That way, the script doesn't crash if the Add-AppxPackage command fails
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Chocolatey requires refreshing the shell and environment variables in order to function
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Part 3: Installing packages via Chocolatey
# This section cats the packages.txt into an array
# It's very important to ensure packages.txt is formatted correctly:
# Each package should be listed on its own line
$Packages = @(Get-Content .\packages.txt)
foreach ($Package in $Packages)
{
  choco install $Package -y
}

# Schedule Chocolatey Daily Upgrades
# Copy Chocolatey Upgrade Scripts to User Folder to be Scheduled
Copy-Item -Path '.\Tools\ChocolateyUpgrade.ps1' -Destination '$env:USERPROFILE\Scripts'
# Add Upgrade Script to Task Scheduler
$action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument '-Command "$env:USERPROFILE\Scripts\ChocolateyUpgrade.ps1"'
$time = New-ScheduledTaskTrigger -Daily -At 4:30PM
$STPrin = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
Register-ScheduledTask -User "System" -Trigger $time -Action $action -Principal $STPrin -TaskPath "Chocolatey" -TaskName "ChocolateyUpgrade" -Description "Upgrades Chocolatey and all its packages"

# Refresh shell one last time
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")