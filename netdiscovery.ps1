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

    .PARAMETER getprocess
    Getting the processname for all active connections

    .PARAMETER fullreport
    Runs all parameters

    .EXAMPLE
    netconn [-out] [-resolve] [-getprocess] [-all]

    .NOTES
    Author : Trond Weiseth
    #>

    param(
        [CmdletBinding()]
        [switch]$Resolve,
        [switch]$Out,
        [switch]$GetProcess,
        [switch]$Fullreport,

        [Parameter(Mandatory=$false,ParameterSetName="Status")]
        [ValidateSet('listen','established','bound','timeWait','closeWait')]
        [string]$Status
    )

    $nic = Get-NetAdapter | where {$_.Status -eq "Up"} | select -ExpandProperty Name
    $localip = Get-NetIPAddress -InterfaceAlias $nic -AddressFamily IPv4 | select -ExpandProperty IPAddress

    Function connquery() {
        if ($Status) {
            Get-NetTCPConnection -LocalAddress $localip -state $Status
        } else {
            Get-NetTCPConnection -LocalAddress $localip
        }
    }
    function fetchprocess() {
        $pids = connquery | Select-Object -ExpandProperty OwningProcess
        $pids | ForEach-Object {Get-Process -Id $_ | Select-Object Id,ProcessName} | Format-Table
    }
    function getconnections() {
        if ($Out) {
            connquery | Out-GridView
        } else {
            connquery
        }
    }
    function resolver() {
        if ($Status) {
            $iplist = Get-NetTCPConnection -LocalAddress $localip -state $Status | select -ExpandProperty RemoteAddress
        } else {
            $iplist = Get-NetTCPConnection -LocalAddress $localip | select -ExpandProperty RemoteAddress
        }
        if ($Out) {
            $iplist | ForEach-Object {Invoke-RestMethod -Uri http://ip-api.com/json/$_} | Out-GridView
        } else {
            $iplist | ForEach-Object {Invoke-RestMethod -Uri http://ip-api.com/json/$_ | Select-Object query,country,countryCode,region,regionName,city,zip,timezone,isp,org,as} | Format-Table -Autosize -Wrap
        }
    }

    if ($Fullreport) {
        getconnections
        fetchprocess
        resolver
    } else {
        if ($Getprocess){
            fetchprocess
        } else {
            if ($Resolve) {
                resolver
            } else {
                getconnections
            }
        }
    }
}
