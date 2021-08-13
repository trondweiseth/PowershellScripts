Function Net-Test {

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)][string]$rhost,
        [string]$port,
        [string]$remote,
        [string]$timeout,
        [switch]$help
    )

    function help() {
        write-host "SYNTAX: Net-Test [[-rhost] <string>] [-port <string>] [-remote <string>] [-timeout <string>] [-help]  [<CommonParameters>]" -ForegroundColor Yellow
    }

    if ($help -or !$rhost) { help } else {

        if ($remote) {

            Invoke-Command -ComputerName $remote -Credential $cred -ArgumentList $rhost, $port, $timeout -ScriptBlock {

                param([string]$rhost, [string]$port, [string]$timeout)
                if (!$timeout) { $timeout = 100 }
                $dnsres = Resolve-DnsName $rhost -DnsOnly -ErrorAction SilentlyContinue 
                if ($? -and $dnsres -ne $null) {
                    $ComputerName = $dnsres | Select-Object -ExpandProperty Name -First 1
                }
                else {
                    Write-Host -ForegroundColor Yellow -BackgroundColor Black "WARNING: Could not resolve DNS name`n"
                    $ComputerName = $rhost
                    $inres = $rhost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$" -and [ipaddress]$thost; if ($inres -eq $false) { break }
                }
                $netinterface = Get-NetIPInterface | Where-Object { $_.ConnectionState -eq "Connected" -and $_.AddressFamily -eq "IPv4" } | Select-Object -ExpandProperty InterfaceAlias -First 1
                $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
                $ErrorActionPreference = "SilentlyContinue"
                $RA = $dnsres | ForEach-Object { $_.IPAddress }
                if ((Test-Connection localhost -Count 1 | Get-Member | foreach { $_.Name }) -imatch "Latency") {
                    $responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty Latency
                    if ($?) {
                        $ping = "True"
                    }
                    else {
                        $ping = "False"
                    }
                }
                else {
                    $responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty ResponseTime
                    if ($?) {
                        $ping = "True"
                    }
                    else {
                        $ping = "False"
                    }
                }

                function portinfotable() {
                
                    Write-Host -ForegroundColor Cyan "===================================="
                    Write-Host -NoNewline -ForegroundColor Green "CumputerName           : "; Write-Host -ForegroundColor Yellow "$ComputerName"
                    Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$RA"
                    Write-Host -NoNewline -ForegroundColor Green "RemotePort             : "; Write-Host -ForegroundColor Yellow "$port"
                    Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
                    Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
                    Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
                    Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
                    Write-Host -NoNewline -ForegroundColor Green "TcpTestSucceeded       : "; Write-Host -ForegroundColor Yellow "$res"
                    Write-Host -ForegroundColor Cyan "===================================="
                }

                if ($port) {
                    $tcpobject = new-Object system.Net.Sockets.TcpClient 
                    #Connect to remote machine's port               
                    $connect = $tcpobject.BeginConnect($rhost, $port, $null, $null) 
                    #Configure a timeout before quitting - time in milliseconds 
                    $wait = $connect.AsyncWaitHandle.WaitOne($timeout, $false) 
                    If (-Not $Wait) {
                        Write-Host -ForegroundColor Yellow -BackgroundColor Black "WARNING: TCP connect to ${rhost}:$port failed`n"
                        $res = "False"
                        portinfotable
                    }
                    Else {
                        $error.clear()
                        $tcpobject.EndConnect($connect) | out-Null
                        $res = "True"
                        portinfotable
                    }
                }
                else {
                    Write-Host -ForegroundColor Cyan "===================================="
                    Write-Host -NoNewline -ForegroundColor Green "CumputerName           : "; Write-Host -ForegroundColor Yellow "$ComputerName"
                    Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$RA"
                    Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
                    Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
                    Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
                    Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
                    Write-Host -ForegroundColor Cyan "===================================="
                }
            }
        }
        else {
            if (!$timeout) { $timeout = 100 }
            $dnsres = Resolve-DnsName $rhost -DnsOnly -ErrorAction SilentlyContinue 
            if ($? -and $dnsres -ne $null) {
                $ComputerName = $dnsres | Select-Object -ExpandProperty Name -First 1
            }
            else {
                Write-Host -ForegroundColor Yellow -BackgroundColor Black "WARNING: Could not resolve DNS name`n"
                $ComputerName = $rhost
                $inres = $rhost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$" -and [ipaddress]$thost; if ($inres -eq $false) { break }
            }
            $netinterface = Get-NetIPInterface | Where-Object { $_.ConnectionState -eq "Connected" -and $_.AddressFamily -eq "IPv4" } | Select-Object -ExpandProperty InterfaceAlias -First 1
            $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
            $ErrorActionPreference = "SilentlyContinue"
            $RA = $dnsres | ForEach-Object { $_.IPAddress }
            if ((Test-Connection localhost -Count 1 | Get-Member | foreach { $_.Name }) -imatch "Latency") {
                $responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty Latency
                if ($?) {
                    $ping = "True"
                }
                else {
                    $ping = "False"
                }
            }
            else {
                $responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty ResponseTime
                if ($?) {
                    $ping = "True"
                }
                else {
                    $ping = "False"
                }
            }

            function portinfotable() {
                
                Write-Host -ForegroundColor Cyan "===================================="
                Write-Host -NoNewline -ForegroundColor Green "CumputerName           : "; Write-Host -ForegroundColor Yellow "$ComputerName"
                Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$RA"
                Write-Host -NoNewline -ForegroundColor Green "RemotePort             : "; Write-Host -ForegroundColor Yellow "$port"
                Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
                Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
                Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
                Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
                Write-Host -NoNewline -ForegroundColor Green "TcpTestSucceeded       : "; Write-Host -ForegroundColor Yellow "$res"
                Write-Host -ForegroundColor Cyan "===================================="
            }

            if ($port) {
                $tcpobject = new-Object system.Net.Sockets.TcpClient 
                #Connect to remote machine's port               
                $connect = $tcpobject.BeginConnect($rhost, $port, $null, $null) 
                #Configure a timeout before quitting - time in milliseconds 
                $wait = $connect.AsyncWaitHandle.WaitOne($timeout, $false) 
                If (-Not $Wait) {
                    Write-Host -ForegroundColor Yellow -BackgroundColor Black "WARNING: TCP connect to ${rhost}:$port failed`n"
                    $res = "False"
                    portinfotable
                }
                Else {
                    $error.clear()
                    $tcpobject.EndConnect($connect) | out-Null
                    $res = "True"
                    portinfotable
                }
            }
            else {
                Write-Host -ForegroundColor Cyan "===================================="
                Write-Host -NoNewline -ForegroundColor Green "CumputerName           : "; Write-Host -ForegroundColor Yellow "$ComputerName"
                Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$RA"
                Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
                Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
                Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
                Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
                Write-Host -ForegroundColor Cyan "===================================="
            }
        }
    }
}
