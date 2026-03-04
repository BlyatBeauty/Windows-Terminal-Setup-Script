# Misha's Windows Terminal Setup Script

# Part 3: Installing packages via Chocolatey
# This section cats the packages.txt into an array
# It's very important to ensure packages.txt is formatted correctly:
# Each package should be listed on its own line
$Packages = @(Get-Content .\packages.txt)
foreach ($Package in $Packages)
{
  choco install $Package -y
}