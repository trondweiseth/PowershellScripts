Function Install-CleanUp() {
param(
[Parameter(Position=0,Mandatory=$true)][string]$softwarename
)

    $folderpaths = @(
    'C:\Program Files\'
    'C:\Program Files (x86)\'
    'E:\Program Files\'
    'E:\Program Files (x86)'
    )

    if ($registrykey = Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\' | where {$_.Name -imatch $softwarename} | select -ExpandProperty PSPath) {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Registry key: $registrykey"
        Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove registry key? (Y\N):"
        $answer = Read-Host
        if ($answer -eq "y") {
            Remove-Item $registrykey
            Write-Host -ForegroundColor Green "Registry key removed: $registrykey`n"
        }
    }

    foreach ($folderpath in $folderpaths) {
        $softwarepath = Get-ChildItem -Path $folderpath | where {$_.Name -imatch "$softwarename"} | select -ExpandProperty FullName
        if ($softwarepath) {
            Write-Host -ForegroundColor Green -BackgroundColor Black "Found folder: $softwarepath"
            Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Remove folder? (Y\N):"
            $answer = Read-Host
            if ($answer -eq "y") {
                #Remove-Item $softwarepath -Recurse
                Write-Host -ForegroundColor Red "Folder removed: $softwarepath"
            }
        }
    }
}
