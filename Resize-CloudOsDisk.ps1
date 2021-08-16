Function Resize-CloudOsDisk() {

    param(
    [Parameter(Mandatory=$true,Position=0)][string]$ComputerName,
    [switch]$BootAndSystem
    )

    $selection = get-cloVirtualMachineDisk -VMname $ComputerName | select -ExpandProperty DiskInfo | 
    Add-Member -MemberType AliasProperty -Name 'Size GB' -Value Size -PassThru | 
    select VMname,'Size GB',Name,CanExpand,ExpandFailure,Bus,Lun | Out-GridView -PassThru
    $canexpand = $selection | Select-Object -ExpandProperty canExpand
    $diskname  = $selection | select -ExpandProperty Name
    $disksize  = $selection | select -ExpandProperty 'Size GB'
    
    function removecheckpoints() {
        $checkpoints = Get-SCVirtualMachine $ComputerName | Get-SCVMCheckpoint
        if ($checkpoints) {
            $checkpoints | foreach {
                Write-Host -ForegroundColor Green 'Name :' $_.Name -NoNewline
                Write-Host -ForegroundColor Yellow '  Description :' $_.Description
                }
            Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Do you want to remove the checkpoint(s)? (Y/N): "
            $confirmation = Read-Host
            if ($confirmation -eq 'y') {
                $checkpoints | ForEach-Object {Remove-SCVMCheckpoint -VMCheckpoint $_ -Confirm}
                sleep 5
                Write-Host -ForegroundColor Green "Checkpoint(s) are removed.`n"
            } else {break}
        }
    }

    if ($canexpand -eq $false) {
        $errormessage = $selection | Select-Object -ExpandProperty ExpandFailure
        write-host -ForegroundColor Yellow -BackgroundColor Black $errormessage
        write-host -ForegroundColor Yellow -BackgroundColor Black 'Checking for available checkpoints...'
        removecheckpoints
    }
    
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -NoNewline "Expand disk with (GB): " 
    [int]$resize = Read-Host
    
    if ($resize -lt $disksize) {
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "ERROR : value is too low. Valua have to be higher than: $disksize GB."
        break
    }
    
    if ($BootAndSystem) {
        expand-VirtualHardDisk -VirtualHardDiskSizeGB $resize -VMname $ComputerName -BootAndSystem
    } else {
        expand-cloVirtualHardDisk -VirtualHardDiskSizeGB $resize -VMname $ComputerName -DiskName $diskname
    }
}
