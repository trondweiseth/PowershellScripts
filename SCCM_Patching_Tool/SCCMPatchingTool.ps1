<#
.SYNOPSIS
     SCCM Patching Pool
.DESCRIPTION
     Tool to make installing patches from software center on multiple host's easier.
     This scrip uses the the system center virtual machine manager module to manage the vm's.
.NOTES

     Author     : Trond Weiseth
#>

$scriptlocation = $MyInvocation.MyCommand.Path
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$winform                        = New-Object system.Windows.Forms.Form
$winform.ClientSize             = New-Object System.Drawing.Point(690,500)
$winform.text                   = 'SCCM Patching Tool'
#$winform.BackColor             = [System.Drawing.ColorTranslator]::FromHtml("#00A3FF")
$winform.StartPosition          = 'CenterScreen'
$winform.TopMost                = $false

$textboxlable                   = New-Object System.Windows.Forms.Label
$textboxlable.Text              = 'Host(s):'
$textboxlable.Location          = New-Object System.Drawing.Size(8,35)
$textboxlable.AutoSize          = $True
$winform.Controls.Add($textboxlable)

$objTextBox1                    = New-Object System.Windows.Forms.TextBox 
$objTextBox1.Multiline          = $True;
$objTextBox1.Location           = New-Object System.Drawing.Size(10,60) 
$objTextBox1.Size               = New-Object System.Drawing.Size(300,100)
$objTextBox1.Scrollbars         = 'Vertical'
$objTextBox1.ForeColor          = 'Green'
$winform.Controls.Add($objTextBox1)

$textboxlable2                  = New-Object System.Windows.Forms.Label
$textboxlable2.Text             = 'CP Description:'
$textboxlable2.Location         = New-Object System.Drawing.Size(8,170)
$textboxlable2.AutoSize         = $True
$winform.Controls.Add($textboxlable2)

$objTextBox2                    = New-Object System.Windows.Forms.TextBox 
$objTextBox2.Location           = New-Object System.Drawing.Size(95,165) 
$objTextBox2.Width              = '215'
$objTextBox2.Text               = 'SharePoint Patching'
$winform.Controls.Add($objTextBox2)

$Clearbuttn                     = New-Object system.Windows.Forms.Button
$Clearbuttn.text                = 'Clear output'
$Clearbuttn.AutoSize            = $true
$Clearbuttn.location            = New-Object System.Drawing.Point(10,215)
$Clearbuttn.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Clearbuttn.Add_Click({ $objRichTextBox1.ResetText() })
$winform.Controls.Add($Clearbuttn)

