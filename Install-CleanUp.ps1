Function Install-CleanUp() {
    param(
        [Parameter(Position = 0, Mandatory = $true)][string]$softwarename
    )

    $folderpaths = @(
        'C:\Program Files\'
        'C:\Program Files (x86)\'
        'E:\Program Files\'
        'E:\Program Files (x86)'
    )

    if ($registrykey = Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\' | Where-Object { $_.Name -imatch $softwarename } | Select-Object -ExpandProperty PSPath) {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Registry key: $registrykey"
        Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove registry key? (Y\N):"
        $answer = Read-Host
        if ($answer -eq "y") {
            Remove-Item $registrykey
            Write-Host -ForegroundColor Green "Registry key removed: $registrykey`n"
        }
    }
    else { Write-Host -ForegroundColor Red "No matching registry keys." }

    foreach ($folderpath in $folderpaths) {
        $softwarepath = Get-ChildItem -Path $folderpath | Where-Object { $_.Name -imatch "$softwarename" } | Select-Object -ExpandProperty FullName
        if ($softwarepath) {
            Write-Host -ForegroundColor Green -BackgroundColor Black "Found folder: $softwarepath"
            Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove folder? (Y\N):"
            $answer = Read-Host
            if ($answer -eq "y") {
                Remove-Item $softwarepath -Force -Recursive
                Write-Host -ForegroundColor Red "Folder removed: $softwarepath"
            }
        }
    }
    if (!$softwarepath) {
        Write-Host -ForegroundColor Red "No matching folders."
    }
}
