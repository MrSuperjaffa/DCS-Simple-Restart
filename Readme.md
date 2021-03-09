Basic DCS Restart Script v1.1.0

Author: Mr_Superjaffa#5430
        Contact me on Discord for assistance

Description: This script starts DCS and SRS and tracks the process ID. Additionally it checks the log incase of soft locks.
              In case of restart the script will run itself in a new Powershell window.

DISCLAIMER: Always be sure to double check scripts you download and only run scripts you trust.
            I Mr_Superjaffa take no responsibility for any damage or lost files caused by the execution of this script.

Usage: Place the files in a seperate folder, named however you like.
       Open the Start-DCS-Server.ps1 file in a text editor.
       Edit the following variable to meet your needs:

       $DCSFolder = "G:\Program Files\Eagle Dynamics\DCS World"
       This is your DCS installation folder. Just point to the root directory.

       $SRSFolder = "D:\Program Files\DCS-SimpleRadio-Standalone"
       This is your SRS installation folder. Just point to the root directory.

       $WriteFolder = "DCS"
       This is the Saved Games folder DCS will be operation in. Just include the name.

       $MaxMissionTime = "21600"
       This is the max time for the server to run. Expressed in seconds.

       After configuration, run the .bat file

       Before the script can restart, you'll need to change the PowerShell ExecutionPolicy.
       You'll need to set this to Unrestricted.
       Open a PowerShell window as Administrator and enter 'Set-ExecutionPolicy Unrestricted'

       Please take note that this will allow unsigned scripts to run on your machine.
       
Task Scheduling: Here's an example of creating a task to auto run this script on machine logon:

    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Bypass -File `"C:\Server\Server Scripts\Start-DCS-Server.ps1`""
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName Start-DCS-Server -Description "Jaffa was here; Starts the DCS server"

    Usage of this would require that the machine be set to autologin. This can be configured with this Windows Sysinternals tool: https://docs.microsoft.com/en-us/sysinternals/downloads/autologon