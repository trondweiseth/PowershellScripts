Function Encrypt {

    param
    (
        [Parameter(Mandatory=$true)]
        [string]$File,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Encrypt','Decrypt')]
        [string]$Action,

        [Parameter(Mandatory=$false)]
        [switch]$Silent
    )

    $item = Get-Item $File
    $Data = Get-Content $File
    $FullName = $item.FullName

    if ($Action -eq 'Encrypt') {
        $text = Get-Content $File
        $encrypted = $Data | ConvertTo-SecureString -AsPlainText -Force
        $fromsecurestring = $encrypted | ConvertFrom-SecureString
        $fromsecurestring | Out-File $FullName
        if (!$Silent) {
            Write-Host -f Green "Encrypted file $FullName"
        }
    }

    if ($Action -eq 'Decrypt') {
        $tosecurestring = Get-Content $FullName | ConvertTo-SecureString
        $tosecurestring | % {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($_)
            $Marshal::PtrToStringAuto($Bstr)
            } | Out-File $FullName
            if (!$Silent) {
                Write-Host -f Green "Decrypted file $FullName"
            }
    }
}

function Run-EncryptedScript {

    param
    (
        [Parameter(Mandatory=$true)]
        [string]$File
    )
    
    $item = Get-Item $File
    $FullName = $item.FullName
    Encrypt ${FilePath}${FileName}_encrypted.txt -Action Decrypt -Silent
    & $FullName
}
