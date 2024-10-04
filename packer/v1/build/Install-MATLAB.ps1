<#
.SYNOPSIS
    Installs MATLAB using MPM.

.LINK
    https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md

.DESCRIPTION
        Installs MATLAB using MATLAB Package Manager.

.NOTES
    Copyright 2020-2024 The MathWorks, Inc.
    The $ErrorActionPreference variable is set to 'Stop' to ensure that any errors encountered during the function execution will cause the script to stop and throw an error.
#>

function Install-MATLABUsingMPM {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Release,

        [Parameter(Mandatory = $true)]
        [string] $Products,

        [Parameter(Mandatory = $false)]
        [string] $SourceURL
    )

    Write-Output 'Starting Install-MATLABUsingMPM...'

    Set-Location -Path $Env:TEMP

    # As a best practice, installing the latest version of mpm before calling it.
    Write-Output 'Installing mpm ...'
    Invoke-WebRequest -OutFile "$Env:TEMP\mpm.exe" -Uri 'https://www.mathworks.com/mpm/win64/mpm'

    $MpmLogFilePath = "$Env:TEMP\mathworks_$Env:USERNAME.log"

    Write-Output 'Installing products ...'
    $ProductsList = $Products -Split ' '
    try {
        # Check if SourceURL is empty
        if ($SourceURL.length -eq 0) {
            # Install MATLAB directly from the release and products list
            & "$Env:TEMP\mpm.exe" install `
                --release $Release `
                --products $ProductsList
        }
        else {
            # Dot-sourcing the Mount-MATLABSource script
            . 'C:\Windows\Temp\config\matlab\Mount-MATLABSource.ps1'
    
            # Temporary drive containing the source files for MATLAB and toolboxes install
            $MATLABSourceDrive = 'X'
            
            # Call Mount-MATLABSource function to mount the SMB File Share containing MATLAB installation files
            Mount-MATLABSource -SourceLocation "$SourceURL" -FileShareAlias "MATLABFILESHAREUSERNAME" -ShareKeyAlias "MATLABFILESHAREPASSWORD" -AzureKeyVault "$Env:AZURE_KEY_VAULT" -DriveToMount "$MATLABSourceDrive"
    
            # Check if the path exists on the mounted drive
            if (Test-Path -Path "${MATLABSourceDrive}:\dvd\archives") {
                # Install MATLAB from the mounted file share
                & "$Env:TEMP\mpm.exe" install `
                    --source "${MATLABSourceDrive}:\dvd\archives\" `
                    --products $ProductsList

                # Remove the source location
                Remove-SMBMapping -LocalPath "${MATLABSourceDrive}:" -Force -UpdateProfile
            }
            else {
                Write-Output "Unable to find file share mounted on ${MATLABSourceDrive} drive"
                exit 1
            }
        }
    }
    catch {
        # Log the content of the mpm log file if it exists
        if (Test-Path $MpmLogFilePath) {
            Get-Content -Path $MpmLogFilePath
        }
    
        # Ensure the file share is unmounted in case of an error
        if (Test-Path "${MATLABSourceDrive}:") {
            Remove-SMBMapping -LocalPath "${MATLABSourceDrive}:" -Force -UpdateProfile
        }
    
        throw
    }
    
    Write-Output 'Removing mpm ...'
    Remove-Item "$Env:TEMP/mpm.exe"

    if (Test-Path $MpmLogFilePath) {
        Remove-Item $MpmLogFilePath
    }

    Write-Output 'Done with Install-MATLABUsingMPM.'
}


function Initialize-MATLAB {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Release
    )

    Write-Output 'Starting Initialize-MATLAB ...'

    Write-Output "Copy license_info.xml file to enable MHLM licensing by default, create license directory if doesn't exist"
    $DestinationLicenseFolder = "$Env:ProgramFiles\MATLAB\$Release\licenses"
    if (!(Test-Path -Path $DestinationLicenseFolder)) {
        New-Item $DestinationLicenseFolder -Type Directory
    }
    Copy-Item 'C:\Windows\Temp\config\matlab\license_info.xml' -Destination $DestinationLicenseFolder

    Write-Output 'Set firewall rules for MATLAB'
    New-NetFirewallRule -DisplayName "MATLAB $Release" -Name "MATLAB $Release" -Action Allow -Program "C:\program files\matlab\$Release\bin\win64\matlab.exe"
    New-NetFirewallRule -DisplayName 'mw_olm' -Name 'mw_olm' -Action Allow -Program "C:\program files\matlab\$Release\bin\win64\mw_olm.exe"
    powershell -inputformat none -outputformat none -NonInteractive -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\MATLAB'"

    Write-Output 'Set registry keys to disable pop-ups in Windows'
    New-Item -Path 'HKLM:\System\CurrentControlSet\Control\Network\NewNetworkWindowOff\'
    New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE\'
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Value 1

    Write-Output 'Install MathWorks SSL Certificate ...'
    Install-Certificates -Url 'https://licensing.mathworks.com'

    Write-Output 'Move msa.ini file for Startup Accelerator'
    if (-not (Test-Path -Path "C:\ProgramData\MathWorks")){
        New-Item -ItemType "directory" -Path "C:\ProgramData\MathWorks"
    }
    Copy-Item "C:\Windows\Temp\config\matlab\startup-accelerator\$Env:RELEASE\msa.ini" -Destination 'C:\ProgramData\MathWorks\msa.ini'
   
    Generate-ToolboxCache -Release $Release

    Write-Output 'Done with Initialize-MATLAB.'
}


