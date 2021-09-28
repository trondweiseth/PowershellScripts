# PS. This server list is dynamic and you may have to update the list. This can also be done by running SP-Servers <enviroment> -EditFile

$ENV01 = @(
'server1.env01.contoso.local'
'server1.env01.contoso.local'
'server1.env01.contoso.local'
)

$ENV02 = @(
'server1.env02.contoso.local'
'server2.env02.contoso.local'
'server3.env02.contoso.local'
)

$TEST = @(
'server1.test.contoso.local'
'server2.test.contoso.local'
'server3.test.contoso.local'
)

$PROD = @(
'server1.prod.contoso.local'
'server2.prod.contoso.local'
'server3.prod.contoso.local'
)


New-Item -Path $HOME\Documents -Name SharepointHosts -ItemType "directory"
$FolderLocation =  "$HOME\Documents\SharepointHosts"

$ENV01.Trim() | Set-Content $FolderLocation\ENV01.txt
$ENV02.Trim() | Set-Content $FolderLocation\ENV02.txt
$TEST.Trim()  | Set-Content $FolderLocation\TEST.txt
$PROD.Trim()  | Set-Content $FolderLocation\PROD.txt