$objRichTextBox1                = New-Object System.Windows.Forms.RichTextBox
$objRichTextBox1.Multiline      = $True;
$objRichTextBox1.Location       = New-Object System.Drawing.Size(10,250)
$objRichTextBox1.Size           = New-Object System.Drawing.Size(670,240)
$objRichTextBox1.Scrollbars     = 'Vertical'
$objRichTextBox1.ReadOnly       = $True
$objRichTextBox1.MultiLine      = $True
$objRichTextBox1.Anchor         = [System.Windows.Forms.AnchorStyles]::Top `
    -bor [System.Windows.Forms.AnchorStyles]::Left `
    -bor [System.Windows.Forms.AnchorStyles]::Right `
    -bor [System.Windows.Forms.AnchorStyles]::Bottom
$winform.Controls.Add($objRichTextBox1)

$Set_Credential                 = New-Object system.Windows.Forms.Button
$Set_Credential.Location        = New-Object System.Drawing.Size(10,10) 
$Set_Credential.Size            = New-Object System.Drawing.Size(100,20)
$Set_Credential.Text            = 'Set Credentials'
$Set_Credential.add_Click({ $Global:cred = Get-Credential $env:USERNAME })
$winform.Controls.Add($Set_Credential)

$serverStatus                   = New-Object system.Windows.Forms.Button
$serverStatus.text              = "Server status"
$serverStatus.Width             = '160'
$serverStatus.location          = New-Object System.Drawing.Point(330,10)
$serverStatus.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$serverStatus.Add_Click({ serverstatus })
$winform.Controls.Add($serverStatus)

$restartServer                  = New-Object system.Windows.Forms.Button
$restartServer.text             = 'Restart server(s)'
$restartServer.Width            = '160'
$restartServer.location         = New-Object System.Drawing.Point(330,40)
$restartServer.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$restartServer.Add_Click({ restartserver })
$winform.Controls.Add($restartServer)

$stopServer                     = New-Object system.Windows.Forms.Button
$stopServer.text                = 'Stop Server(s)'
$stopServer.Width               = '160'
$stopServer.location            = New-Object System.Drawing.Point(330,70)
$stopServer.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$stopServer.Add_Click({ stopserver })
$winform.Controls.Add($stopServer)

$startServer                    = New-Object system.Windows.Forms.Button
$startServer.text               = "Start Server(s)"
$startServer.Width              = '160'
$startServer.location           = New-Object System.Drawing.Point(330,100)
$startServer.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$startServer.Add_Click({ startserver })
$winform.Controls.Add($startServer)

$getCheckpoint                  = New-Object system.Windows.Forms.Button
$getCheckpoint.text             = 'Get Checkpoint'
$getCheckpoint.Width            = '160'
$getCheckpoint.location         = New-Object System.Drawing.Point(520,160)
$getCheckpoint.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$getCheckpoint.Add_Click({ getchekcpoints })
$winform.Controls.Add($getCheckpoint)

$removeCheckpoint               = New-Object system.Windows.Forms.Button
$removeCheckpoint.text          = "Remove Checkpoint"
$removeCheckpoint.Width         = '160'
$removeCheckpoint.location      = New-Object System.Drawing.Point(330,130)
$removeCheckpoint.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$removeCheckpoint.Add_Click({ removecheckpoints })
$winform.Controls.Add($removeCheckpoint)

$takeCheckpoint                 = New-Object system.Windows.Forms.Button
$takeCheckpoint.text            = 'Take Checkpoint'
$takeCheckpoint.Width           = '160'
$takeCheckpoint.location        = New-Object System.Drawing.Point(330,160)
$takeCheckpoint.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$takeCheckpoint.Add_Click({ coldcheckpoint })
$winform.Controls.Add($takeCheckpoint)

$clientaction = @(
'MachinePolicy',
'DiscoveryData',
'ComplianceEvaluation',
'AppDeployment',
'HardwareInventory', 
'UpdateDeployment', 
'UpdateScan', 
'SoftwareInventory'
)
$SCCMClientAction               = New-Object System.Windows.Forms.ComboBox
$SCCMClientAction.Width         = '160'
$SCCMClientAction.location      = New-Object System.Drawing.Point(520,10)
$SCCMClientAction.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$SCCMClientAction.Items.AddRange($clientaction)
$SCCMClientAction.SelectedIndex = '0'
$winform.Controls.Add($SCCMClientAction)

$RunSCCMClientAction            = New-Object system.Windows.Forms.Button
$RunSCCMClientAction.text       = 'Run SCCMClientAction'
$RunSCCMClientAction.Width      = '160'
$RunSCCMClientAction.location   = New-Object System.Drawing.Point(520,40)
$RunSCCMClientAction.Font       = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$RunSCCMClientAction.Add_Click({ runSCCMClientAction })
$winform.Controls.Add($RunSCCMClientAction)

$ClearSCCMCache                = New-Object system.Windows.Forms.Button
$ClearSCCMCache.text           = 'Clear SCCM Cache'
$ClearSCCMCache.Width          = '160'
$ClearSCCMCache.location       = New-Object System.Drawing.Point(520,70)
$ClearSCCMCache.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$ClearSCCMCache.Add_Click({ clearsccmcache })
$winform.Controls.Add($ClearSCCMCache)

$installApp                     = New-Object system.Windows.Forms.Button
$installApp.text                = 'Install Application'
$installApp.Width               = '160'
$installApp.location            = New-Object System.Drawing.Point(520,100)
$installApp.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$installApp.Add_Click({ appinstallation })
$winform.Controls.Add($installApp)

$installStatus                  = New-Object system.Windows.Forms.Button
$installStatus.text             = 'Installation Status'
$installStatus.Width            = '160'
$installStatus.location         = New-Object System.Drawing.Point(520,130)
$installStatus.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$installStatus.Add_Click({ installstatus })
$winform.Controls.Add($installStatus)

$textboxlable3                  = New-Object System.Windows.Forms.Label
$textboxlable3.Text             = 'AppName:'
$textboxlable3.Location         = New-Object System.Drawing.Size(313,195)
$textboxlable3.AutoSize         = $True
$winform.Controls.Add($textboxlable3)

$objTextBox3                    = New-Object System.Windows.Forms.TextBox 
$objTextBox3.Location           = New-Object System.Drawing.Size(375,190) 
$objTextBox3.Width              = '305'
$objTextBox3.Text               = 'Sharepoint 2013 CU 2021 January'
$winform.Controls.Add($objTextBox3)

$textboxlable4                  = New-Object System.Windows.Forms.Label
$textboxlable4.Text             = 'File Hash:'
$textboxlable4.Location         = New-Object System.Drawing.Size(120,225)
$textboxlable4.AutoSize         = $True
$winform.Controls.Add($textboxlable4)

$objTextBox4                    = New-Object System.Windows.Forms.TextBox 
$objTextBox4.Location           = New-Object System.Drawing.Size(180,220)
$objTextBox4.Width              = '500'
$objTextBox4.Text               = '1F085D389C20DA018B285C3D018BAC514CAA5BA42E2AD63BF32E93E79B164F2'
$winform.Controls.Add($objTextBox4)

$textboxlable5                  = New-Object System.Windows.Forms.Label
$textboxlable5.Text             = 'App Version:'
$textboxlable5.Location         = New-Object System.Drawing.Size(8,195)
$textboxlable5.AutoSize         = $True
$winform.Controls.Add($textboxlable5)

$objTextBox5                    = New-Object System.Windows.Forms.TextBox 
$objTextBox5.Location           = New-Object System.Drawing.Size(95,190) 
$objTextBox5.Width              = '215'
$objTextBox5.Text               = '15.0.5371.1005'
$winform.Controls.Add($objTextBox5)

$saveInput = New-Object system.Windows.Forms.Button
$saveInput.text = 'Save Text'
#$saveInput.Width               = '160'
$saveInput.AutoSize = $true
$saveInput.location = New-Object System.Drawing.Point(235, 10)
$saveInput.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$saveInput.Add_Click( {
        #Saves text to Hash text box
        $hashstring = (Get-Content $scriptlocation) | Where-Object { $_ -match "objTextBox4.Text               = '" -and $_ -notmatch 'replace' }
        $currenthash = $hashstring.Split("'")[1]
        $newhash = $objTextBox4.Text
        (Get-Content $scriptlocation).Replace("$currenthash", "$newhash") | Set-Content -Path $scriptlocation 
        #Saves text to AppName
        $appnamestring = (Get-Content $scriptlocation) | Where-Object { $_ -match "objTextBox3.Text               = '" -and $_ -notmatch 'replace' }
        $currentappname = $appnamestring.Split("'")[1]
        $newappname = $objTextBox3.Text
        (Get-Content $scriptlocation).Replace("$currentappname", "$newappname") | Set-Content -Path $scriptlocation
        #Saves text to CP Description
        $descriptionstring = (Get-Content $scriptlocation) | Where-Object { $_ -match "objTextBox2.Text               = '" -and $_ -notmatch 'replace' }
        $currentdescription = $descriptionstring.Split("'")[1]
        $newdescription = $objTextBox2.Text
        (Get-Content $scriptlocation).Replace("$currentdescription", "$newdescription") | Set-Content -Path $scriptlocation
        #Saves text to Appversion
        $appversionstring = (Get-Content $scriptlocation) | Where-Object { $_ -match "objTextBox5.Text               = '" -and $_ -notmatch 'replace' }
        $currentappversion = $appversionstring.Split("'")[1]
        $newappversion = $objTextBox5.Text
        (Get-Content $scriptlocation).Replace("$currentappversion", "$newappversion") | Set-Content -Path $scriptlocation
})
$winform.Controls.Add($saveInput)

# Code goes here:

Function DisplayMessage {
    param
    (
        [parameter(Mandatory = $true)]
        [string]$MessageString,
        [ValidateSet("Black", "Green", "Blue", "Brown", "Yellow", "Red")]
        [string]$color    
    )

    if (!$Color) { $Color = 'Black' }
    $objRichTextBox1.SelectionColor = [Drawing.Color]::$color
    $objRichTextBox1.AppendText($MessageString)
    $objRichTextBox1.SelectionStart = $objRichTextBox1.Text.Length
    $objRichTextBox1.ScrollToCaret()
    $objTextBox1.Focus()
}

Function DisplayError {
    param
    (
        [parameter(Mandatory = $true)]
        [String]
        $ErrorString
    )
 
    $objRichTextBox1.ForeColor = 'Red'
    $objRichTextBox1.AppendText($ErrorString)
    $objRichTextBox1.SelectionStart = $objRichTextBox1.Text.Length
    $objRichTextBox1.ScrollToCaret()
    $objTextBox1.Focus()
}

Function ServerStatusUp() {
    $objTextBox1.Lines | ForEach-Object {
        $retry = 0
        $success = $true
        do {  
            if (!(Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue)) {
                $success = $false
            }
            else {
                DisplayMessage -MessageString "Checking if server is down. Retry ($retry/5). Next attempt in 5 seconds..." -color Blue
                Start-sleep -Seconds 5
            }
            $retry++ 
        }until($retry -eq 5 -or $success -eq $false)
        if ($success -eq $false) {
            DisplayMessage -MessageString "$_ is down." -color Green
        }
        else {
            DisplayError -ErrorString "$_ is still up."
        }
    }
}

Function ServerStatusDown() {
    $objTextBox1.Lines | ForEach-Object {
        $retry = 0
        $success = $false
        do {  
            if (!(Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue)) {
                $success = $true
            }
            else {
                DisplayMessage -MessageString "Checking if server is up. Retry ($retry/5). Next attempt in 5 seconds..." -color Blue
                Start-sleep -Seconds 5
            }
            $retry++ 
        }until($retry -eq 5 -or $success -eq $true)
        if ($success -eq $false) {
            DisplayMessage -MessageString "$_ is up." -color Green
        }
        else {
            DisplayError -ErrorString "$_ is still down."
        }
    }
}

Function serverstatus() {
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        DisplayMessage -MessageString "Checking server status on $_...`n" -color Green
        try {
            $res = Get-SCVirtualMachine $_ | select-object name, status | out-string -ErrorAction Stop
            DisplayMessage -MessageString $res -color Brown
        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}

