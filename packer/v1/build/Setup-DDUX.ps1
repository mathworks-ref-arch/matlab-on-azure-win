<#
.SYNOPSIS
    Enables MATLAB DDUX to allow MathWorks to gain insights into how this product is being used.

.DESCRIPTION
    The script sets environment variables to enable MathWorks to gain insights into the usage of this product, aiding in the improvement of MATLAB.
    It's important to note that your content and information within your files are not shared with MathWorks.
    To opt out of this service, simply delete this file.

.EXAMPLE
    Set-DDUX

.NOTES
    Copyright 2024 The MathWorks, Inc.
    The $ErrorActionPreference variable is set to 'Stop' to ensure that any errors encountered during the function execution will cause the script to stop and throw an error.
#>
function Set-DDUX {

    Write-Output 'Starting Set-DDUX...'

    [Environment]::SetEnvironmentVariable("MW_CONTEXT_TAGS", "MATLAB:AZURE:PACKERFILE:V1", "Machine")
    [Environment]::SetEnvironmentVariable("MW_DDUX_FORCE_ENABLE", "$true", "Machine")

    Write-Output 'Done with Set-DDUX.'
}


try {
    $ErrorActionPreference = 'Stop'
    Set-DDUX
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "WARNING - An error occurred while running script 'Setup-DDUX': $ScriptPath. Error: $_"
}
