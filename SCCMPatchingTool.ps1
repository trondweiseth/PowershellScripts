Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$winform = New-Object system.Windows.Forms.Form
$winform.ClientSize = New-Object System.Drawing.Point(690, 500)
$winform.text = "SCCM Patching Tool"
#$winform.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#00A3FF")
$winform.StartPosition = "CenterScreen"
$winform.TopMost = $false

$textboxlable = New-Object System.Windows.Forms.Label
$textboxlable.Text = "Host(s):"
$textboxlable.Location = New-Object System.Drawing.Size(10, 35)
$textboxlable.AutoSize = $True
$winform.Controls.Add($textboxlable)
   
$objTextBox1 = New-Object System.Windows.Forms.TextBox 
$objTextBox1.Multiline = $True;
$objTextBox1.Location = New-Object System.Drawing.Size(10, 60) 
$objTextBox1.Size = New-Object System.Drawing.Size(300, 100)
$objTextBox1.Scrollbars = "Vertical"
$objTextBox1.ForeColor = "Green"
$winform.Controls.Add($objTextBox1)

$textboxlable2 = New-Object System.Windows.Forms.Label
$textboxlable2.Text = "CP Description:"
$textboxlable2.Location = New-Object System.Drawing.Size(10, 170)
$textboxlable2.AutoSize = $True
$winform.Controls.Add($textboxlable2)

$objTextBox2 = New-Object System.Windows.Forms.TextBox 
$objTextBox2.Location = New-Object System.Drawing.Size(95, 165) 
$objTextBox2.Width = '215'
$winform.Controls.Add($objTextBox2)

$Clearbuttn = New-Object system.Windows.Forms.Button
$Clearbuttn.text = "Clear output"
$Clearbuttn.AutoSize = $true
$Clearbuttn.location = New-Object System.Drawing.Point(10, 215)
$Clearbuttn.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$Clearbuttn.Add_Click( { $objRichTextBox1.ResetText() })
$winform.Controls.Add($Clearbuttn)

