# One-liner to search for services
while ($true) { $i = read-host "Service" ; Get-Service | Select-Object Status,Name,DisplayName,StartType,DependentServices | Where-Object { $_.DisplayName -imatch "$i" -or $_.Name -imatch "$i" } | Format-Table -AutoSize }