function Install-Certificates {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Url
    )

    Write-Output 'Starting Install-Certificates ...'

    $WebRequest = [Net.WebRequest]::CreateHttp($Url)
    $WebRequest.AllowAutoRedirect = $true
    $Chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain
    [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    # Request website
    try { $WebRequest.GetResponse() } catch {}

    # Creates Certificate
    $Certificate = $WebRequest.ServicePoint.Certificate.Handle

    # Build chain
    $Chain.Build($Certificate)
    $Cert = $Chain.ChainElements[$Chain.ChainElements.Count - 1].Certificate
    $Bytes = $Cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    Set-Content -Value $Bytes -Encoding byte -Path 'C:\Windows\Temp\mathworks_root_ca.cer'

    # Install the certificate
    Import-Certificate -FilePath 'C:\Windows\Temp\mathworks_root_ca.cer' -CertStoreLocation 'Cert:\LocalMachine\Root'

    # Cleanup
    [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
    Remove-Item 'C:\Windows\Temp\mathworks_root_ca.cer'

    Write-Output 'Done with Install-Certificates.'
}

function Install-Python {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PythonInstallerUrl
    )
    Set-Location C:\Windows\Temp
    Write-Output 'Starting Install-Python...'

    Invoke-WebRequest -Uri $PythonInstallerUrl -OutFile 'C:\Windows\Temp\python-installer.exe'

    Write-Output 'Python Installer downloaded successfully. Installing ...'
    Start-Process 'C:\Windows\Temp\python-installer.exe' -Wait -ArgumentList '/quiet InstallAllUsers=0 Include_launcher=0 TargetDir="C:\Program Files\PythonTemp"'

    Write-Output 'Done with Install-Python.'
}

function Uninstall-Python {
    Write-Output 'Starting Uninstall-Python...'

    Start-Process 'C:\Windows\Temp\python-installer.exe' -Wait -ArgumentList '/quiet /Uninstall'

    Write-Output 'Done with Uninstall-Python.'
}

function Generate-ToolboxCache {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Release
    )
   
    Install-Python -PythonInstallerUrl $Env:PYTHON_INSTALLER_URL 
    
    Write-Output 'Generate Toolbox cache xml if MATLAB version is greater than or equal to 2021b'
    # Toolbox cache generation is supported from R2021b onwards.
    if ($Release -ge 'R2021b') {
        & 'C:\Program Files\PythonTemp\python.exe' C:\Windows\Temp\config\matlab\generate_toolbox_cache.py "C:\Program Files\MATLAB\$Release" "C:\Program Files\MATLAB\$Release\toolbox\local"
    }
    else {
        Write-Host "Unable to generate Toolbox cache xml as version $Release is less than R2021b."
    }

    Uninstall-Python
}

function Add-DesktopShortcut {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Release
    )

    Write-Output 'Starting Add-DesktopShortcut ...'

    Write-Output 'Remove Azure VM desktop shortcuts.'

    $currentUser = [Environment]::UserName
    Remove-Item -Path "C:\Users\$currentUser\Desktop\*.website"

    Write-Output 'Add MATLAB shortcut in Desktop for all users.'
    Copy-Item -Path "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\MATLAB $Release\MATLAB $Release.lnk" -Destination 'C:\Users\Public\Desktop'

    Write-Output 'Done with Add-DesktopShortcut.'
}


function Install-MATLAB {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Release,

        [Parameter(Mandatory = $true)]
        [string] $Products,

        [Parameter(Mandatory = $false)]
        [string] $SourceURL
    )

    Install-MATLABUsingMPM -Release $Release -Products $Products -SourceURL $SourceURL
    Initialize-MATLAB -Release $Release
    Add-DesktopShortcut -Release $Release
}


try {
    $ErrorActionPreference = 'Stop' 
    Install-MATLAB -Release "$Env:RELEASE" -Products $Env:PRODUCTS -SourceURL $Env:MATLAB_SOURCE_LOCATION
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script 'Install-MATLAB': $ScriptPath. Error: $_"
    throw
}
