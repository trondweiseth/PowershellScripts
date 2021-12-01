# Module for testing udp connections between hosts.

Copy the script and run Import-Module TestUDPConnection.ps1 or function to the hosts that udp connection that are to be tested.

# Usage
    On the source host: Test-NetConnectionUDP -ComputerName dc01.contoso.net -Port 53 -SourcePort 10000 (sourceport defaults to 50000 if not set)
    On the destination host: Start-UDPServer -Port 50000 (port defaults to 10000 if not set)
