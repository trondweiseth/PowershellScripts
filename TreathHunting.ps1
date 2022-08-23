Function TreathHunting() {

    param
    (
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $Search,

        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [ValidateSet('File','Domain','IP')]
        [string]
        $Query,

        [Parameter(Mandatory=$true)]
        [ValidateSet('VirusTotal','AilienVault')]
        [string]
        $Engine
    )

    Begin{
        $object   = $Search
        $VTfile   = "start https://www.virustotal.com/gui/file/"
        $VTdomain = "start https://www.virustotal.com/gui/domain/"
        $VTip     = "start https://www.virustotal.com/gui/ip-address/"
        $AVdomain = "start https://otx.alienvault.com/indicator/domain/"
        $AVfile   = "start https://otx.alienvault.com/indicator/file/"
        $AVip     = "start https://otx.alienvault.com/indicator/ip/"
    }
    Process
    {

        if ($Query -eq "File") {
            $Hashlist = [System.Collections.ArrayList]@()
            foreach ($File in $object) {
                $Hash = (Get-FileHash -Algorithm MD5 $File).Hash
                [void]$Hashlist.Add($Hash)
            }
            foreach ($object in $Hashlist) {
                if ($Engine -eq "VirusTotal") {
                    Invoke-Expression $VTfile$object
                } else {
                    Invoke-Expression $AVfile$object
                }
            }
        }

        if ($Query -eq "Domain") {
            if ($Engine -eq "VirusTotal") {
                Invoke-Expression $VTdomain$object
            } else {
                Invoke-Expression $AVdomain$object
            }
        }

        if ($Query -eq "IP") {
            if ($Engine -eq "VirusTotal") {
                Invoke-Expression $VTip$object
            } else {
                Invoke-Expression $AVip$object
            }
        }
    }
    End{
        Clear-Variable object
        if ($?) {Write-Host -ForegroundColor Green "Successful."}
    }
}
