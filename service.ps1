# One-liner to search for services
while ($true) {$i= read-host "DisplayName" ;service | where {$_.DisplayName -imatch "$i" -or $_.Name -imatch "$i"} | ft -AutoSize}
