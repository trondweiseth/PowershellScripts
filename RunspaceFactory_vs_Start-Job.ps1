function stage() {
    $Global:Count = 1
    $Global:NIC = Get-NetAdapterStatistics | ? { $_.ReceivedBytes -ne 0} | select -ExpandProperty Name
    $Global:IP  = Get-NetIPAddress -InterfaceAlias $NIC -AddressFamily IPv4 | select -ExpandProperty IPAddress
    $GlobalServers = Get-NetTCPConnection -State Established -LocalAddress $IP | select -ExpandProperty RemoteAddress
}

#### Start-Job ####
function startjob() {
    foreach ($s in $Servers) {
        start-job -ArgumentList $NIC,$IP,$s -ScriptBlock $scriptblock
    }
    get-job | wait-job | Receive-Job | ft -AutoSize ; Get-Job | Remove-Job
}

#### RunspaceFactory ####
function runSpaceTest() {
    # Create RunspacePool
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, [string]$servers.Count)
    $RunspacePool.ApartmentState = "STA"
    $RunspacePool.Open()

    # Create and execute Runspace for each scan
    $Runspaces = foreach ($Server in $Servers) {
        $Runspace = [PowerShell]::Create().AddScript($scriptBlock).AddParameter("Server", $Server).AddParameter("Count", $Count)
        $Runspace.RunspacePool = $RunspacePool
        $Handle = $Runspace.BeginInvoke()
        [PSCustomObject] @{
            Runspace = $Runspace
            Handle = $Handle
        }
    }

    # Wait for all Runspaces to complete and store the results in an array
    $Results = foreach ($Runspace in $Runspaces) {
        $Runspace.Runspace.EndInvoke($Runspace.Handle)
    }
    return $results
    # Clean up RunspacePool
    $RunspacePool.Close()
    $RunspacePool.Dispose()
}

#### ScriptBlock ####
$scriptblock = {
    param($server, $Count)

    try {
        Resolve-DnsName $server  -ErrorAction Stop
        }
    catch {
        if ($error[0] -imatch 'ResourceUnavailable') {
            $TARGET = $server | -replace '.in-addr.arpa';Resolve-DnsName $TARGET;return
            }
        }
}

#### Main exec ####
stage
Write-Host -f Yellow "Testing start-Job"
Measure-Command {startjob} | Tee-Object -Variable jotbime
Write-Host -f Yellow "Testing RunspaceFactory"
Measure-Command {runSpaceTest} | Tee-Object -Variable runspacetime
if ($runspacetime.Milliseconds -gt $jotbime.Milliseconds) {$f="Start-job";$time=($runspacetime.Milliseconds - $jotbime.Milliseconds)}
else {$f="RunspaceFactory";$time=($jotbime.Milliseconds - $runspacetime.Milliseconds)}
Write-host -f Green "$f was $time milliseconds faster."
