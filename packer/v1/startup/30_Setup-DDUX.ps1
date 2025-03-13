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
    Copyright 2025 The MathWorks, Inc.
#>
function Set-DDUX {

    Write-Output 'Starting Set-DDUX...'

    [Environment]::SetEnvironmentVariable('MW_DDUX_FORCE_ENABLE', $true, [System.EnvironmentVariableTarget]::Machine)

    # Endpoint and header for the Azure Instance Metadata Service
    $IMDSEndpoint = "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
    $Header = @{ "Metadata" = "true" }

    $Response = Invoke-RestMethod -Uri $IMDSEndpoint -Headers $Header

    # Extract the tag value for "mw-app"
    $MWAppTag = $Response.compute.tagsList | Where-Object { $_.name -eq "mw-app" } | Select-Object -ExpandProperty value


    if ( $MWAppTag -eq 'cloudcenter' ) {
        # If machine is deployed from Cloud Center, set appropriate DDUX values as environment variables
        $CloudCenterDDUXValue = 'MATLAB:CLOUD_CENTER:V1'
        $CurrentContextValue = [Environment]::GetEnvironmentVariable('MW_CONTEXT_TAGS', [System.EnvironmentVariableTarget]::Machine)

        if ($CurrentContextValue -and ($CurrentContextValue -notmatch "$CloudCenterDDUXValue")) {
            # If a current context is already set and does not include the Cloud Center DDUX value, update the context to include it
            [System.Environment]::SetEnvironmentVariable('MW_CONTEXT_TAGS', "$CurrentContextValue,$CloudCenterDDUXValue", [System.EnvironmentVariableTarget]::Machine)
        } elseif ($CurrentContextValue -eq '') {
            [System.Environment]::SetEnvironmentVariable('MW_CONTEXT_TAGS', "$CloudCenterDDUXValue", [System.EnvironmentVariableTarget]::Machine)
        }

    }

    Write-Output 'Done with Set-DDUX.'
}


try {
    Set-DDUX
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "WARNING - An error occurred while running script 'Set-DDUX': $ScriptPath. Error: $_"
}
