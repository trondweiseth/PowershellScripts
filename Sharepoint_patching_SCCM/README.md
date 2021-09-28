# Sharepoint Patching SCCM

First run Initiate_Serverlists.ps1 to create server lists for each enviroment.

Run Sharepointpatching.ps1 or copy the content to your PS profile. Read the script header before running.

To get all commands run: Get-Command SP-*

You need to assign a server list before running the other commands. Use: SP-Servers . I.e: SP-Servers TEST. (Can use tab to toggle through all enviroments)

Commands:

    SP-ClearSCCMCache       - Clearing SCCM Cache
    SP-CreateCheckpoints    - Creating a checkpoint
    SP-ForceStopServers     - Forced shutdown locally from VM's
    SP-GetApplications      - Getting application information from software center on VM's
    SP-GetCheckpoints       - Getting available checkpoints
    SP-InstallationStatus   - Checking if an application from software center is installed by hash
    SP-RemoveCheckpoints    - Removing checkpoints
    SP-RunSCCMClientAction  - Running SCCM clien actions
    SP-Servers              - Assigning a server list to run rest of the commands toward. Need to be ran first.
    SP-StartServers         - Starting VM's through VMM
    SP-StopServers          - Stopping VM's through VMM
    SP-TestConnection       - Testing ICMP towards VM's
    SP-TriggerInstallation  - Starting installation of an application on VM's
    SP-VMConnect            - Connecting to VM's through RDP
    SP-VMStatus             - Checking VM status (Running or PowerOff) through VMM
