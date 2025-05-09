<#
.SYNOPSIS
    Installs MATLAB Support Packages using MPM.

.LINK
    https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md

.NOTES
    Copyright 2024-2025 The MathWorks, Inc.
    The function sets $ErrorActionPreference to 'Stop' to ensure that any errors encountered during the installation process will cause the script to stop and throw an error.
#>


function Install-MATLABSPKGUsingMPM {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Release,

        [Parameter(Mandatory = $true)]
        [string] $Products,

        [Parameter(Mandatory = $false)]
        [string] $SourceURL
    )

    Write-Output 'Starting Install-MATLABSPKGUsingMPM...'
    Set-Location -Path $Env:TEMP

    # As a best practice, downloading the latest version of mpm before calling it.
    Write-Output 'Downloading mpm ...'
    
    Invoke-WebRequest -OutFile "$Env:TEMP\mpm.exe" -Uri 'https://www.mathworks.com/mpm/win64/mpm'

    $MpmLogFilePath = "$Env:TEMP\mathworks_$Env:USERNAME.log"

    Write-Output 'Installing products ...'
    $ProductsList = $Products -Split ' '

    try {
        if ( $SourceURL.length -eq 0 ) {
            & "$Env:TEMP\mpm.exe" install `
                --release $Release `
                --products $ProductsList
        }
        else {
            # Dot-sourcing the Mount-MATLABSource script
            . 'C:\Windows\Temp\config\matlab\Mount-MATLABSource.ps1'
    
            # Temporary drive containing the source files for SPKG install
            $MATLABSPKGSourceDrive = 'X'

            # Call Mount-MATLABSource function to mount the SMB File Share containing MATLAB installation files
            Mount-MATLABSource -SourceLocation "$SourceURL" -FileShareAlias "MATLABFILESHAREUSERNAME" -ShareKeyAlias "MATLABFILESHAREPASSWORD" -AzureKeyVault "$Env:AZURE_KEY_VAULT" -DriveToMount "$MATLABSPKGSourceDrive"
    
            # Check if the path exists on the mounted drive
            if (Test-Path -Path "${MATLABSPKGSourceDrive}:\dvd\archives") {

                # Install MATLAB from the mounted file share
                & "$Env:TEMP\mpm.exe" install `
                    --source "${MATLABSPKGSourceDrive}:\support_packages\" `
                    --products $ProductsList
                
                # Un-mount the Azure File Share
                Remove-SMBMapping -LocalPath "${MATLABSPKGSourceDrive}:" -Force -UpdateProfile
            }
            else {
                Write-Output "Unable to find file share mounted on ${MATLABSPKGSourceDrive} drive"
                exit 1
            }
            
        }
    }
    catch {
        if (Test-Path $MpmLogFilePath) {
            Get-Content -Path $MpmLogFilePath
        }

        # Ensure the file share is unmounted in case of an error
        if (Test-Path "${MATLABSPKGSourceDrive}:") {
            Remove-SMBMapping -LocalPath "${MATLABSPKGSourceDrive}:" -Force -UpdateProfile
        }        

        throw
    }

    Write-Output 'Removing mpm ...'
    Remove-Item "$Env:TEMP/mpm.exe"

    if (Test-Path $MpmLogFilePath) {
        Remove-Item $MpmLogFilePath
    }

    Write-Output 'Done with Install-MATLABSPKGUsingMPM.'
}

function Install-MATLABSupportPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Release,

        [Parameter(Mandatory = $true)]
        [string] $Products,

        [Parameter(Mandatory = $false)]
        [string] $SourceURL
    )
    Install-MATLABSPKGUsingMPM -Release $Release -Products $Products -SourceURL $SourceURL
}


try {
    $ErrorActionPreference = 'Stop'
    if (-not "$Env:SPKGS"){
        Write-Output 'No support packages provided to be installed. Installation skipped.'
        exit 0
    }
    Install-MATLABSupportPackages -Release $Env:RELEASE -Products $Env:SPKGS -SourceURL $Env:SPKG_SOURCE_LOCATION
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script 'Install-MATLABSupportPackages': $ScriptPath. Error: $_"
    throw
}
