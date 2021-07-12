Function Port-Test {

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)][string]$ip,
        [int]$port,
        [string]$remote,
        [switch]$help
    )

    if ($ComputerName -imatch "sgf") {
        $uname = ("sgf\bf-$env:USERNAME")
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $uname, $cred.Password
    }

    function help() {
        write-host "SYNTAX: Port-Test [-ip] <hostname/ipaddr> [-port <portnumber>] [-remote <hostname of the remote host to run the script from>]" -ForegroundColor Yellow
    }

    if ($help -or !$ip) {help} else {

    if ($remote) {

        Invoke-Command -ComputerName $remote -Credential $cred -ArgumentList $ip, $port -ScriptBlock {

            $ip = $args[0]
            $rhost = Resolve-DnsName $ip | select -ExpandProperty Name
            $port = $args[1]
            $ErrorActionPreference = "SilentlyContinue"
            $netinterface = Get-NetIPInterface | where { $_.ConnectionState -eq "Connected" } | select -ExpandProperty InterfaceAlias -First 1
            $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | select -ExpandProperty IPAddress
            $RA = Resolve-DnsName $ip | foreach { $_.IPAddress }
            $socket = new-object System.Net.Sockets.TcpClient($ip, $port)
  
            if ($port) {

                If ($socket.Connected)
                {
    
                    "CumputerName     : $rhost"
                    "RemoteAddress    : $RA"
                    "InterfaceAlias   : $netinterface"
                    "SourceAddress    : $srcip"
                    "RemotePort       : $port"
                    “TcpTestSucceeded : True” 
    
                    $socket.Close() 
                }
    
                else {
    
                    "CumputerName     : $rhost"
                    "RemoteAddress    : $RA"
                    "InterfaceAlias   : $netinterface"
                    "SourceAddress    : $srcip"
                    "RemotePort       : $port"
                    “TcpTestSucceeded : False” 
                }
    
            }
            else {
    
                if ($responsetime = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue  | select -ExpandProperty ResponseTime) {
                    $ping = "True"
                }
                else {
                    $ping = "False"
                }
    
                "ComputerName           : $rhost"
                "RemoteAddress          : $RA"
                "InterfaceAlias         : $netinterface"
                "SourceAddress          : $srcip"
                "PingSucceeded          : $ping"
                "PingReplyDetails (RTT) : $responsetime"
            }
        }

    }
    else {
        $rhost = Resolve-DnsName $ip | select -ExpandProperty Name
        $netinterface = Get-NetIPInterface | where { $_.ConnectionState -eq "Connected" } | select -ExpandProperty InterfaceAlias -First 1
        $srcip = Get-NetIPAddress -InterfaceAlias $netinterface -AddressFamily IPv4 | select -ExpandProperty IPAddress
        $ErrorActionPreference = "SilentlyContinue"
        $RA = $(Resolve-DnsName $ip | foreach { $_.IPAddress })
        $socket = new-object System.Net.Sockets.TcpClient($ip, $port)    

        if ($port) {

            If ($socket.Connected)
            {

                "CumputerName     : $rhost"
                "RemoteAddress    : $RA"
                "InterfaceAlias   : $netinterface"
                "SourceAddress    : $srcip"
                "RemotePort       : $port"
                “TcpTestSucceeded : True” 

                $socket.Close() 
            }

            else {

                "CumputerName     : $rhost"
                "RemoteAddress    : $RA"
                "InterfaceAlias   : $netinterface"
                "SourceAddress    : $srcip"
                "RemotePort       : $port"
                “TcpTestSucceeded : False” 
            }

        }
        else {

            if ($responsetime = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue  | select -ExpandProperty ResponseTime) {
                $ping = "True"
            }
            else {
                $ping = "False"
            }

            "ComputerName           : $rhost"
            "RemoteAddress          : $RA"
            "InterfaceAlias         : $netinterface"
            "SourceAddress          : $srcip"
            "PingSucceeded          : $ping"
            "PingReplyDetails (RTT) : $responsetime"
        }
    }
    }
}
