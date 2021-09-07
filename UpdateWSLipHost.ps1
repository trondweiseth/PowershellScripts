$wslip =  wsl hostname -I
$hostsfilewslip = ((Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String "kali") -split " " | Select-Object -First 1).Trim()
(Get-Content C:\Windows\System32\drivers\etc\hosts).Replace("$hostsfilewslip", "$wslip") | Set-Content -path C:\Windows\System32\drivers\etc\hosts
