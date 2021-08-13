# Improved version of the built in Test-NetConnection

The port test is a using basic socket to see if the port is open.
Instead of using the slower Test-Netconnection ICMP test, this script uses the faster Test-Connection to check for ICMP response.

Some older powershell versions don't have the newer Test-Netconnection to test for port connectivity. This script works on all versions of powershell.


SYNTAX

    Net-Test [[-rhost] <string>] [-port <string>] [-remote <string>] [-timeout <string>] [-help] [<CommonParameters>]

-Remote - Runs the test from a remote host towards rhost.
Ie. If you want to test the port connectivity back from the target host, ypu can use the -remote parameter
Example: 

    DC01 -> DC02 -> DC01: Net-Test -rhost DC01 -port 3389 -remote DC02
