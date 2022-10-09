Function Textframe {
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline)]
        $InputText
    )
    
    $Output = $InputText | Out-String
    $LongestLine=(($Output -split '[\n]') | Measure-Object -Maximum -Property Length).Maximum
    $Closer = ("#" * ($LongestLine + 3))
    $Closer
    $Output -split '[\n\r]' | ? {$_.trim() -ne "" } | % {
        $StringLength = $_ | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
        $Spacer = ($LongestLine - $StringLength)
        "# " + $_ + " " * $Spacer + "#"
    }
    $Closer
}
