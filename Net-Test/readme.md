# Improved version of the built in Test-NetConnection function

The port test is using basic socket to see if the repote port is open.
And instead of using the slower Test-Netconnection ping, this script uses the faster Test-Connection to see if the rhost responds to icmp.

Some older powershell versions don't have the newer Test-Netconnection to test port connectivity. This script works on all versions of powershell.


SYNTAX

    Net-Test [[-rhost] <string>] [-port <int[]>] [-remote <string>] [-help]  [<CommonParameters>]

-Remote - Runs the test from a remote host towards the target host.
If you want to test the port connectivity back from the target host, ypu can use the -remote parameter
Example: 

    DC01 -> DC02 -> DC01: Net-Test -rhost DC02 -port 3389 -remote DC02
