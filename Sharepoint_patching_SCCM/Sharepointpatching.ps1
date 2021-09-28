# Before useing this module, you have to create server lists for each of your enviroments.
# To get a list of all the available commands run: Get-Command SP-*
#
# Any functions that changes a state or value have validation before running. 
# Any function that is only informational are not validated before running.
#
#If you dont use pscredentials in your profile, uncomment the option below
#$uname = ("$env:USERDOMAIN\$env:USERNAME");$cred = Get-Credential $uname
#
# You need to change Site configuration variable $SiteCode and $ProviderMachineName with  your sccm server and site number.
# Alternatively, you can get the first part of the function with the code provided by your SCCM.
# 1) Open SCCM. 2) Click the blue dropdown menu beside Search tab in top left corner. 4) Click 'Connect via PowerShell ISE.
# 5) Copy and replace the same code inside SP-InstallationStatus function.

<# SCCM script to detect application:

    $installed=$null

    $FileHash= Get-FileHash -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll' -ErrorAction SilentlyContinue
    $version = (Get-Item -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll').Versioninfo.FileVersion

    if(($version -eq '19.0.1234.1234' -and $FileHash.Hash -eq "B502F8BB38475869CE4F4A95CDB689FB6411B78339D49586746F7B7E48573645")){
             $installed=1
      }

    Write-Host $installed
    
#>

$scriptlocation = $MyInvocation.MyCommand.Path
Clear-Variable servers -ErrorAction SilentlyContinue

Function SP-Servers() {
    param(
        [ValidateSet('ENV01', 'ENV02', 'TEST', 'PROD')]
        [string]$Global:Enviroment,
        [switch]$EditFile
    )
    
    function helpmsg {
        Write-Host -ForegroundColor Yellow "SYNTAX: SP-Servers [{ENV01 | ENV02 | TEST | PROD}] [-EditFile]"
    }

    if (! $Enviroment) { helpmsg; break }
    $serverlistfolder = "$HOME\Documents\SharepointHosts"
    if ($EditFile) {notepad.exe $serverlistfolder\$Enviroment.txt | Out-Null}
    $Global:servers = Get-Content $serverlistfolder\$Enviroment.txt
    Write-Host -ForegroundColor Yellow "Servers are set to:"
    $servers | foreach { Write-Host -ForegroundColor Cyan "$_" }
}

Function validation() {
    Write-Host -ForegroundColor Red "Do you want to run $command on enviroment ${Enviroment}? (y/n):" -NoNewline
    $validate = Read-Host -InformationAction SilentlyContinue
    if ($validate -notmatch 'y') { break }
}

Function errormsg  {
    if ($null -eq $Servers) {
        Write-Warning "No servers are selected. Run SP-Servers [{ENV01 | ENV02 | TEST | PROD}]"
        break
    }
}

Function SP-StartServers {
    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    foreach ($server in $servers) {
        Get-SCVirtualMachine $server |  start-SCVirtualMachine -RunAsynchronously | Select-Object Name,Status | Format-Table -AutoSize
    }
    while ((SP-VMStatus | Select-Object Status) -notmatch "Running") {sleep 2}
    SP-VMStatus
}

Function SP-StopServers {
    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    # Stop servers
    foreach ($server in $servers) {
        Get-SCVirtualMachine $server |  Stop-SCVirtualMachine -Shutdown -RunAsynchronously | Select-Object Name,Status | Format-Table -AutoSize
    }
    while ((SP-VMStatus | Select-Object Status) -notmatch "PowerOff") {sleep 2}
    SP-VMStatus
}

Function SP-ForceStopServers {
    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    # Force Stop servers
    foreach ($server in $servers) {
        try {
            stop-computer $server -force -ErrorAction stop
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    while ((SP-VMStatus | Select-Object Status) -notmatch "PowerOff") {sleep 2}
    SP-VMStatus
}

Function SP-VMStatus {
    errormsg
    # check status servers
    foreach ($server in $servers) {
        Get-SCVirtualMachine $server | select-object name, status
    }
}

Function SP-CreateCheckpoints {
    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    $spchkpointdescription = {"SharePoint Patching"}
    $validate = Read-Host -Prompt "Current description is: '$spchkpointdescription'. Do you want you change the description? (y/n) (Default n)" -ErrorAction SilentlyContinue
    if ($validate -imatch 'y') {
        $newspchkpointdescription = Read-Host -Prompt "Description "
        $savedescription = Read-Host -Prompt "Do you want to save the description? (y/n) (Default n)" -ErrorAction SilentlyContinue
        if ($savedescription -imatch 'y') {
            $currentdescription = ((Get-Content $scriptlocation | Where-Object { $_ -match "spchkpointdescription"}).Split('{')[1]).Trim("}")
            (Get-Content $scriptlocation).Replace("$currentdescription","$newspchkpointdescription") | Set-Content -Path $scriptlocation
        }
    
    }
    $savedescription = Read-Host -Prompt "Do you want to save the description? (y/n) "

    # Take a cold Checkpoint
    foreach ($server in $servers) {
        Get-SCVirtualMachine $server | New-SCVMCheckpoint -Description $spchkpointdescription -RunAsynchronously
    }
}

Function SP-GetCheckpoints() {
    errormsg
    foreach ($server in $servers) {
        $checkpoints = Get-SCVirtualMachine $server | Get-SCVMCheckpoint
        if ($checkpoints) {
            $checkpoints | foreach {
                Write-Host -ForegroundColor Green 'Name :' $_.Name -NoNewline
                Write-Host -ForegroundColor Yellow '  Description :' $_.Description
            }
        }
    }
}

Function SP-RemoveCheckpoints {
    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    # Remove old checkpoint
    foreach ($server in $servers) {
        $Checkpoints = Get-SCVMCheckpoint -VM $server

        foreach ($checkpoint in $Checkpoints) {

            Remove-SCVMCheckpoint -VMCheckpoint $Checkpoint

        }
    }
}

Function SP-VMConnect() {
    param([switch]$Wait)
    errormsg
    foreach ($server in $servers) {
        if ($wait) {
            while (! (Test-Connection $server -ErrorAction SilentlyContinue)) { sleep 3 }
        }
        mstsc /w:1024 /h:800 /v:$server
    }
}

Function SP-TestConnection {
    # check server status
    param([switch]$Wait,[int]$Time)
    errormsg
    if ($null -eq $Time) {$Time = 3}
    foreach ($server in $servers) {
        if ($Wait) {while (! (Test-Connection $server -Count 1 -ErrorAction SilentlyContinue)) {sleep $Time}}
        try {
            Test-Connection $server -Count 1 -ErrorAction Stop | Format-Table -AutoSize
        }
        catch {
            Write-Host -ForegroundColor Red "$server is not responding."
        }
    }
}

Function SP-ClearSCCMCache {
    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    $servers | foreach-object {

        Invoke-Command -ComputerName $_ -ScriptBlock {

            # https://sccm-zone.com/deleting-the-sccm-cache-the-right-way-3c1de8dc4b48

            ## Initialize the CCM resource manager com object
            [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
            ## Get the CacheElementIDs to delete
            $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
            ## Remove cache items
            ForEach ($CacheItem in $CacheInfo) {
                $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))

            }

            return $true

        } -Credential $creds
    }
}

Function SP-RunSCCMClientAction {
    [CmdletBinding()]
                
    # Parameters used in this function
    param
    (  
        [ValidateSet('MachinePolicy', 
            'DiscoveryData', 
            'ComplianceEvaluation', 
            'AppDeployment',  
            'HardwareInventory', 
            'UpdateDeployment', 
            'UpdateScan', 
            'SoftwareInventory')] 
        [string[]]$ClientAction

        # https://www.powershellbros.com/sccm-client-actions-remote-machines-powershell-script/
    )

    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    $ActionResults = @()
    $Global:servers | ForEach-Object {
        Try {
            $ActionResults = Invoke-Command -ComputerName $_ -Credential $cred -ArgumentList (,$ClientAction) -ErrorAction Stop -ScriptBlock { param($ClientAction)
 
                Foreach ($Item in $ClientAction) {
                    $Object = @{} | select "Action name", Status
                    Try {
                        $ScheduleIDMappings = @{ 
                            'MachinePolicy'        = '{00000000-0000-0000-0000-000000000021}'; 
                            'DiscoveryData'        = '{00000000-0000-0000-0000-000000000003}'; 
                            'ComplianceEvaluation' = '{00000000-0000-0000-0000-000000000071}'; 
                            'AppDeployment'        = '{00000000-0000-0000-0000-000000000121}'; 
                            'HardwareInventory'    = '{00000000-0000-0000-0000-000000000001}'; 
                            'UpdateDeployment'     = '{00000000-0000-0000-0000-000000000108}'; 
                            'UpdateScan'           = '{00000000-0000-0000-0000-000000000113}'; 
                            'SoftwareInventory'    = '{00000000-0000-0000-0000-000000000002}'; 
                        }
                        $ScheduleID = $ScheduleIDMappings[$item]
                        Write-Verbose "Processing $Item - $ScheduleID"
                        [void]([wmiclass] "root\ccm:SMS_Client").TriggerSchedule($ScheduleID);
                        $Status = "Success"
                        Write-Verbose "Operation status - $status"
                    }
                    Catch {
                        $Status = "Failed"
                        Write-Verbose "Operation status - $status"
                    }
                    $Object."Action name" = $item
                    $Object.Status = $Status
                    $Object
                }
 
            } | Select-Object @{n = 'ServerName'; e = { $_.pscomputername } }, "Action name", Status
        }  
        Catch {
            Write-Error $_.Exception.Message
        }
        Return $ActionResults
    }
}

Function SP-GetApplications {
    param([String][Parameter(Mandatory = $True, Position = 0)] $AppName)
    errormsg
    $evalstates = @(
        "No state information is available"
        "Application is enforced to desired/resolved state"
        "Application is not required on the client"
        "Application is available for enforcement (install or uninstall based on resolved state). Content may/may not have been downloaded"
        "Application last failed to enforce (install/uninstall)"
        "Application is currently waiting for content download to complete"
        "Application is currently waiting for content download to complete"
        "Application is currently waiting for its dependencies to download"
        "Application is currently waiting for a service (maintenance) window"
        "Application is currently waiting for a previously pending reboot"
        "Application is currently waiting for serialized enforcement"
        "Application is currently enforcing dependencies"
        "Application is currently enforcing"
        "Application install/uninstall enforced and soft reboot is pending"
        "Application installed/uninstalled and hard reboot is pending"
        "Update is available but pending installation"
        "Application failed to evaluate"
        "Application is currently waiting for an active user session to enforce"
        "Application is currently waiting for all users to logoff"
        "Application is currently waiting for a user logon"
        "Application in progress, waiting for retry"
        "Application is waiting for presentation mode to be switched off"
        "Application is pre-downloading content (downloading outside of install job)"
        "Application is pre-downloading dependent content (downloading outside of install job)"
        "Application download failed (downloading during install job)"
        "Application pre-downloading failed (downloading outside of install job)"
        "Download success (downloading during install job)"
        "Post-enforce evaluation"
        "Waiting for network connectivity"
        )
    foreach ($server in $servers) {
        write-host -BackgroundColor DarkCyan "                                                      " -NoNewline
        Write-Host -ForegroundColor Yellow -BackgroundColor DarkCyan  $server -NoNewline
        write-host -BackgroundColor DarkCyan "                                                      "
        Invoke-Command -ComputerName $server -Credential $cred -ArgumentList $AppName,$evalstates -ScriptBlock {param($AppName,$evalstates)
            (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" | Where-Object { $_.Name -match "$AppName" }) |
            Select-Object Name,InstallState,LastInstallTime,ResolvedState,AllowedActions,InProgressActions, @{ Name='EvaluationState'; Expression = { ($Evalstates[$_.EvaluationState]) } } | Format-Table -AutoSize -Wrap
        }
    }
}

Function SP-TriggerInstallation {

    # Trigger app installation

    Param
    (
    [String][Parameter(Mandatory = $True, Position = 0)] $AppName,
    [ValidateSet("Install", "Uninstall")]
    [String][Parameter(Mandatory = $True, Position = 1)] $Method
    )

    errormsg
    $command = (Get-PSCallStack).Command | select -First 1
    validation
    foreach ($server in $servers) {
        Invoke-Command -ComputerName $server -Credential $cred -ArgumentList $AppName,$Method -ScriptBlock {

            Param
                (
                [String]$AppName,
                [String]$Method
                )
 
                Begin {
                    $Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" | Where-Object { $_.Name -like $AppName })
                    $CCMApplicationName = $Application.FullName
                    if (!('' -eq $Application)) {$readval = Read-Host -Prompt "Do you want to install ${CCMApplicationName}? (y/n) (Default n)"}
                    if (!($readval -imatch 'y')) {break}
                    $Args = @{EnforcePreference = [UINT32] 0
                        Id                      = "$($Application.id)"
                        IsMachineTarget         = $Application.IsMachineTarget
                        IsRebootIfNeeded        = $False
                        Priority                = 'High'
                        Revision                = "$($Application.Revision)" 
                    } 
                }
                Process
                { 
                    Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -MethodName $Method -Arguments $Args 
                }
                End {}
        }
    }  
}

Function SP-InstallationStatus{
    [CmdletBinding()]
    param(
    [Parameter(Position=0)][string]$AppName,
    [int]$Time,
    [switch]$Wait
    )

    errormsg
    if ($null -eq $Time) {$Time = 30}
    if ($AppName -eq '') {
        $InstallStatusAppName = {Sharepoint 2016 CU 2021 March} # "Sharepoint 2016 CU 2021 March"
    }
    else {
        $InstallStatusAppName = $AppName
        $currentAppName = ((Get-Content $scriptlocation | Where-Object { $_ -imatch "InstallStatusAppName"}).Split('{')[1]).Trim("}")
        (Get-Content $scriptlocation).Replace("$currentAppName","$InstallStatusAppName") | Set-Content -Path $scriptlocation
    }

    Write-Host -ForegroundColor Yellow "Checking installation staus for $InstallStatusAppName..."

    # Press 'F5' to run this script. Running this script will load the ConfigurationManager module for Windows PowerShell and will connect to the site.

    # Uncomment the line below if running in an environment where script signing is required.
    #Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

    # Site configuration
    $SiteCode = <site code> # Site code 
    $ProviderMachineName = "contoso.sccmserver.local" # SMS Provider machine name

    # Customizations
    $initParams = @{}
    #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
    #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

    # Do not change anything below this line

    # Import the ConfigurationManager.psd1 module 
    if((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    # Connect to the site's drive if it is not already present
    if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams

    $xmloutput = Get-CMApplication -Name $InstallStatusAppName | Select-Object SDMPackageXML
    if (!($null -eq $xmloutput)) {
        $xmlitems = ([xml]($xmloutput.SDMPackageXML)).AppMgmtDigest.DeploymentType.Installer.DetectAction.InnerText
        $NewHash = ($xmlitems).Split('"')[1]
        $NewVersion = ($xmlitems).Split("'")[5]
    }
    else {
        Write-Warning "Could not find any application with the name $InstallStatusAppName"
    }


    function validatescript {

        param([string]$NewHash,[string]$NewVersion)

        $installed = $null
        $FileHash = Get-FileHash -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll' -ErrorAction SilentlyContinue
        $version = (Get-Item -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll').Versioninfo.FileVersion

        if (($version -eq "$NewVersion" -and $FileHash.Hash -eq "$NewHash")) {
            $installed = "$env:COMPUTERNAME SP patch ready $(get-date)"
            Write-Host $installed -ForegroundColor Green
        }
        else {
            write-host "Not yet installed on $env:COMPUTERNAME $(get-date)" -ForegroundColor Red
        }
    }

    function waitvalidatescript {

        param([string]$NewHash,[string]$NewVersion,[int]$Time)

        while(1) {
            $installed = $null
            $FileHash = Get-FileHash -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll' -ErrorAction SilentlyContinue
            $version = (Get-Item -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll').Versioninfo.FileVersion

            if (($version -eq "$NewVersion" -and $FileHash.Hash -eq "$NewHash")) {
                $installed = "$env:COMPUTERNAME SP patch ready $(get-date)"
                Write-Host $installed -ForegroundColor Green
                break
            }
            else {
                Write-Host "Still not installed on $env:COMPUTERNAME. Checking $server again in $Time seconds..." -ForegroundColor Red
                sleep $Time
            }
        }
    }

    if ($Wait) {
        $servers | foreach-object {Invoke-Command -ComputerName $_ -Credential $cred -ArgumentList $NewHash,$NewVersion,$Time -ScriptBlock ${function:waitvalidatescript}}
    }
    else {
        $servers | foreach-object {Invoke-Command -ComputerName $_ -Credential $cred -ArgumentList $NewHash,$NewVersion -ScriptBlock ${function:validatescript}}
    }
}
