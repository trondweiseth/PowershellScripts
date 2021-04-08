function netconn() {
    Get-NetTCPConnection | where {$_.State -cmatch 'Established' -and $_.RemoteAddress -ne '127.0.0.1' -and $_.LocalAddress -cnotmatch '::'}
}
function netconn-resolve() {
    $iplist = netconn | select RemoteAddress | foreach {$_.RemoteAddress}
    $iplist | foreach {Invoke-RestMethod -Uri http://ip-api.com/json/$_}
}
