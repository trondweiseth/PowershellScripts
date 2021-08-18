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
        "E:\Program Files (x86)\"
        "$HOME\AppData\Roaming\"
        "$HOME\AppData\Local\"
    )

    $date = get-date -Format dd.MM.yyyy
    $registrykeys = [System.Collections.ArrayList]@()
    $folderlist = [System.Collections.ArrayList]@()

    foreach ($registrypath in $registrypaths) {
        if ($registrykey = Get-ChildItem registry::$registrypath | Where-Object { $_.Name -imatch "$softwarename" } | Select-Object -ExpandProperty Name) {
            foreach ($regstring in $registrykey) {
                $arrayID = $registrykeys.Add($regstring)
            }
        }
    }

    if ($registrykeys) {
        $regselection = $registrykeys | Out-GridView -PassThru -Title "Registry Key(s)"
        Write-Host -ForegroundColor Green -BackgroundColor Black "Registry key(s):"
        $regselection | ForEach-Object { write-host -ForegroundColor Cyan $_ }
        Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove registry key? (Y\N):"
        $answer = Read-Host
        if ($answer -eq "y") {
            if ($RegistryBackup) {
                if (!(Test-Path "C:\RegistryBackup_$date")) {
                    [void](New-Item -Path C:\ -ItemType Directory -Name "RegistryBackup_$date")
                }
                $backupfolder = "C:\RegistryBackup_$date"
                $regselection | ForEach-Object {
                    $regbackup = $_.Replace('\', '_')
                    [void](reg export $_ $backupfolder\$regbackup.reg /y)
                    Write-Host -ForegroundColor Green "Backup of registry key: " ; write-host -ForegroundColor Cyan "$backupfolder\$regbackup.reg"
                }
            }
            $regselection | ForEach-Object {
                Remove-Item Registry::$_ -Recurse
                Write-Host -NoNewline -ForegroundColor Red "Registry key removed : "; write-host -ForegroundColor Cyan $_
            }
        }
    }

    foreach ($folderpath in $folderpaths) {
        if ($softwarepath = Get-ChildItem -Path $folderpath | Where-Object { $_.Name -imatch "$softwarename" } | Select-Object -ExpandProperty FullName) {
            foreach ($folder in $softwarepath) {
                $arrayID = $folderlist.Add($folder)
            }
        }
    }

    if ($folderlist) {
        $folderselection = $folderlist | Out-GridView -PassThru -Title "Folder(s)"
        Write-Host -ForegroundColor Green -BackgroundColor Black "Found folder(s): "
        $folderselection | ForEach-Object { write-host -ForegroundColor Cyan $_ }
        Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove folder? (Y\N):"
        $answer = Read-Host
        if ($answer -eq "y") {
            $folderselection | ForEach-Object {
                Remove-Item $_ -Force
                Write-Host -NoNewline -ForegroundColor Red "Folder removed: " ; write-host -ForegroundColor Cyan $_
            }
        }
    }
}
