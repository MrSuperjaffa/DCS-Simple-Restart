<# Basic DCS Restart Script
Copyright (C) 2021 Tony Unruh

Contact: Mr_Superjaffa#5430 on Discord

Description: This script starts DCS and SRS and tracks the process ID. Additionally it checks the log incase of soft locks.
             In case of restart the script will run itself in a new Powershell window.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/.
#>

## EDIT HERE
$DCSFolder = "C:\Program Files\Eagle Dynamics\DCS World"
$SRSFolder = "C:\Program Files\DCS-SimpleRadio-Standalone"
$WriteFolder = "DCS.openbeta_server"
$MaxMissionTime = "21600"

# DONT TOUCH BEYOND HERE
$ErrorActionPreference = "SilentlyContinue"
$VERSION = "v1.1.0"
$CycleTime = 1 # This defines the time between checks
$LogThreshold = 300 # This defines how long the dcs.log can remain unchanged before the script believes DCS has soft locked

$LogNew = @{} # Defining our arrays
$LogOld = @{}

Write-Output "Basic DCS Restart Script $VERSION by Mr_Superjaffa#5430"
Write-Output "-------------------------------------------------------"

Write-Output "Copyright (C) 2021 Tony Unruh
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain conditions."

# Starting DCS
$DCSProcess = Start-Process -FilePath "$DCSFolder\bin\DCS.exe" -ArgumentList "--server","--norender","-w $WriteFolder" -PassThru
$DCSPID = $DCSProcess.ID
Write-Output "Started DCS. Process ID: $DCSPID"

# Starting SRS
Set-Location -Path $SRSFolder # This is critical otherwise SRS won't pull the config. smh cmdline
$SRSProcess = Start-Process -FilePath "$SRSFolder\SR-Server.exe" -PassThru 
$SRSPID = $SRSProcess.ID
Write-Output "Started SRS. Process ID: $SRSPID"

# Waiting 15 seconds before entering the loop
Start-Sleep -Seconds 15

Do {
    # Checking the log incase of soft lock
    $LogInfo = Get-Item -Path "$HOME\Saved Games\$WriteFolder\Logs\dcs.log"
    If (($(Get-Date) - $LogInfo.LastWriteTime).TotalSeconds -lt $LogThreshold) {
        Write-Output "Log is still outputting."
    } Else {
        Write-Output "Log has stopped outputting! DCS might be soft locked. Resarting..."
        Break
    }


    # Checking that the DCS process is still running
    If (Get-Process -ID $DCSProcess.ID) {
        Write-Output "DCS is still running."
    } Else {
        Write-Output "DCS is not running! Restarting..."
        Break
    }

    # Checking if SRS is running, if not it'll quietly restart it.
    If (Get-Process -ID $SRSProcess.ID) {
        Write-Output "SRS is still running."
    } Else {
        Write-Output "SRS is not running! Quietly restarting..."
        Set-Location -Path $SRSFolder
        $SRSProcess = Start-Process -FilePath "$SRSFolder\SR-Server.exe" -PassThru
        $SRSPID = $SRSProcess.ID
    }

    # Checking the runtime against our requested time
    $ElapsedTime = $(Get-Date) - $DCSProcess.StartTime
    [int]$TimeRemaining = $MaxMissionTime - $ElapsedTime.TotalSeconds
    If ($ElapsedTime.TotalSeconds -lt $MaxMissionTime) {
        Write-Output "Server time remaining: $TimeRemaining"
    } Else {
        Write-Output "Server time elapsed! Restarting..."
        Break
    }

    # Sleeping before we cycle again
    Start-Sleep -Seconds $CycleTime
    Clear-Host
    Write-Output "Basic DCS Restart Script $VERSION by Mr_Superjaffa#5430"
    Write-Output "-------------------------------------------------------"
    Write-Output "DCS PID: $DCSPID"
    Write-Output "SRS PID: $SRSPID"
} While (0 -lt 1)

# We've now exited the loop and are now expected to restart.

Write-Output "Server is now restarting!"

# Stopping the server processes
Stop-Process -ID $DCSProcess.ID
Stop-Process -ID $SRSProcess.ID

Write-Output "Waiting 30 seconds..."
Start-Sleep -Seconds 30

# Starting the script in another Powershell instance
$NewProcess = $MyInvocation.MyCommand.Path # This fetches the scripts name and location to be run again.
Start-Process Powershell -ArgumentList "`"-File`" `"$NewProcess`""

Exit