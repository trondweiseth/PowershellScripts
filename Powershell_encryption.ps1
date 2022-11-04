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
    $text = Get-Content $File
    $FilePath = $item.Directory
    if ($File -imatch '_decrypted' -or $File -imatch '_encrypted') {
        $FileName = $item.BaseName.Split('_')[0]
    }
    else {
        $FileName = $item.BaseName
    }
    if ($Action -eq 'Encrypt') {
        $text = Get-Content $File
        $encrypted = $text | ConvertTo-SecureString -AsPlainText -Force
        $fromsecurestring = $encrypted | ConvertFrom-SecureString
        $fromsecurestring | Out-File ${FilePath}${FileName}_encrypted.txt
        if (!$Silent) {
            Write-Host -f Green "Encrypted file saved at ${FilePath}${FileName}_encrypted.txt"
        }
    }

    if ($Action -eq 'Decrypt') {
        $tosecurestring = Get-Content ${FilePath}${FileName}_encrypted.txt | ConvertTo-SecureString
        $tosecurestring | % {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($_)
            $Marshal::PtrToStringAuto($Bstr)
            } | Out-File ${FilePath}${FileName}_decrypted.txt
            if (!$Silent) {
                Write-Host -f Green "Decrypted file saved at ${FilePath}${FileName}_decrypted.txt"
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
    $FilePath = $item.Directory
    $FileName = $item.BaseName.Split('_')[0]
    $FullName = $item.FullName
    if (Test-Path ${FilePath}${FileName}_encrypted.txt) {
        echo "Encrypted script. Use Run-EncryptedScript $FullName" > $FullName
    }
    else {
        Encrypt $FullName -Action Encrypt -Silent
    }
    Encrypt ${FilePath}${FileName}_encrypted.txt -Action Decrypt -Silent
    cat ${FilePath}${FileName}_decrypted.txt > $FullName
    rm ${FilePath}${FileName}_decrypted.txt
    & $FullName
    echo "Encrypted script. Use Run-EncryptedScript $FullName" > $FullName
}
