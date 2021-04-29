while ($true)
{
    # Getting current time
    $CurrentTime = get-date -Format '%h%m'

    # Selecting a random time between 07:30 and 07:45
    $StartTime = Get-Random -Minimum 730 -Maximum 745

    #Waiting until the clock is matching the random time set.
    if ($CurrentTime -ne $StartTime)
    {
        sleep 29
    }

    # Running whatever is set. In ths case it will start Skype
    else
    {
        start-process "C:\Program Files (x86)\Microsoft Office\Office16\lync.exe"
    }

    # Breaking out of the loop and exiting the script
    break
}
