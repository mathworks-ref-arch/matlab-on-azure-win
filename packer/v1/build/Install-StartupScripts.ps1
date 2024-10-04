<#
.SYNOPSIS
    Installs Startup scripts.

.DESCRIPTION
    Installs startup scripts to be executed within the VM during provisioning via the ARM template.

.EXAMPLE
    Install-StartupScripts

.NOTES
    Copyright 2024 The MathWorks, Inc.
    The $ErrorActionPreference variable is set to 'Stop' to ensure that any errors encountered during the function execution will cause the script to stop and throw an error.
#>
function Install-StartupScripts {
    Write-Output 'Starting Install-StartupScripts...'

    $StartupPath = "$Env:ProgramFiles\MathWorks\Startup"

    if (-not (Test-Path $StartupPath)) { [Void]( New-Item -Path $StartupPath -ItemType Directory ) }

    Move-Item -Path 'C:\Windows\Temp\startup\*' -Destination $StartupPath
    Remove-Item -Path 'C:\Windows\Temp\startup\'

    Write-Output 'Done with Install-StartupScripts.'
}


try {
    $ErrorActionPreference = 'Stop'
    Install-StartupScripts
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script 'Install-StartupScripts': $ScriptPath. Error: $_"
    throw
}
