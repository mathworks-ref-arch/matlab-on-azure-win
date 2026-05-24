<#
.SYNOPSIS
    Cleans up residual files remaining from Packer.

.DESCRIPTION
    This script serves as the final step in the VHD building process, responsible for cleaning up residual files, including the installer files downloaded during the build scripts and removing .NET 6 runtimes.

.EXAMPLE
    Remove-TemporaryBuildFiles

.NOTES
    Copyright 2024-2026 The MathWorks, Inc.
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

    Write-Output 'Done with Remove-TemporaryBuildFiles.'
}

function Remove-DotNet6Runtimes {
    Write-Output 'Starting Remove-DotNet6Runtimes...'

    # List of .NET 6 runtime folders to target
    $runtimeFolders = @(
        "$env:ProgramFiles\dotnet\shared\Microsoft.NETCore.App",
        "$env:ProgramFiles\dotnet\shared\Microsoft.AspNetCore.App",
        "$env:ProgramFiles (x86)\dotnet\shared\Microsoft.NETCore.App",
        "$env:ProgramFiles (x86)\dotnet\shared\Microsoft.AspNetCore.App"
    )

    foreach ($path in $runtimeFolders) {
        if (-not (Test-Path $path)) {
            Write-Output "Path not found: $path"
            continue
        }

        Get-ChildItem -Path $path -Directory | ForEach-Object {
            # Check if the directory name matches a .NET 6 version pattern (e.g., 6.0, 6.0.1)
            if ($_.Name -match '^6\.\d+(\.\d+)?$') {
                $path = $_.FullName
                Write-Output "Removing .NET 6 runtime: $path"
                try {
                    Remove-Item -Path $path -Recurse -Force
                } catch {
                    Write-Output "WARNING: Failed to remove: $path - $($PSItem.Exception.Message)"
                }
            }
        }
    }

    Write-Output 'Done with Remove-DotNet6Runtimes.'
}

function Cleanup{
    Remove-TemporaryBuildFiles
    Remove-DotNet6Runtimes
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
