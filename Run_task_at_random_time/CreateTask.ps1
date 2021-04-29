$Action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument 'powershell.exe -ExecutionPolicy bypass "StartupTask.ps1"'
$Trigger = New-ScheduledTaskTrigger -Daily -at 07:30
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName "Startup MyProgram" -InputObject $Task -User $env:USERDOMAIN\$env:USERNAME -force
