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
        $VirusTotal,

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
                Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess,$process | Format-Table * -AutoSize
            }
            else {
                Get-NetTCPConnection -LocalAddress $localip |
                Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess,$process | Format-Table * -AutoSize
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
                if ($VirusTotal) {
                    $iplist | ForEach-Object {
                        $RemoteIpAddress = $_.RemoteAddress
                        $ProcessId = $_.OwningProcess
                        $IpResult = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                        $VirusTotalResult =  Invoke-WebRequest -Uri https://www.virustotal.com/api/v3/ip_addresses/$RemoteIpAddress/votes -Headers @{"x-apikey"="bfa906e9430715ee1eb285b7678b430c280e402c1f0728f367b3b7448bae6396"}
                        $json = $VirusTotalResult | ConvertFrom-Json
                        $Verdict = $json.data.attributes | Select-Object -First 1 | Select-Object -ExpandProperty verdict
                        if ($json.meta.count -eq '0') {$Verdict = "Clean"}
                        $IpResult | Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}}, @{Name = 'VirusTotalVerdict';Expression={$Verdict}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                    } | Out-GridView -PassThru
                } else {
                    $iplist | ForEach-Object {
                        $RemoteIpAddress = $_.RemoteAddress
                        $ProcessId = $_.OwningProcess
                        $IpResult = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                        $IpResult | Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                    } | Out-GridView -PassThru
                }
            }
            else {
                if ($VirusTotal) {
                    $iplist | ForEach-Object {
                        $RemoteIpAddress = $_.RemoteAddress
                        $ProcessId = $_.OwningProcess
                        $IpResult = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                        $VirusTotalResult =  Invoke-WebRequest -Uri https://www.virustotal.com/api/v3/ip_addresses/$RemoteIpAddress/votes -Headers @{"x-apikey"="<api-key>"}
                        $json = $VirusTotalResult | ConvertFrom-Json
                        $Verdict = $json.data.attributes | Select-Object -First 1 | Select-Object -ExpandProperty verdict
                        if ($json.meta.count -eq '0') {$Verdict = "Clean"}
                        $IpResult | Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}}, @{Name = 'VirusTotalVerdict';Expression={$Verdict}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                    } | Format-Table * -AutoSize 
                } else {
                    $iplist | ForEach-Object {
                        $RemoteIpAddress = $_.RemoteAddress
                        $ProcessId = $_.OwningProcess
                        $IpResult = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                        $IpResult | Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                    } | Format-Table * -AutoSize 
                }
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
