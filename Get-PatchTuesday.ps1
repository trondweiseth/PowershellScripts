$today = Get-Date
$tuesday = $today.AddDays(((2 - [int]$today.DayOfWeek) % 7 + 7) % 7)
$patchTime = Get-Date -Date "$($tuesday.ToString("yyyy-MM-dd")) 19:00:00"
    
if($patchTime -ge $today) {
  $timeUntilPatch = New-TimeSpan -Start $today -End $patchTime
  return "Patch Tuesday is on $($patchTime.ToString("dddd dd. MMMM yyyy HH:mm")). Time until patch release: $($timeUntilPatch.Days) days, $($timeUntilPatch.Hours) hours, $($timeUntilPatch.Minutes) minutes, $($timeUntilPatch.Seconds) seconds."
} else {
  $nextTuesday = $today.AddDays(((2 - [int]$today.DayOfWeek) % 7 + 14) % 7)
  $patchTime = Get-Date -Date "$($nextTuesday.ToString("yyyy-MM-dd")) 19:00:00"
  $timeUntilPatch = New-TimeSpan -Start $today -End $patchTime
  return "Patch Tuesday has already passed this week. The next patch Tuesday is on $($patchTime.ToString("dddd dd. MMMM yyyy HH:mm")). Time until patch release: $($timeUntilPatch.Days) days, $($timeUntilPatch.Hours) hours, $($timeUntilPatch.Minutes) minutes, $($timeUntilPatch.Seconds) seconds."
}

