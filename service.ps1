# One-liner to search for services
while ($true) { $i = read-host "DisplayName" ; Get-Service | where { $_.DisplayName -imatch "$i" -or $_.Name -imatch "$i" } | Format-Table -AutoSize }
