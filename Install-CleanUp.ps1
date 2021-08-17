Function Install-CleanUp() {
    param(
        [Parameter(Position = 0, Mandatory = $true)][string]$softwarename
    )

    $registrypaths = @(
        'HKEY_CURRENT_USER\SOFTWARE\'
        'HKEY_LOCAL_MACHINE\SOFTWARE\'
        'HKEY_USERS\.DEFAULT\Software\'
        'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\'
    )

    $folderpaths = @(
        'C:\Program Files\'
        'C:\Program Files (x86)\'
        'E:\Program Files\'
        'E:\Program Files (x86)'
    )

    foreach ($registrypath in $registrypaths) {
        if ($registrykey = Get-ChildItem registry::$registrypath | Where-Object { $_.Name -imatch $softwarename } | Select-Object -ExpandProperty PSPath) {
            if ($registrykey) {
                Write-Host -ForegroundColor Green -BackgroundColor Black "Registry key: $registrykey"
                Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove registry key? (Y\N):"
                $answer = Read-Host
                if ($answer -eq "y") {
                    Remove-Item $registrykey
                    Write-Host -ForegroundColor Red "Registry key removed: $registrykey`n"
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
    elseif (!registrykey) {
        Write-Host -ForegroundColor Red "No matching registry key."
    }
}
