# One-liner to search for services
while ($true) { $i = read-host "Serrvice" ; Get-Service | select Status,Name,DisplayName,StartType,DependentServices | Where-Object { $_.DisplayName -imatch "$i" -or $_.Name -imatch "$i" } | Format-Table -AutoSize }
