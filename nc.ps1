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
        $Global:VirusTotalAPIKey="<VirusTotal API Key>"
        $nic = Get-NetAdapter | where { $_.Status -eq "Up" } | Select-Object -ExpandProperty Name
        $localip = Get-NetIPAddress -InterfaceAlias $nic -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
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
                        $VirusTotalResult =  Invoke-WebRequest -Uri https://www.virustotal.com/api/v3/ip_addresses/$RemoteIpAddress/votes -Headers @{"x-apikey"="$VirusTotalAPIKey"}
                        $json = $VirusTotalResult | ConvertFrom-Json
                        $Verdict = $json.data.attributes | Select-Object -First 1 | Select-Object -ExpandProperty verdict
                        if ($json.meta.count -eq '0') {$Verdict = "Clean"}
                        $IpResult |
                        Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}}, @{Name = 'VirusTotal';Expression={$Verdict}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                    } | Out-GridView -PassThru
                } else {
                    $iplist | ForEach-Object {
                        $RemoteIpAddress = $_.RemoteAddress
                        $ProcessId = $_.OwningProcess
                        $IpResult = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                        $IpResult |
                        Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                    } | Out-GridView -PassThru
                }
            }
            else {
                if ($VirusTotal) {
                    $iplist | ForEach-Object {
                        $RemoteIpAddress = $_.RemoteAddress
                        $ProcessId = $_.OwningProcess
                        $IpResult = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                        $VirusTotalResult =  Invoke-WebRequest -Uri https://www.virustotal.com/api/v3/ip_addresses/$RemoteIpAddress/votes -Headers @{"x-apikey"="$VirusTotalAPIKey"}
                        $json = $VirusTotalResult | ConvertFrom-Json
                        $Verdict = $json.data.attributes | Select-Object -First 1 | Select-Object -ExpandProperty verdict
                        if ($json.meta.count -eq '0') {$Verdict = "Clean"}
                        $IpResult |
                        Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}}, @{Name = 'VirusTotal';Expression={$Verdict}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
                    } | Format-Table * -AutoSize 
                } else {
                    $iplist | ForEach-Object {
                        $RemoteIpAddress = $_.RemoteAddress
                        $ProcessId = $_.OwningProcess
                        $IpResult = Invoke-RestMethod -Uri http://ip-api.com/json/$RemoteIpAddress
                        $IpResult |
                        Select-Object query, @{Name = 'OwningProcess';Expression={$ProcessId}}, @{Name='ProcessName';Expression={(Get-Process -Id $ProcessId).ProcessName}},country, countryCode, region, regionName, city, zip, timezone, isp, org, as
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
