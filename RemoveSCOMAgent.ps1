Function RemoveSCOMAgent() {

    param([string[]]$Hosts,[switch]$Validate)
    if (!$Hosts) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "SYNTAX: RemoveSCOMAgent -Hosts host1,host2`n";break}
    [void](Import-Module OperationsManagerExtensions)
    cls
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "Searching for SCOM Agent(s)..."
    foreach ($Computername in $Hosts){
        try {
            Remove-SCOMAgent -DNSHostname $Computername -ErrorAction Stop
            if ($validate) {Remove-SCOMAgent -DNSHostname $Computername -ErrorAction Stop}
        }
        catch {
            Write-Warning $Error[0]
        }
    }
}
