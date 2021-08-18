Function Uninstall-CleanUp() {
    param(
        [Parameter(Position = 0, Mandatory = $true)][string]$softwarename,
        [switch]$RegistryBackup
    )

    $registrypaths = @(
        "HKEY_CURRENT_USER\SOFTWARE\"
        "HKEY_CURRENT_USER\SOFTWARE\Classes\"
        "HKEY_LOCAL_MACHINE\SOFTWARE\"
        "HKEY_USERS\.DEFAULT\Software\"
        "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\"
    )

    $folderpaths = @(
        "C:\Program Files\"
        "C:\Program Files (x86)\"
        "E:\Program Files\"
        "E:\Program Files (x86)"
        "$HOME\AppData\Roaming"
        "$HOME\AppData\Local"
    )

    $date = get-date -Format dd.MM.yyyy

    foreach ($registrypath in $registrypaths) {
        if ($registrykey = Get-ChildItem registry::$registrypath | Where-Object { $_.Name -imatch "$softwarename" } | Select-Object -ExpandProperty Name) {
            if ($registrykey) {
                Write-Host -ForegroundColor Green -BackgroundColor Black "Registry key:"
                $registrykey
                Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove registry key? (Y\N):"
                $answer = Read-Host
                if ($answer -eq "y") {
                    if ($RegistryBackup) {
                        if (!(Test-Path "C:\RegistryBackup_$date")) {
                            [void](New-Item -Path C:\ -ItemType Directory -Name "RegistryBackup_$date")
                        }
                        $backupfolder = "C:\RegistryBackup_$date"
                        $registrykey | foreach {
                            $regbackup = $_.Replace('\', '_')
                            [void](reg export $_ $backupfolder\$regbackup.reg /y)
                            Write-Host -ForegroundColor Green "Backup of registry key: $backupfolder\$regbackup.reg"
                        }
                    }
                    $registrykey | foreach {
                        Remove-Item Registry::$_ -Recurse
                        Write-Host -ForegroundColor Red "Registry key removed: $_`n"
                    }
                }
            }
        }
    }

    foreach ($folderpath in $folderpaths) {
        $softwarepath = Get-ChildItem -Path $folderpath | Where-Object { $_.Name -imatch "$softwarename" } | Select-Object -ExpandProperty FullName
        if ($softwarepath) {
            Write-Host -ForegroundColor Green -BackgroundColor Black "Found folder: $softwarepath"
            Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove folder? (Y\N):"
            $answer = Read-Host
            if ($answer -eq "y") {
                Remove-Item $softwarepath -Force
                Write-Host -ForegroundColor Red "Folder removed: $softwarepath"
            }
        }
    }
    if (!$softwarepath) {
        Write-Host -ForegroundColor Red "No matching folders."
    }
    if (!$registrykey) {
        Write-Host -ForegroundColor Red "No matching registry key."
    }
}