Function restartserver() {
    $oReturn = [System.Windows.Forms.MessageBox]::Show("Do you want to reboot?", "Reboot", "4", "48")
    switch ($oReturn) {
        "Yes" {
            if (!$objTextBox1.Lines) {
                DisplayError -ErrorString "ERROR: No host(s).`n"
            }
            $objTextBox1.Lines | ForEach-Object {
                DisplayMessage -MessageString "Starting server $_...`n" -color Green
                try {
                    $res = restart-computer $_ -force -ErrorAction stop | Out-String
                    DisplayMessage -MessageString $res -color Brown
                    ServerStatusUp
                }
                catch {
                    if ($_.Exception.Message -imatch 'winrm') {
                        DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
                    }
                }
            }
        }
        "NO" {
            DisplayError -ErrorString "Reboot canceled."
        }
    }
}

Function stopserver() {
    $oReturn = [System.Windows.Forms.MessageBox]::Show("Do you want to stop vm(s)?", "Reboot", "4", "48")
    switch ($oReturn) {
        "Yes" {
            if (!$objTextBox1.Lines) {
                DisplayError -ErrorString "ERROR: No host(s).`n"
            }
            $objTextBox1.Lines | ForEach-Object {
                if (Get-SCVirtualMachine $_ |  Stop-SCVirtualMachine -Shutdown) {
                    DisplayMessage -MessageString "Stopping server $_" -color Green
                    ServerStatusDown
                }
                else {
                    DisplayError -ErrorString "Could not find $_"
                }

            }
        }
        "NO" {
            DisplayError -ErrorString "Shutdown canceled."
        }
    }

}

