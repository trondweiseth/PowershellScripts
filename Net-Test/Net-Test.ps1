Function Net-Test {

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)][string]$rhost,
        [string]$remote,
        [int]$port,
        [int]$timeout,
        [switch]$help
    )

    function help() {
        write-host "SYNTAX: Net-Test [[-rhost] <string>] [-port <string>] [-remote <string>] [-timeout <string>] [-help]  [<CommonParameters>]" -ForegroundColor Yellow
    }

    if ( $help -or ! $rhost ) { help ; break }

    $IPMATCH = $rhost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$" -and [ipaddress]$rhost

    if ( ! $timeout ) { $timeout = 100 }

    if ($dnsres = Resolve-DnsName $rhost -DnsOnly -ErrorAction SilentlyContinue) {
        if ($dnsres | Select-Object -ExpandProperty NameHost -First 1 -ErrorAction SilentlyContinue) {
            $ComputerName = $dnsres | Select-Object -ExpandProperty NameHost -First 1
        }
        else {
            $ComputerName = $dnsres | Select-Object -ExpandProperty Name -First 1
        }
        $ipAddresses = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue
        $RA = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue -First 2
    }
    else {
        Write-Warning "Could not resolve DNS name`n"
        if ( $IPMATCH -eq $false ) { break }
        $ComputerName = $rhost
    }

    if ($IPMATCH -eq $true) {
        $RA = $rhost
        $ipAddresses = $rhost
    }

    $NicInformation = Find-NetRoute -RemoteIPAddress $RA
    $srcip = $NicInformation | Select-Object -ExpandProperty IPAddress -ErrorAction SilentlyContinue
    $netinterface = $NicInformation | Select-Object -ExpandProperty InterfaceAlias -ErrorAction SilentlyContinue -First 1

    if ((Test-Connection localhost -Count 1 | Get-Member | ForEach-Object { $_.Name }) -imatch "Latency") { $pingproperty = "Latency" } else { $pingproperty = "ResponseTime" }

    if ($responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty $pingproperty) {
        $ping = "True"
    }
    else {
        $ping = "False"
    }

    function icmpoutput {
        param (
            $ComputerName,
            $RA,
            $netinterface,
            $srcip,
            $ping,
            $responsetime
        )
        Write-Host -ForegroundColor Cyan "===================================="
        Write-Host -NoNewline -ForegroundColor Green "CumputerName           : "; Write-Host -ForegroundColor Yellow "$ComputerName"
        Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$RA"
        Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
        Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
        Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
        Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
        Write-Host -ForegroundColor Cyan "===================================="
    }

    function tcpoutput () {
        param (
            $ComputerName,
            $Remadr,
            $port,
            $netinterface,
            $srcip,
            $ping,
            $responsetime,
            $res
        )
        Write-Host -ForegroundColor Cyan "===================================="
        Write-Host -NoNewline -ForegroundColor Green "CumputerName           : "; Write-Host -ForegroundColor Yellow "$ComputerName"
        Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$Remadr"
        Write-Host -NoNewline -ForegroundColor Green "RemotePort             : "; Write-Host -ForegroundColor Yellow "$port"
        Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
        Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
        Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
        Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
        Write-Host -NoNewline -ForegroundColor Green "TcpTestSucceeded       : "; Write-Host -ForegroundColor Yellow "$res"
        Write-Host -ForegroundColor Cyan "===================================="
    }

    function portTestBlock() {
        param(
            $ip,
            $port,
            $timeout
        )
        $tcpobject = new-Object system.Net.Sockets.TcpClient 
        #Connect to remote machine's port               
        $connect = $tcpobject.BeginConnect($ip, $port, $null, $null) 
        #Configure a timeout before quitting - time in milliseconds 
        $wait = $connect.AsyncWaitHandle.WaitOne($timeout, $false) 
        If (-Not $Wait) {
            Write-Warning "TCP connect to ($ip : $port) failed"
            $Global:res = "False"
            $Global:Remadr = $ip
        }
        Else {
            $error.clear()
            $tcpobject.EndConnect($connect) | out-Null
            $Global:res = "True"
            $Global:Remadr = $ip
        }
    }
    
    if ($remote) {
        if ($port) {
            foreach ($ip in $ipAddresses) { Invoke-Command -ArgumentList $ip, $port, $timeout -ScriptBlock ${function:portTestBlock} }
            Invoke-Command -ComputerName $remote -Credential $cred -ArgumentList $ComputerName, $Remadr, $port, $netinterface, $srcip, $ping, $responsetime, $res -ScriptBlock ${function:tcpoutput}
        }
        else {
            Invoke-Command -ArgumentList  $ComputerName, $RA, $netinterface, $srcip, $ping, $responsetime -ScriptBlock ${function:icmpoutput}
        }
    }
    else {
        if ($port) {
            foreach ($ip in $ipAddresses) { Invoke-Command -ArgumentList $ip, $port, $timeout -ScriptBlock ${function:portTestBlock} }
            Invoke-Command -ArgumentList $ComputerName, $Remadr, $port, $netinterface, $srcip, $ping, $responsetime, $res -ScriptBlock ${function:tcpoutput}
        }
        else {
            Invoke-Command -ArgumentList  $ComputerName, $RA, $netinterface, $srcip, $ping, $responsetime -ScriptBlock ${function:icmpoutput}
        }
    }
}
