@echo off

REM Misha's Windows Terminal Setup Script

REM - Get permissions
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:Introductions
REM Introductions
echo These scripts are designed to help speed up Windows and PowerShell setup.
echo Please ensure you have selected your Chocolatey packages before running the script.
goto Prompt

:Prompt
	set pack="n"
	set /p pack=Have you selected which packages you wish to install? (Y or N) 
	if /I "%pack%"=="yes" goto Script
	if /I "%pack%"=="y" goto Script
	if /I "%pack%"=="no" goto NoPackages
	if /I "%pack%"=="n" goto NoPackages

:Script

powershell.exe -ExecutionPolicy Bypass -Command "%~dp0Terminal_Setup.ps1"
goto OptionalSettings

:OptionalSettings
REM - Not everyone will want these settings
REM - Give the option to bail out of the script here
	echo This script has optional settings:
	echo Installing Steam
	echo Installing Discord
	echo Z for PowerShell (Requires PowerShell 7)
	echo Oh-My-Posh (Requires PowerShell 7)
	echo My preconfigured Terminal settings (Requires PowerShell 7)
	echo Windows Subsystem for Linux
	echo Selecting optional settings will allow you to pick and choose which of these options to install.
	echo Choosing not to select optional settings will end the script.
	set Optional="n"
	set /p Optional=Would you like to select optional settings? (Y or N) 
	if /I "%Optional%"=="yes" goto SteamPrompt
	if /I "%Optional%"=="y" goto SteamPrompt
	if /I "%Optional%"=="no" goto End
	if /I "%Optional%"=="n" goto End

:SteamPrompt
REM - Install Steam via Winget
	set SteamInstall="n"
	set /p SteamInstall=Would you like to install Steam? (Y or N) 
	if /I "%SteamInstall%"=="yes" goto Install_Steam
	if /I "%SteamInstall%"=="y" goto Install_Steam
	if /I "%SteamInstall%"=="no" goto DiscordPrompt
	if /I "%SteamInstall%"=="n" goto DiscordPrompt
	
:Install_Steam
winget install --id Valve.Steam -e  --accept-package-agreements
goto DiscordPrompt
	
:DiscordPrompt
REM - Install Discord via Winget
	set DiscordInstall="n"
	set /p DiscordInstall=Would you like to install Discord? (Y or N) 
	if /I "%DiscordInstall%"=="yes" goto Install_Discord
	if /I "%DiscordInstall%"=="y" goto Install_Discord
	if /I "%DiscordInstall%"=="no" goto Zprompt
	if /I "%DiscordInstall%"=="n" goto Zprompt
	
:Install_Discord
winget install --id Discord.Discord -e  --accept-package-agreements
goto Zprompt

:Zprompt
REM - Install Z prompt
	set Zshell="n"
	set /p Zshell=Would you like to install Z for PowerShell? (Y or N) 
	if /I "%Zshell%"=="yes" goto Install_Z
	if /I "%Zshell%"=="y" goto Install_Z
	if /I "%Zshell%"=="no" goto PoshPrompt
	if /I "%Zshell%"=="n" goto PoshPrompt

:Install_Z
pwsh.exe -Command "Install-Module z -AllowClobber"
pwsh.exe -Command "echo 'Import-Module z' | Out-File $PROFILE -append -Encoding utf8"
goto PoshPrompt

:PoshPrompt
REM - Install Oh-My-Posh
	set Posh="n"
	set /p Posh=Would you like to install Oh-My-Posh for PowerShell? (Y or N) 
	if /I "%Posh%"=="yes" goto Install_Posh
	if /I "%Posh%"=="y" goto Install_Posh
	if /I "%Posh%"=="no" goto TerminalPrompt
	if /I "%Posh%"=="n" goto TerminalPrompt

:Install_Posh
REM - Install nerd fonts for Oh-My-Posh
pwsh.exe -Command "%~dp0Tools\Firacode_Installer.ps1"
REM - Install Oh-My-Posh
pwsh.exe -Command "winget install JanDeDobbeleer.OhMyPosh -s winget"
pwsh.exe -Command "Copy-Item -Path '.\Tools\kaliwin.omp.json' -Destination '$env:POSH_THEMES_PATH\kaliwin.omp.json'"
pwsh.exe -Command "Get-Content '.\Tools\Posh_Profile.txt' | Out-File $PROFILE -append -Encoding utf8"
goto TerminalPrompt

:TerminalPrompt
REM - Install Windows Terminal using my preconfigured settings
	echo My preconfigured Terminal settings include:
	echo  - Quake Mode enabled on Windows Startup
	echo  - My default Terminal profiles and fonts
	set Term="n"
	set /p Term=Would you like to install Oh-My-Posh for PowerShell? (Y or N) 
	if /I "%Term%"=="yes" goto Install_Terminal_Settings
	if /I "%Term%"=="y" goto Install_Terminal_Settings
	if /I "%Term%"=="no" goto WSLPrompt
	if /I "%Term%"=="n" goto WSLPrompt

:Install_Terminal_Settings
REM - Setting up the preconfigured Terminal settings
REM - Copying settings.json Tools\Windows Terminal Config to the Windows Terminal folder
copy "%~dp0Tools\Windows_Terminal_Config\settings.json" "%USERPROFILE%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
REM - Copying the Terminal Quake Mode command to shell:Startup
copy "%~dp0Tools\Windows_Terminal_Config\Terminal Quake Mode.lnk" "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
goto WSLPrompt

:WSLPrompt
REM - Install Linux prompt
	set WSL="n"
	set /p WSL=Would you like to install Linux via WSL? (Y or N) 
	if /I "%WSL%"=="yes" goto Linux_Install
	if /I "%WSL%"=="y" goto Linux_Install
	if /I "%WSL%"=="no" goto End
	if /I "%WSL%"=="n" goto End
	
:Linux_Install
REM - Install Linux via WSL2
echo Installing WSL2
powershell.exe wsl --install
Goto End

:End
echo You have reached the end of the script. Please restart your PC if needed, and set up everything else as desired.
echo.
echo Press any key to exit the script . . .  
Pause > nul
exit

REM ==============================================================================================================================
REM 			Conditional endings
REM ==============================================================================================================================


:NoPackages
REM - If the user has not selected packages, tell them to select packages prior to running the script as admin
echo The script has not run.
echo In the 'Tools' folder there is a Package Selection shortcut for an interactive checklist of the most common packages.
echo There is both an online and offline version of this file.
echo Please select your packages there and add them to 'packages.txt' for the script to fetch them.
echo Remember to list all your packages on one line separated by a space.
echo And remember to run this script as administrator!
echo Press any key to exit . . .  
Pause > nul
exit