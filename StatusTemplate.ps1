Function PingStatus() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)][string[]]$HostName,
        [int]$PingCount,
        [switch]$SuccessOnly,
        [switch]$help
    )
    
    function help() { Write-Host "PingStatus [[-HostName] Host1,Host2] [[-PingCount] <int>] [-SuccessOnly] [-help]`n" -ForegroundColor Yellow -BackgroundColor Black }
    function statusok() { Write-Host -NoNewline "[ "; Write-Host -NoNewline -ForegroundColor Green "OK"; Write-Host " ]" }
    function statuserror() { Write-Host -NoNewline "[ "; Write-Host -NoNewline -ForegroundColor Red "ERROR"; Write-Host " ]" }
    function statusmsg() { Write-Host -NoNewline "[ "; Write-Host -NoNewline -ForegroundColor Cyan "Ping status: $target"; Write-Host " ]" -NoNewline }
    function envmsg() {
        Write-Host "`n       " -BackgroundColor DarkCyan -NoNewline
        write-host "Host(s): $HostName" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline
        Write-Host "       `n" -BackgroundColor DarkCyan
    }
    if ($help -or "$*" -imatch "-h" -or !$HostName) {
        help
        break
    }

    if (!$PingCount) {
        $PingCount = 1
    }

    Write-Host "Ping count: $PingCount" -ForegroundColor Cyan
    envmsg
    foreach ($target in $HostName) {

        try {
            $result = test-connection -Count $PingCount $target -ErrorAction Stop | ft -AutoSize -Wrap | out-string
            statusmsg
            statusok
            Write-Host $result
        }
        catch {
            if (!$SuccessOnly) { statusmsg; statuserror }
        }
    }
}
