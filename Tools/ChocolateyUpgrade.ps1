# Function to delete the new shortcuts that Chocolatey makes when upgrading packages
function choco {
$CHOCOEXE=$(Get-Command choco.exe).Path
If ([bool]$CHOCOEXE){
    $CHOCOARG1=$Args[0]
    $CHOCOARG2=$Args[1]
    $ALLCHOCOARGS=$Args
    If ($CHOCOARG1 -eq "upgrade" -And [bool]$CHOCOARG2) {
        echo "`nGoing to remove any new shortcuts from desktop generated from now until upgrade finishes`n"
        $StartTime = Get-Date
        & $CHOCOEXE $ALLCHOCOARGS
        $Desktops = "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop"
        $ICONSTOREMOVE=$($Desktops | Get-ChildItem -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $StartTime })
        echo "`nRemoving desktop icons:"
        echo $ICONSTOREMOVE
        $Desktops | Get-ChildItem -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $StartTime } | Remove-Item
    }else {
        & $CHOCOEXE $ALLCHOCOARGS
        }
}else {
    echo "`nUser defined function ""choco"" did not find choco.exe in path. Is choco installed?`n"
    }
}

# Upgrade all Chocolatey packages
choco upgrade all -y

Exit