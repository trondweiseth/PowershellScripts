Function netconn() {

    param(
        [switch]$resolve,
        [switch]$out,
        [switch]$getprocess
    )

    function fetchprocess() {
        $pids = getconnections | Select-Object OwningProcess | ForEach-Object {$_.OwningProcess}
        $pids | ForEach-Object {Get-Process -Id $_ | Select-Object Id,ProcessName} | Format-Table
    }
    function getconnections() {
        if ($out) {
            Get-NetTCPConnection | Where-Object {$_.State -cmatch 'Established' -and $_.RemoteAddress -ne '127.0.0.1' -and $_.LocalAddress -cnotmatch '::'} | Out-GridView
        } else {
            Get-NetTCPConnection | Where-Object {$_.State -cmatch 'Established' -and $_.RemoteAddress -ne '127.0.0.1' -and $_.LocalAddress -cnotmatch '::'}
        }
    }
    function resolver() {

        $iplist = netconn | Select-Object RemoteAddress | ForEach-Object {$_.RemoteAddress}
        if ($out) {
            $iplist | ForEach-Object {Invoke-RestMethod -Uri http://ip-api.com/json/$_} | Out-GridView
        } else {
            $iplist | ForEach-Object {Invoke-RestMethod -Uri http://ip-api.com/json/$_ | Select-Object query,country,countryCode,region,regionName,city,zip,timezone,isp,org,as} | Format-Table -Autosize -Wrap
        }
    }

    if ($getprocess){
        fetchprocess
    } else {
        if ($resolve) {
            resolver
        } else {
            getconnections
        }
    }
}
