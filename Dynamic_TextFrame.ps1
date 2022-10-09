Function Textframe {
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline)]
        $InputText,
        $Sidewalls = "|",
        $Lines = "*"
    )
    
    $Output = $InputText | Out-String
    $LongestLine=(($Output -split '[\n]') | Measure-Object -Maximum -Property Length).Maximum
    $Closer = ("${Lines}" * ($LongestLine + 3))
    $Closer
    $Output -split '[\n\r]' | ? {$_.trim() -ne "" } | % {
        $StringLength = $_ | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
        $Spacer = ($LongestLine - $StringLength)
        "${Sidewalls} " + $_ + " " * $Spacer + "${Sidewalls}"
    }
    $Closer
}
