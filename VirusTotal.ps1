Function VirusTotal() {

    param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $Files
    )
    Begin{}
    Process
    {
        foreach ($File in $Files) {
            $Hash = Get-FileHash -Algorithm MD5 $File | Select-Object -ExpandProperty Hash
            start Https://www.virustotal.com/gui/file/$Hash
        }
    }
    End{}
}
