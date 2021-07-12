Function Port-Test {

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)][string]$ip,
        [int[]]$port,
        [string]$remote,
        [switch]$help
    )

    function help() {
        write-host "SYNTAX: Port-Test [-ip] <hostname/ipaddr> [-port <portnumber>] [-remote <hostname of the remote host to run the script from>]" -ForegroundColor Yellow
    }

    if ($help -or !$ip) { help } else {

        if ($remote) {

            Invoke-Command -ComputerName $remote -Credential $cred -ArgumentList $ip, $port -ScriptBlock {

                param([string]$ip, [string]$port)

                $rhost = Resolve-DnsName $ip | Select-Object -ExpandProperty Name
                $ErrorActionPreference = "SilentlyContinue"
                $netinterface = Get-NetIPInterface | Where-Object { $_.ConnectionState -eq "Connected" } | Select-Object -ExpandProperty InterfaceAlias -First 1
                $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
                $RA = Resolve-DnsName $ip | ForEach-Object { $_.IPAddress }
  
                function portinfotable() {
                    "===================================="
                    "CumputerName     : $rhost"
                    "RemoteAddress    : $RA"
                    "InterfaceAlias   : $netinterface"
                    "SourceAddress    : $srcip"
                    "RemotePort       : $port"
                    “TcpTestSucceeded : $res”
                    "===================================="
                }

                if ($port) {
                    $socket = new-object System.Net.Sockets.TcpClient($ip, $port)
                    If ($socket.Connected) {
                        $res = "True"
                        portinfotable
                        $socket.Close()
                    }
    
                    else {
                        $res = "False"
                        portinfotable
                    }
    
                }
                else {
    
                    if ($responsetime = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty ResponseTime) {
                        $ping = "True"
                    }
                    else {
                        $ping = "False"
                    }

                    "===================================="
                    "ComputerName           : $rhost"
                    "RemoteAddress          : $RA"
                    "InterfaceAlias         : $netinterface"
                    "SourceAddress          : $srcip"
                    "PingSucceeded          : $ping"
                    "PingReplyDetails (RTT) : $responsetime"
                    "===================================="
                }
            }

        }
        else {
            $rhost = Resolve-DnsName $ip | Select-Object -ExpandProperty Name
            $netinterface = Get-NetIPInterface | Where-Object { $_.ConnectionState -eq "Connected" } | Select-Object -ExpandProperty InterfaceAlias -First 1
            $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
            $ErrorActionPreference = "SilentlyContinue"
            $RA = $(Resolve-DnsName $ip | ForEach-Object { $_.IPAddress })

            function portinfotable() {
                "===================================="
                "CumputerName     : $rhost"
                "RemoteAddress    : $RA"
                "InterfaceAlias   : $netinterface"
                "SourceAddress    : $srcip"
                "RemotePort       : $port"
                “TcpTestSucceeded : $res”
                "===================================="
            }

            if ($port) {
                $port | ForEach-Object {
                    $socket = new-object System.Net.Sockets.TcpClient($ip, $_) 
                    If ($socket.Connected) {
                        $res = "True"
                        portinfotable
                        $socket.Close()
                    }

                    else {
                        $res = "False"
                        portinfotable
                    }
                }

            }
            else {

                if ($responsetime = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty ResponseTime) {
                    $ping = "True"
                }
                else {
                    $ping = "False"
                }

                "===================================="
                "ComputerName           : $rhost"
                "RemoteAddress          : $RA"
                "InterfaceAlias         : $netinterface"
                "SourceAddress          : $srcip"
                "PingSucceeded          : $ping"
                "PingReplyDetails (RTT) : $responsetime"
                "===================================="
            }
        }
    }
}
