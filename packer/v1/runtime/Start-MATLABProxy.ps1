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
    Copyright 2024-2025 The MathWorks, Inc.
    This script is invoked by Task Scheduler only.
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
    $Env:MWI_MATLAB_STARTUP_SCRIPT="cd C:\Users\$USER\Documents"
    # The MWI_AUTH_TOKEN variable declared below is set by line 45 of the 40_Setup-MATLABProxy.ps1 script in the startup folder. 
    # The script sets this variable to specify the authentication token for matlab-proxy. 
    # Do not uncomment or modify this variable declaration. 
    # $Env:MWI_AUTH_TOKEN=
    
    matlab-proxy-app
}

try {
    Start-MATLABProxy
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script: $ScriptPath. Error: $_"
    throw
}
