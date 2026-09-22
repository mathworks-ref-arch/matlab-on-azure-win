<#
.SYNOPSIS
    Configures and launches matlab-proxy.

.DESCRIPTION
    Configures and launches matlab-proxy.

.EXAMPLE
    Start-MATLABProxy

.LINK
    https://github.com/mathworks/matlab-proxy/blob/main/Advanced-Usage.md

.NOTES
    Copyright 2024-2026 The MathWorks, Inc.
    This script is invoked by Task Scheduler at machine startup.
#>

# The USER variable declared below is set by line 34 of the 40_Setup-MATLABProxy.ps1 script in the startup folder. 
# The script sets this variable to specify the default directory for MATLAB accessed via matlab-proxy. 
# Do not uncomment or modify this variable declaration. 
# $USER=

function Start-MATLABProxy {

    $PythonPackageLocation = "$Env:ProgramFiles\MathWorks\matlab-proxy\python-package" 

    # Set the environment variables below to configure your MATLAB Proxy settings. 
    # For detailed instructions, see https://github.com/mathworks/matlab-proxy/blob/main/Advanced-Usage.md
    $Env:PATH="$Env:PATH;$PythonPackageLocation\bin"
    $Env:PYTHONPATH="$PythonPackageLocation"
    $Env:MWI_APP_PORT='8123'
    $Env:MWI_ENABLE_SSL='true'
    $Env:MWI_ENABLE_TOKEN_AUTH='true'
    $Env:MWI_PROCESS_START_TIMEOUT='300'

    # Start MATLAB in the user's Documents folder.
    $MATLAB_STARTUP_FOLDER = "C:\Users\$USER\Documents"
    New-Item -ItemType Directory -Force -Path $MATLAB_STARTUP_FOLDER | Out-Null
    $Env:MWI_MATLAB_STARTUP_SCRIPT = "cd $MATLAB_STARTUP_FOLDER"
    # The MWI_AUTH_TOKEN variable declared below is set by line 45 of the 40_Setup-MATLABProxy.ps1 script in the startup folder.
    # The script sets this variable to specify the authentication token for matlab-proxy.
    # Do not uncomment or modify this variable declaration.
    # $Env:MWI_AUTH_TOKEN=

    matlab-proxy-app *>&1
}

$LogPath = "$Env:ProgramData\MathWorks\matlab-proxy.log"
Start-Transcript -Path $LogPath -Append | Out-Null
try {
    Start-MATLABProxy
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script: $ScriptPath. Error: $_"
    throw
}
finally {
    Stop-Transcript | Out-Null
}
