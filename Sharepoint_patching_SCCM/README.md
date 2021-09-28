# Sharepoint Patching SCCM

First run Initiate_Serverlists.ps1 to create server lists for each enviroment.

Run Sharepointpatching.ps1 or copy the content to your PS profile. Read the script header before running.

To get all commands run: Get-Command SP-*

You need to assign a server list before running the other commands. Use: SP-Servers . I.e: SP-Servers TEST. (Can use tab to toggle through all enviroments)