$objRichTextBox1 = New-Object System.Windows.Forms.RichTextBox
$objRichTextBox1.Multiline = $True;
$objRichTextBox1.Location = New-Object System.Drawing.Size(10, 250)
$objRichTextBox1.Size = New-Object System.Drawing.Size(670, 240)
$objRichTextBox1.Scrollbars = "Vertical"
$objRichTextBox1.ReadOnly = $True
$objRichTextBox1.Anchor = [System.Windows.Forms.AnchorStyles]::Top `
    -bor [System.Windows.Forms.AnchorStyles]::Left `
    -bor [System.Windows.Forms.AnchorStyles]::Right `
    -bor [System.Windows.Forms.AnchorStyles]::Bottom
$winform.Controls.Add($objRichTextBox1)

$Set_Credential = New-Object system.Windows.Forms.Button
$Set_Credential.Location = New-Object System.Drawing.Size(10, 10) 
$Set_Credential.Size = New-Object System.Drawing.Size(100, 20)
$Set_Credential.Text = 'Set Credentials'
$Set_Credential.add_Click( { $Global:cred = Get-Credential mgmt\$env:USERNAME })
$winform.Controls.Add($Set_Credential)

$serverStatus = New-Object system.Windows.Forms.Button
$serverStatus.text = "Server status"
$serverStatus.Width = '160'
$serverStatus.location = New-Object System.Drawing.Point(330, 10)
$serverStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$serverStatus.Add_Click( { serverstatus })
$winform.Controls.Add($serverStatus)

$restartServer = New-Object system.Windows.Forms.Button
$restartServer.text = "Restart server(s)"
$restartServer.Width = '160'
$restartServer.location = New-Object System.Drawing.Point(330, 40)
$restartServer.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$restartServer.Add_Click( { restartserver })
$winform.Controls.Add($restartServer)

$stopServer = New-Object system.Windows.Forms.Button
$stopServer.text = "Stop Server(s)"
$stopServer.Width = '160'
$stopServer.location = New-Object System.Drawing.Point(330, 70)
$stopServer.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$stopServer.Add_Click( { stopserver })
$winform.Controls.Add($stopServer)

$startserver = New-Object system.Windows.Forms.Button
$startserver.text = "Start Server(s)"
$startserver.Width = '160'
$startserver.location = New-Object System.Drawing.Point(330, 100)
$startserver.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$startserver.Add_Click( { startServer })
$winform.Controls.Add($startserver)

$getCheckpoint = New-Object system.Windows.Forms.Button
$getCheckpoint.text = "Get Checkpoint"
$getCheckpoint.Width = '160'
$getCheckpoint.location = New-Object System.Drawing.Point(520, 130)
$getCheckpoint.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$getCheckpoint.Add_Click( { getchekcpoints })
$winform.Controls.Add($getCheckpoint)

$removeCheckpoint = New-Object system.Windows.Forms.Button
$removeCheckpoint.text = "Remove Checkpoint"
$removeCheckpoint.Width = '160'
$removeCheckpoint.location = New-Object System.Drawing.Point(330, 130)
$removeCheckpoint.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$removeCheckpoint.Add_Click( { removecheckpoints })
$winform.Controls.Add($removeCheckpoint)

$takeCheckpoint = New-Object system.Windows.Forms.Button
$takeCheckpoint.text = "Create Checkpoint"
$takeCheckpoint.Width = '160'
$takeCheckpoint.location = New-Object System.Drawing.Point(330, 160)
$takeCheckpoint.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$takeCheckpoint.Add_Click( { coldcheckpoint })
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
$SCCMClientAction = New-Object System.Windows.Forms.ComboBox
$SCCMClientAction.Width = '160'
$SCCMClientAction.Items.AddRange($clientaction)
$SCCMClientAction.location = New-Object System.Drawing.Point(520, 10)
$SCCMClientAction.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$SCCMClientAction.SelectedIndex = '0'
$winform.Controls.Add($SCCMClientAction)

$RunSCCMClientAction = New-Object system.Windows.Forms.Button
$RunSCCMClientAction.text = "Run SCCMClientAction"
$RunSCCMClientAction.Width = '160'
$RunSCCMClientAction.location = New-Object System.Drawing.Point(520, 40)
$RunSCCMClientAction.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$RunSCCMClientAction.Add_Click( { Run-SCCMClientAction })
$winform.Controls.Add($RunSCCMClientAction)

$RemoveSCCMCache = New-Object system.Windows.Forms.Button
$RemoveSCCMCache.text = "Remove SCCM Cache"
$RemoveSCCMCache.Width = '160'
$RemoveSCCMCache.location = New-Object System.Drawing.Point(520, 70)
$RemoveSCCMCache.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$RemoveSCCMCache.Add_Click( { installstatus })
$winform.Controls.Add($RemoveSCCMCache)

$installStatus = New-Object system.Windows.Forms.Button
$installStatus.text = "Installation Status"
$installStatus.Width = '160'
$installStatus.location = New-Object System.Drawing.Point(520, 100)
$installStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$installStatus.Add_Click( { installstatus })
$winform.Controls.Add($installStatus)

$textboxlable3 = New-Object System.Windows.Forms.Label
$textboxlable3.Text = "AppName:"
$textboxlable3.Location = New-Object System.Drawing.Size(315, 195)
$textboxlable3.AutoSize = $True
$winform.Controls.Add($textboxlable3)

$objTextBox3 = New-Object System.Windows.Forms.TextBox 
$objTextBox3.Location = New-Object System.Drawing.Size(375, 190) 
$objTextBox3.Width = '305'

$winform.Controls.Add($objTextBox3)

$textboxlable4 = New-Object System.Windows.Forms.Label
$textboxlable4.Text = "File Hash:"
$textboxlable4.Location = New-Object System.Drawing.Size(120, 225)
$textboxlable4.AutoSize = $True
$winform.Controls.Add($textboxlable4)

$objTextBox4 = New-Object System.Windows.Forms.TextBox 
$objTextBox4.Location = New-Object System.Drawing.Size(180, 220)
$objTextBox4.Width = '500'
$winform.Controls.Add($objTextBox4)

$textboxlable5 = New-Object System.Windows.Forms.Label
$textboxlable5.Text = "App Version:"
$textboxlable5.Location = New-Object System.Drawing.Size(10, 195)
$textboxlable5.AutoSize = $True
$winform.Controls.Add($textboxlable5)

$objTextBox5 = New-Object System.Windows.Forms.TextBox 
$objTextBox5.Location = New-Object System.Drawing.Size(95, 190) 
$objTextBox5.Width = '215'
$winform.Controls.Add($objTextBox5)

# Code goes here:

Function serverstatus() {
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Checking server status...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $objRichTextBox1.AppendText(
            (Get-SCVirtualMachine $_ | select-object name, status | out-string)
        )
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()
    }
}

Function restartserver() {
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Restarting server(s)...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $objRichTextBox1.AppendText((restart-computer $_ -force -ErrorAction SilentlyContinue))
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()
    }
}
Function stopserver() {
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Stopping server(s)...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $objRichTextBox1.AppendText((Get-SCVirtualMachine $_ |  Stop-SCVirtualMachine -Shutdown))
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret() 
    }
}

Function removecheckpoints() {
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Removing checkpoint(s)...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $objRichTextBox1.AppendText((Get-SCVirtualMachine $_ | select-object name, status | out-string))
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()
    }
}

Function coldcheckpoint() {
    $description = $objTextBox2.Text
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Creating checkpoint...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $objRichTextBox1.AppendText((Get-SCVirtualMachine $server | New-SCVMCheckpoint -Description $description -RunAsynchronously))
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()   
    }
}

Function getchekcpoints() {
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Getting checkpoint(s)...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $checkpoints = Get-SCVirtualMachine $_ | Get-SCVMCheckpoint
        if ($checkpoints) {
            $checkpoints | foreach {
                $objRichTextBox1.AppendText("Name: " + $_.Name)
                $objRichTextBox1.AppendText((" Description: " + $_.Description | out-string))
                $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
                $objRichTextBox1.ScrollToCaret()
            }
        }
    }
}

Function startServer() {
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Starting server(s)...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $objRichTextBox1.AppendText((Get-SCVirtualMachine $server |  start-SCVirtualMachine))
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()   
    }
}

Function Run-SCCMClientAction {

    $ClientAction = $SCCMClientAction.Text
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Running SCCM action: ${ClientAction}...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $ActionResults = @()
        Try { 
            $ActionResults = Invoke-Command -ComputerName $_ -Credential $credentials { param($ClientAction)
 
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
 
            } -ArgumentList $ClientAction -ErrorAction Stop | Select-Object @{n = 'ServerName'; e = { $_.pscomputername } }, "Action name", Status
        }  
        Catch {
            Write-Error $_.Exception.Message 
        }
        $objRichTextBox1.AppendText((return $ActionResults))
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()
    }
} 

Function removesccmcache() {

    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Removing SCCM cache...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    $objTextBox1.Lines | foreach {
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
            $objRichTextBox1.AppendText((return $true))
            $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
            $objRichTextBox1.ScrollToCaret()
        }
    }
}

Function triggerinstall() {

    $hash = $objTextBox4.Text
    $appversion = $objTextBox5.Text
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Starting app installation...`n")

    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    
    $objTextBox1.Lines | foreach {
        $objRichTextBox1.AppendText((
          
                Invoke-Command -ComputerName $_ -ScriptBlock { param($appname)

                    Function Trigger-AppInstallation {
 
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
                }))
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()
    }
}

Function installstatus() {

    $hash = $objTextBox4.Text
    $appversion = $objTextBox5.Text
    if ($objTextBox1.Lines) {
        $objRichTextBox1.AppendText("Checking installation status...`n")
    }
    else {
        $objRichTextBox1.AppendText("ERROR: No host(s).`n")
    }
    $objTextBox1.Lines | foreach {

        $res = Invoke-Command -ComputerName $_ -ArgumentList($hash, $appversion) -ScriptBlock {
            $hash = $args[0]
            $appversion = $args[1]
            $installed = $null

            $FileHash = Get-FileHash -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll' -ErrorAction SilentlyContinue
            $version = (Get-Item -Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.dll').Versioninfo.FileVersion

            if (($version -eq $appversion -and $FileHash.Hash -eq $hash)) {
                echo "$env:COMPUTERNAME SP patch ready $(get-date)"
            }
            else {
                echo "Not installed yet."
            }
        }
        $objRichTextBox1.AppendText($res + "`n")
        $objRichTextBox1.SelectionStart = $objRichTextBox1.TextLength
        $objRichTextBox1.ScrollToCaret()
    }
}
[void]$winform.ShowDialog()
