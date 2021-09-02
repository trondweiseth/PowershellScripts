Function Get-Tsk {
    
# Getting/staring task from task scheduler on local/remote computer
# Example: Get-Tsk -ComputerName dc01.contoso.test -TaskName update -start
   
    param(
    [CmdletBinding()]
    [string[]]$ComputerName,
    [Parameter(Mandatory = $true)][string]$TaskName,
    [switch]$start,
    [switch]$stop,
    [switch]$Info,
    [switch]$Help
    )

    function help() {Write-Host -ForegroundColor Yellow "Syntax: Get-Task [-ComputerName] <host1,host2> [-TaskName] <string> [-start] [-stop] [-Info]`n"}
    if ($Help) {help}

    if ($ComputerName -imatch "sgf") {
        $uname=("sgf\bf-$env:USERNAME")
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $uname,$cred.Password
    }
    function ComputerNameMsg(){
        Write-Host "`n           " -BackgroundColor DarkCyan -NoNewline
        write-host "ComputerName: $CN" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline
        Write-Host "           `n" -BackgroundColor DarkCyan
    }
    if (!$ComputerName) {
        if ($start) {Get-ScheduledTask *$TaskName* | Start-ScheduledTask}
            elseif ($stop) {Get-ScheduledTask *$TaskName* | Stop-ScheduledTask}
            elseif ($Info) {
                $tasknames = Get-ScheduledTask *$TaskName* | select TaskPath,TaskName -ErrorAction SilentlyContinue
                foreach ($tsk in $tasknames){Get-ScheduledTaskInfo -TaskPath $tsk.taskpath -TaskName $tsk.taskname -ErrorAction SilentlyContinue | select TaskName,LastRunTime,NextRunTime}
            }
            else {
                Get-ScheduledTask *$TaskName* | select TaskName,Date,Description | ft -AutoSize -wrap | Tee-Object -Variable res
                if($res -eq $null){Write-Warning "No match found!"}
            }
    }
    else {
        foreach ($CN in $ComputerName) {
            if ($start) {Invoke-Command -ComputerName $CN -Credential $cred -ArgumentList $TaskName -ScriptBlock {param($TaskName)Get-ScheduledTask $TaskName | Start-ScheduledTask}}
            elseif ($stop) {Invoke-Command -ComputerName $CN -Credential $cred -ArgumentList $TaskName -ScriptBlock {param($TaskName)Get-ScheduledTask $TaskName | Stop-ScheduledTask}}
            elseif ($Info) {
                Invoke-Command -ComputerName $CN -Credential $cred -ArgumentList $TaskName -ScriptBlock {param($TaskName)
                $tasknames = Get-ScheduledTask *$TaskName* | select TaskPath,TaskName -ErrorAction SilentlyContinue
                foreach ($tsk in $tasknames){Get-ScheduledTaskInfo -TaskPath $tsk.taskpath -TaskName $tsk.taskname -ErrorAction SilentlyContinue | select TaskName,LastRunTime,NextRunTime}
                }
            }
            else {
                ComputerNameMsg
                Invoke-Command -ComputerName $CN -Credential $cred -ArgumentList $TaskName -ScriptBlock {param($TaskName)Get-ScheduledTask *$TaskName* | select TaskName,Date,Description | ft -AutoSize -wrap} | Tee-Object -Variable res
                if($res -eq $null){Write-Warning "No match found!"}
            }
        }
    }
}
