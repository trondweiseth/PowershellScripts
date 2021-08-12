Function Net-Test {

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)][string]$rhost,
        [int[]]$port,
        [string]$remote,
        [switch]$help
    )

    function help() {
        write-host "SYNTAX: Net-Test [-ip] <hostname/ipaddr> [-port <portnumber>] [-remote <hostname of the remote host to run the script from>]" -ForegroundColor Yellow
    }

    if ($help -or !$rhost) { help } else {

        if ($remote) {

            Invoke-Command -ComputerName $remote -Credential $cred -ArgumentList $rhost, $port -ScriptBlock {

                param([string]$rhost, [string]$port)

                $ComputerName = Resolve-DnsName $rhost | Select-Object -ExpandProperty Name -First 1
                $ErrorActionPreference = "SilentlyContinue"
                $netinterface = Get-NetIPInterface | Where-Object { $_.ConnectionState -eq "Connected" -and $_.AddressFamily -eq "IPv4" } | Select-Object -ExpandProperty InterfaceAlias -First 1
                $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
                $RA = Resolve-DnsName $rhost | ForEach-Object { $_.IPAddress }
                if ((Test-Connection localhost -Count 1 | Get-Member | foreach { $_.Name }) -imatch "Latency") {
                    if ($responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty Latency) {
                        $ping = "True"
                    }
                    else {
                        $ping = "False"
                    }
                }
                else {
                    if ($responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty ResponseTime) {
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
                    $socket = new-object System.Net.Sockets.TcpClient($rhost, $port)
                    If ($socket.Connected) {
                        $res = "True"
                        portinfotable
                        $socket.Close()
                    }
    
                    else {
                        $res = "False"
                        Write-Host -ForegroundColor Yellow -BackgroundColor Black "WARNING: TCP connect to ${rhost}:$port failed`n"
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
            $ComputerName = Resolve-DnsName $rhost | Select-Object -ExpandProperty Name -First 1
            $netinterface = Get-NetIPInterface | Where-Object { $_.ConnectionState -eq "Connected" -and $_.AddressFamily -eq "IPv4" } | Select-Object -ExpandProperty InterfaceAlias -First 1
            $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
            $ErrorActionPreference = "SilentlyContinue"
            $RA = $(Resolve-DnsName $rhost | ForEach-Object { $_.IPAddress })
            if ((Test-Connection localhost -Count 1 | Get-Member | foreach { $_.Name }) -imatch "Latency") {
                if ($responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty Latency) {
                    $ping = "True"
                }
                else {
                    $ping = "False"
                }
            }
            else {
                if ($responsetime = Test-Connection $rhost -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty ResponseTime) {
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
                $port | ForEach-Object {
                    $socket = new-object System.Net.Sockets.TcpClient($rhost, $_) 
                    If ($socket.Connected) {
                        $res = "True"
                        portinfotable
                        $socket.Close()
                    }

                    else {
                        Write-Host -ForegroundColor Yellow -BackgroundColor Black "WARNING: TCP connect to ${rhost}:$port failed`n"
                        $res = "False"
                        portinfotable
                    }
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