Function removecheckpoints() {
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    foreach ($vm in $objTextBox1.Lines) {
        try {
            $Checkpoints = Get-SCVMCheckpoint -VM $vm 
            foreach ($checkpoint in $Checkpoints) {
                DisplayMessage -MessageString "Removing checkpoint: $checkpoint..." -color Green
                DisplayMessage -MessageString (Remove-SCVMCheckpoint -VMCheckpoint $Checkpoint)
            }
        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}

Function coldcheckpoint() {
    $description = $objTextBox2.Text
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        try {
            DisplayMessage -MessageString "Creating checkpoint on $_...`n" -color Green
            DisplayMessage -MessageString (Get-SCVirtualMachine $_ | New-SCVMCheckpoint -Description $description -RunAsynchronously | Out-String)

        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}

Function getchekcpoints() {
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    foreach ($vm in $objTextBox1.Lines) {
        DisplayMessage -MessageString "Getting checkpoint(s) for $vm...`n" -color Green
        try {
            $checkpoints = Get-SCVirtualMachine $vm | Get-SCVMCheckpoint -ErrorAction Stop
            if ($checkpoints -eq $null) {
                DisplayMessage -MessageString "Name: $vm : No chekcpoint(s).`n" -color Black
            }
            else {
                $checkpoints | ForEach-Object {
                    DisplayMessage -MessageString ("Name: " + $_.Name) -color Brown
                    DisplayMessage -MessageString (" Description: " + $_.Description | out-string) -color Blue
                }
            }
        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}

Function startserver() {
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        if (Get-SCVirtualMachine $_ |  start-SCVirtualMachine) {
            DisplayMessage -MessageString "Starting server $_...`n" -color Green
            ServerStatusUp
        }
        else {
            DisplayError -ErrorString "Could not find $_"
        }
    }
}

Function runSCCMClientAction {
    $ClientAction = $SCCMClientAction.Text
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        $ActionResults = @()
        DisplayMessage -MessageString "Running SCCM action: ${ClientAction} on $_...`n" -color Green
        Try { 
            $ActionResults = Invoke-Command -ComputerName $_ -Credential $cred { param($ClientAction)
 
                Foreach ($Item in $ClientAction) {
                    $Object = @{} | Select-Object "Action name", Status
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
 
            } -ArgumentList $ClientAction -ErrorAction Stop | Select-Object @{n = 'ServerName'; e = { $_.pscomputername } }, "Action name", Status | Out-String
        }  
        Catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
        }
        DisplayMessage -MessageString $ActionResults -color Brown
    }
} 

Function clearsccmcache() {
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        DisplayMessage -MessageString "Clearing SCCM cache on $_...`n" -color Green
        try {
            Invoke-Command -ComputerName $_ -Credential $cred -ScriptBlock {

                # https://sccm-zone.com/deleting-the-sccm-cache-the-right-way-3c1de8dc4b48

                ## Initialize the CCM resource manager com object
                [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
                ## Get the CacheElementIDs to delete
                $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
                ## Remove cache items
                ForEach ($CacheItem in $CacheInfo) {
                    $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))
                }
            } -ErrorAction Stop
            DisplayMessage -MessageString "SCCM Cache Cleared." -color Brown
        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}

Function appinstallation() {
    $hash = $objTextBox4.Text
    $appversion = $objTextBox5.Text
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        DisplayMessage -MessageString "Starting app installation on $_...`n" -color Green
        try {
            $res = Invoke-Command -ComputerName $_ -ScriptBlock { param($appname)
                Function triggerAppInstallation {
                    Param
                    (
                        [String][Parameter(Mandatory = $True, Position = 1)] $Computername,
                        [String][Parameter(Mandatory = $True, Position = 2)] $AppName,
                        [ValidateSet("Install", "Uninstall")]
                        [String][Parameter(Mandatory = $True, Position = 3)] $Method
                    )
 
                    Begin {
                        $Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $Computername | Where-Object { $_.Name -like $AppName })
                        $Args = @{EnforcePreference = [UINT32] 0
                            Id                      = "$($Application.id)"
                            IsMachineTarget         = $Application.IsMachineTarget
                            IsRebootIfNeeded        = $False
                            Priority                = 'High'
                            Revision                = "$($Application.Revision)" 
                        }
                    }
                    Process {
                        Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -ComputerName $Computername -MethodName $Method -Arguments $Args
                    }
                    End {}
                } 
                Trigger-AppInstallation -Computername localhost -AppName $appname -Method Install
            } -ErrorAction Stop
            DisplayMessage -MessageString $res -color Brown
        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}

Function installstatus() {
    $hash = $objTextBox4.Text
    $appversion = $objTextBox5.Text
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        DisplayMessage -MessageString "Checking installation status on $_...`n" -color Green
        try {
            $res = Invoke-Command -ComputerName $_ -Credential $cred -ArgumentList($hash, $appversion) -ScriptBlock {
                $hash = $args[0]
                $appversion = $args[1]
                $installed = $null
                $FileHash = Get-FileHash -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll' -ErrorAction SilentlyContinue
                $version = (Get-Item -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll').Versioninfo.FileVersion

                if (($version -eq $appversion -and $FileHash.Hash -eq $hash)) {
                    Write-Output "$env:COMPUTERNAME SP patch ready $(get-date)"
                }
                else {
                    Write-Output "Not installed."
                }
            } -ErrorAction Stop
            DisplayMessage -MessageString ($res + "`n") -color Brown
        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}

Function removesccmcache() {
    if (!$objTextBox1.Lines) {
        DisplayError -ErrorString "ERROR: No host(s).`n"
    }
    $objTextBox1.Lines | ForEach-Object {
        DisplayMessage -MessageString "Removing SCCM cache on $_...`n" -color Green
        try {
            $res = Invoke-Command -ComputerName $_ -Credential $cred -ScriptBlock {

                # https://sccm-zone.com/deleting-the-sccm-cache-the-right-way-3c1de8dc4b48

                ## Initialize the CCM resource manager com object
                [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
                ## Get the CacheElementIDs to delete
                $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
                ## Remove cache items
                ForEach ($CacheItem in $CacheInfo) {
                    $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))
                }
                $objRichTextBox1.AppendText($res)
                $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
                $objRichTextBox1.ScrollToCaret()
            } -ErrorAction Stop
        }
        catch {
            if ($_.Exception.Message -imatch 'winrm') {
                DisplayError -ErrorString "Error connecting to remote server`nError message : WinRM cannot process the request.`n"
            }
            else {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Message", 0, 16)
            }
        }
    }
}
[void]$winform.ShowDialog()
