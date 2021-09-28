Function Get-VMMLog {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$ComputerName,
        [string]$Newest
        )

    if (!$Newest) {$Newest = 10}
    Get-SCVirtualMachine | Out-Null
    if ($ComputerName) {
        Get-SCJob -Full -Newest $Newest | Select-Object Name,Status,StartTime,ResultName,Owner | where {$_.ResultName -imatch "$ComputerName"}  | Format-Table -AutoSize -Wrap
    }
    else {
        Get-SCJob -Full -Newest $Newest | Select-Object Name,Status,StartTime,ResultName,Owner | Format-Table -AutoSize -Wrap
    }
}
