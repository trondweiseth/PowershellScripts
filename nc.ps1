Function nc() {
    <#
    .SYNOPSIS
    Check active connections

    .DESCRIPTION
    This PS script for checking all active network connections.

    .PARAMETER resolve
    Tries to resolve ip address by sending a json query to ip-api.com

    .PARAMETER out
    Sending output to Out-GridView

    .EXAMPLE
    netconn [-out] [-resolve] [-getprocess] [-all]

    .NOTES
    Author : Trond Weiseth
    #>

    param(
        [CmdletBinding()]

        [Parameter(Mandatory=$false)]
        [switch]
        $Resolve,

        [Parameter(Mandatory=$false)]
        [switch]
        $Out,

        [Parameter(Mandatory = $false,
                    ParameterSetName = "Status")]
        [ValidateSet('listen', 'established', 'bound', 'timeWait', 'closeWait')]
        [string]
        $Status
    )

    Begin {
        $nic = Get-NetAdapter | where { $_.Status -eq "Up" } | select -ExpandProperty Name
        $localip = Get-NetIPAddress -InterfaceAlias $nic -AddressFamily IPv4 | select -ExpandProperty IPAddress
        $process = @{
            Name = 'ProcessName'
            Expression = { (Get-Process -Id $_.OwningProcess).Name }
        }
    }

    Process {
        function connquery() {
            if ($Status) {
                Get-NetTCPConnection -LocalAddress $localip -state $Status | 
                Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess,$process | Format-Table *
            }
            else {
                Get-NetTCPConnection -LocalAddress $localip |
                Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess,$process | Format-Table *
            }
        }

        function getconnections() {
            if ($Out) {
                connquery | Out-GridView
            }
            else {
                connquery
            }
        }

        function resolver() {
            if ($Status) {
                $iplist = Get-NetTCPConnection -LocalAddress $localip -state $Status
            }
            else {
                $iplist = Get-NetTCPConnection -LocalAddress $localip
            }
            if ($Out) {
                $iplist | ForEach-Object {
                    $RemoteIpAddress = $_.RemoteAddress
                    $ProcessId = $_.OwningProcess
                    $Result = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                    $Result | Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}}, country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                } | Out-GridView -PassThru
            }
            else {
                $iplist | ForEach-Object {
                    $RemoteIpAddress = $_.RemoteAddress
                    $ProcessId = $_.OwningProcess
                    $Result = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                    $Result | Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}}, country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                } | Format-Table *
                
            }
        }

        if ($Resolve) {
            resolver
        }
        else {
            getconnections
        }
    }

    End{}
}
