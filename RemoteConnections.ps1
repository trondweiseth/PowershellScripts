Function RemoteConnections() {
    Param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('listen', 'established', 'bound', 'timeWait', 'closeWait')]
        [string]
        $State
    )

    [void]($ip = (Get-NetIPConfiguration | where IPv4DefaultGateway).IPv4Address.IPAddress)
    $process = @{
        Name = 'ProcessName'
        Expression = { (Get-Process -Id $_.OwningProcess).Name }
    }
    
    $darkAgent = @{
        Name = 'ExternalIdentity'
        Expression = { 
        $ip = $_.RemoteAddress 
        (Invoke-RestMethod -Uri "http://ipinfo.io/$ip/json" -UseBasicParsing -ErrorAction Ignore).org
      
        }
    }
    if ($State) {
        Get-NetTCPConnection -State $State | Where-Object {$_.LocalAddress -eq "$ip" -and $_.RemoteAddress -ne "0.0.0.0"} |
            Select-Object -Property RemoteAddress, RemotePort, State, OwningProcess, $process, $darkAgent | Format-Table -AutoSize
    }
    else {
        Get-NetTCPConnection | Where-Object {$_.LocalAddress -eq "$ip" -and $_.RemoteAddress -ne "0.0.0.0"} |
            Select-Object -Property RemoteAddress, RemotePort, State, OwningProcess, $process, $darkAgent | Format-Table -AutoSize
    }
}
