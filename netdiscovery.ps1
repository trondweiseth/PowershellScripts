function netconn() {
    Get-NetTCPConnection | where {$_.State -cmatch 'Established' -and $_.RemoteAddress -ne '127.0.0.1' }
}
function netconn-resolve() {
    $iplist = Get-NetTCPConnection | where {$_.RemoteAddress -ne '127.0.0.1' -and $_.State -cmatch 'stablished' -and $_.LocalAddress -cnotmatch '::'} | select RemoteAddress | foreach {$_.RemoteAddress}
    $iplist | foreach {Invoke-RestMethod -Uri http://ip-api.com/json/$_}
}
