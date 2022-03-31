# Fetching all ad trusts in your domain and adding to a variable
[void]($Global:ADTrusts = (Get-ADTrust -Filter * | select -ExpandProperty name) + (Get-ADDomain).dnsroot)

# Main function
Function ADLookup {

    param
    (
        [Parameter(Mandatory = $false)]
        [string]
        $UserName,

        [Parameter(Mandatory = $false)]
        [string]
        $GroupName,

        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                $ADTrust = $ADTrusts | Where-Object -FilterScript { $_ -match $wordToComplete }
                return $ADTrust
            } )]
        [string]
        $ServerName = "mgmt.basefarm.net",

        [Parameter(Mandatory = $false)]
        [switch]
        $NestedGroups,

        [Parameter(Mandatory = $false)]
        [switch]
        $AllDomains,

        [Parameter(Mandatory = $false)]
        [switch]
        $UserDetails,

        [Parameter(Mandatory = $false)]
        [string]
        $SearchUser
    )

    # Look up wich groups a user is member of
    function UserGroupLookup {
        try {
            $res1 = (Get-ADGroup -Filter { name -like "*" }  -Server $ServerName -Properties members -ErrorAction Stop) | where {$_.members -imatch $UserName} | select name | Tee-Object -Variable Global:members
            if ($res1) {
                Write-Host -ForegroundColor Green "=== Domain result from $ServerName ==="
                Write-Host -ForegroundColor Yellow "=== Members of $member ==="
                return $res1
            }
            if ($UserDetails) {
                $res2 = Get-ADUser $UserName -Server $ServerName -Properties DisplayName,Created,AccountExpirationDate,PasswordExpired,PasswordNeverExpires,BadLogonCount,LastBadPasswordAttempt,PasswordLastSet,LastLogonDate,LockedOut,lockoutTime,logonCount,Modified,ObjectGUID | fl * -ErrorAction Stop
                if ($res2) {
                    Write-Host -ForegroundColor Green "=== Domain result from $ServerName ==="
                    Write-Host -ForegroundColor Yellow "=== Members of user $UserName ==="
                    return $res2
                }
             }
         }
         catch {
            if ($error[0] -imatch "Unable to contact the server") {
                Write-Host -ForegroundColor Red "Unable to contact the server."
            } else {
                $error[0]
            }
         }
    }

    # Drill down each member of AD group one level
    function NestedGroupsLoop {
        try {
            foreach ($member in ($members | select -ExpandProperty name)) {
                $res = (Get-ADGroup -Filter { name -like $member }  -Server $ServerName -Properties members -ErrorAction Stop).members -split(',') | where {$_ -imatch "CN"} | foreach {$_.split("=")[1]}
                if ($res) {
                    Write-Host -ForegroundColor Green "=== Domain result from $ServerName ==="
                    Write-Host -ForegroundColor Yellow "=== Members of $member ==="
                    return $res
                }
            }
        }
         catch {
            if ($error[0] -imatch "Unable to contact the server") {
                Write-Host -ForegroundColor Red "Unable to contact the server."
            } else {
                $error[0]
            }
        }
    }

    # Look up members of AD group
    function GroupmemberLookup {
        try {
            $res = (Get-ADGroup -Filter { name -like $GroupName }  -Server $ServerName -Properties members -ErrorAction Stop).members -split(',') | where {$_ -imatch "CN"} | foreach {$_.split("=")[1]} | Tee-Object -Variable Global:members
            if ($res) {
                Write-Host -ForegroundColor Green "=== Domain result from $ServerName ==="
                Write-Host -ForegroundColor Yellow "=== Members of $member ==="
                return $res
            }
        }
        catch {
            if ($error[0] -imatch "Unable to contact the server") {
                Write-Host -ForegroundColor Red "Unable to contact the server."
            } else {
                $error[0]
            }
        }
    }

    # Look up users in AD
    function UserSearch {
        $res = (Get-ADUser -Filter {name -like $SearchUser -or displayname -like $SearchUser} -Server $ServerName -Properties name,DisplayName).name| fl *
        if ($res) {
            Write-Host -ForegroundColor Green "=== Domain result from $ServerName ==="
            return $res
        }
    }

    if ($SearchUser) {
        if ($AllDomains) {
            foreach ($ServerName in $ADTrusts) {
                UserSearch
            }
        } else {
            UserSearch
        }
    }

    if ($GroupName) {
        if ($AllDomains) {
            foreach ($ServerName in $ADTrusts) {
                GroupmemberLookup
            }
        } else {
            GroupmemberLookup
        }
    }

    if ($NestedGroups) {
        if ($AllDomains) {
            foreach ($ServerName in $ADTrusts) {
                NestedGroupsLoop
            }
        } else {
            NestedGroupsLoop
        }
    }

    if ($UserName) {
        if ($AllDomains) {
            foreach ($ServerName in $ADTrusts) {
                UserGroupLookup
            }
        } else { UserGroupLookup }
    }
}
