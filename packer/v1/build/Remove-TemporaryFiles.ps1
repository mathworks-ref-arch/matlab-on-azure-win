<#
.SYNOPSIS
    Cleans up residual files remaining from Packer.

.DESCRIPTION
    This script serves as the final step in the VHD building process, responsible for cleaning up residual files, including the installer files downloaded during the build scripts.

.EXAMPLE
    Remove-TemporaryBuildFiles

.NOTES
    Copyright 2024 The MathWorks, Inc.
    The $ErrorActionPreference variable is set to 'Stop' to ensure that any errors encountered during the function execution will cause the script to stop and throw an error.
#>

function Remove-TemporaryBuildFiles {
    Write-Output 'Starting Remove-TemporaryBuildFiles...'

    $pyInstallerPath = "C:\Windows\Temp\python-installer.exe"
    if (Test-Path $pyInstallerPath) {
        Remove-Item $pyInstallerPath
    }
    Remove-Item C:\Windows\Temp\script-*.ps1
    Remove-Item C:\Windows\Temp\config -Force -Recurse

    # Remove REMOVE_BEFORE_FLIGHT file
    if (Test-Path "C:\Program Files\MATLAB\R2024b\REMOVE_BEFORE_FLIGHT"){
        Remove-Item "C:\Program Files\MATLAB\R2024b\REMOVE_BEFORE_FLIGHT"
    } else {
        Write-Output "C:\Program Files\MATLAB\R2024b\REMOVE_BEFORE_FLIGHT does not exists."
    }


    Write-Output 'Done with Remove-TemporaryBuildFiles.'
}

function Cleanup{
    Remove-TemporaryBuildFiles
}

try {
    $ErrorActionPreference = 'Stop'
    Cleanup
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script 'Remove-TemporaryFiles': $ScriptPath. Error: $_"
    throw
}
