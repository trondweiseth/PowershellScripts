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
                $ipmatch = $rhost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$" -and [ipaddress]$rhost
                $dnsres = Resolve-DnsName $rhost -DnsOnly -ErrorAction SilentlyContinue
                if ($? -and $dnsres -ne $null) {
                    if ($dnsres | Select-Object -ExpandProperty NameHost -First 1 -ErrorAction SilentlyContinue) {
                        $ComputerName = $dnsres | Select-Object -ExpandProperty NameHost -First 1
                    }
                    else {
                        $ComputerName = $dnsres | Select-Object -ExpandProperty Name -First 1
                    }
                    if ($ipmatch -eq $true) {
                        $RA = $rhost
                        $ipAddresses = $rhost
                    }
                    else {
                        $RA = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue -First 2
            
                    }
                }
                else {
                    Write-Warning "Could not resolve DNS name`n"
                    $ComputerName = $rhost
                    if ($ipmatch -eq $false) { break }
                }
    
                if ($ipAddresses = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue) {
                    $ipAddresses = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue
                }
                else { $ipAddresses = $rhost }
                $nicInformation = Find-NetRoute -RemoteIPAddress $RA 
                $srcip = $nicInformation | select -ExpandProperty IPAddress -ErrorAction SilentlyContinue
                $netinterface = $nicInformation | select -ExpandProperty InterfaceAlias -ErrorAction SilentlyContinue -First 1
                if ((Test-Connection localhost -Count 1 | Get-Member | ForEach-Object { $_.Name }) -imatch "Latency") {
                    if ($responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty Latency) {
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
                    Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$Remadr"
                    Write-Host -NoNewline -ForegroundColor Green "RemotePort             : "; Write-Host -ForegroundColor Yellow "$port"
                    Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
                    Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
                    Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
                    Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
                    Write-Host -NoNewline -ForegroundColor Green "TcpTestSucceeded       : "; Write-Host -ForegroundColor Yellow "$res"
                    Write-Host -ForegroundColor Cyan "===================================="
                }
    
                if ($port) {
                    $ipAddresses | ForEach-Object {
                        $tcpobject = new-Object system.Net.Sockets.TcpClient 
                        #Connect to remote machine's port               
                        $connect = $tcpobject.BeginConnect($_, $port, $null, $null) 
                        #Configure a timeout before quitting - time in milliseconds 
                        $wait = $connect.AsyncWaitHandle.WaitOne($timeout, $false) 
                        If (-Not $Wait) {
                            Write-Warning "TCP connect to ($_ : $port) failed"
                            $res = "False"
                            $Remadr = $_
                        }
                        Else {
                            $error.clear()
                            $tcpobject.EndConnect($connect) | out-Null
                            $res = "True"
                            $Remadr = $_
                            portinfotable
                            break
                        }
                    }
                    portinfotable
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
            $ipmatch = $rhost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$" -and [ipaddress]$rhost
            $dnsres = Resolve-DnsName $rhost -DnsOnly -ErrorAction SilentlyContinue
            if ($? -and $dnsres -ne $null) {
                if ($dnsres | Select-Object -ExpandProperty NameHost -First 1 -ErrorAction SilentlyContinue) {
                    $ComputerName = $dnsres | Select-Object -ExpandProperty NameHost -First 1
                }
                else {
                    $ComputerName = $dnsres | Select-Object -ExpandProperty Name -First 1
                }
                if ($ipmatch -eq $true) {
                    $RA = $rhost
                    $ipAddresses = $rhost
                }
                else {
                    $RA = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue -First 2
        
                }
            }
            else {
                Write-Warning "Could not resolve DNS name`n"
                $ComputerName = $rhost
                if ($ipmatch -eq $false) { break }
            }

            if ($ipAddresses = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue) {
                $ipAddresses = $dnsres | Select-Object -ExpandProperty IP4Address -ErrorAction SilentlyContinue
            }
            else { $ipAddresses = $rhost }
            $nicInformation = Find-NetRoute -RemoteIPAddress $RA 
            $srcip = $nicInformation | select -ExpandProperty IPAddress -ErrorAction SilentlyContinue
            $netinterface = $nicInformation | select -ExpandProperty InterfaceAlias -ErrorAction SilentlyContinue -First 1
            if ((Test-Connection localhost -Count 1 | Get-Member | ForEach-Object { $_.Name }) -imatch "Latency") {
                if ($responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty Latency) {
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
                Write-Host -NoNewline -ForegroundColor Green "RemoteAddress          : "; Write-Host -ForegroundColor Yellow "$Remadr"
                Write-Host -NoNewline -ForegroundColor Green "RemotePort             : "; Write-Host -ForegroundColor Yellow "$port"
                Write-Host -NoNewline -ForegroundColor Green "InterfaceAlias         : "; Write-Host -ForegroundColor Yellow "$netinterface"
                Write-Host -NoNewline -ForegroundColor Green "SourceAddress          : "; Write-Host -ForegroundColor Yellow "$srcip"
                Write-Host -NoNewline -ForegroundColor Green "PingSucceeded          : "; Write-Host -ForegroundColor Yellow "$ping"
                Write-Host -NoNewline -ForegroundColor Green "PingReplyDetails (RTT) : "; Write-Host -ForegroundColor Yellow "$responsetime ms"
                Write-Host -NoNewline -ForegroundColor Green "TcpTestSucceeded       : "; Write-Host -ForegroundColor Yellow "$res"
                Write-Host -ForegroundColor Cyan "===================================="
            }

            if ($port) {
                $ipAddresses | ForEach-Object {
                    $tcpobject = new-Object system.Net.Sockets.TcpClient 
                    #Connect to remote machine's port               
                    $connect = $tcpobject.BeginConnect($_, $port, $null, $null) 
                    #Configure a timeout before quitting - time in milliseconds 
                    $wait = $connect.AsyncWaitHandle.WaitOne($timeout, $false) 
                    If (-Not $Wait) {
                        Write-Warning "TCP connect to ($_ : $port) failed"
                        $res = "False"
                        $Remadr = $_
                    }
                    Else {
                        $error.clear()
                        $tcpobject.EndConnect($connect) | out-Null
                        $res = "True"
                        $Remadr = $_
                    }
                }
                portinfotable
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
