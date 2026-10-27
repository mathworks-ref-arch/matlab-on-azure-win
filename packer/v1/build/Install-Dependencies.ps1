<#
.SYNOPSIS
    Installs dependencies for reference architecture features.

.DESCRIPTION
    The Install-Dependencies function installs the required dependencies for the application.

.PARAMETER DcvInstallerUrl
    The URL for the NICE DCV installer.

.PARAMETER PythonInstallerUrl
    The URL for the Python installer.

.NOTES
    Copyright 2024-2026 The MathWorks, Inc.
    The $ErrorActionPreference variable is set to 'Stop' to ensure that any errors encountered during the function execution will cause the script to stop and throw an error.
#>

function Get-NICEDCV {
    param(
        [Parameter(Mandatory = $true)]
        [string] $DcvInstallerUrl
    )
    Set-Location C:\Windows\Temp
    Write-Output 'Starting Get-NICEDCV ...'
    (New-Object System.Net.WebClient).DownloadFile($DcvInstallerUrl, 'C:\Windows\Temp\nice-dcv-server.msi')
    Write-Output 'Done with Get-NICEDCV.'
}

function Install-EdgeBrowser {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EdgeInstallerUrl
    )
    Set-Location C:\Windows\Temp
    Write-Output 'Starting Install-EdgeBrowser...'
    
    Write-Output 'Downloading Edge browser msi file ...'
    $InstallerFile = 'C:\Windows\Temp\MicrosoftEdgeEnterpriseX64.msi'
    (New-Object System.Net.WebClient).DownloadFile($EdgeInstallerUrl, $InstallerFile)
    
    Write-Output 'Installing Edge browser ...'
    $Installer = Start-Process msiexec.exe -Wait -PassThru -ArgumentList '/i C:\Windows\Temp\MicrosoftEdgeEnterpriseX64.msi /quiet /norestart /l*v C:\ProgramData\InstallationLogs\edge_install_msi.log'

    # Exit code 3010 means the install succeeded and needs a restart, which the build does later.
    if ($Installer.ExitCode -ne 0 -and $Installer.ExitCode -ne 3010) {
        throw "Edge installation failed with exit code $($Installer.ExitCode). See C:\ProgramData\InstallationLogs\edge_install_msi.log."
    }

    $EdgeExecutable = @(
        "${Env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $EdgeExecutable) {
        throw 'msedge.exe not found after installing Edge.'
    }

    Write-Output "Edge version in this image: $((Get-Item $EdgeExecutable).VersionInfo.ProductVersion)"

    Write-Output 'Done with Install-EdgeBrowser.'
}

function Install-AzCLI {
    Write-Output 'Starting Install-AzCLI...'
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    Remove-Item .\AzureCLI.msi
    Write-Output 'Done with Install-AzCLI.'
}

function Install-Python {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PythonInstallerUrl
    )

    Write-Output 'Starting Install-Python...'

    Invoke-WebRequest -Uri $PythonInstallerUrl -OutFile 'C:\Windows\Temp\python.exe'

    Write-Output 'Python Installer downloaded successfully. Installing ...'
    Start-Process 'C:\Windows\Temp\python.exe' -Wait -ArgumentList "/quiet InstallAllUsers=1 TargetDir=`"$Env:PYTHON_INSTALL_PATH`""

    Write-Output 'Done with Install-Python.'
}

function Install-Dependencies {
    param(
        [Parameter(Mandatory = $true)]
        [string] $DcvInstallerUrl,
        
        [Parameter(Mandatory = $true)]
        [string] $PythonInstallerUrl,

        [Parameter(Mandatory = $true)]
        [string] $EdgeInstallerUrl
    )
   
    Get-NICEDCV -DcvInstallerUrl $DcvInstallerUrl
    Install-Python -PythonInstallerUrl $PythonInstallerUrl
    Install-EdgeBrowser -EdgeInstallerUrl $EdgeInstallerUrl
    Install-AzCLI
}

try {
    $ErrorActionPreference = 'Stop'
    
    Write-Output 'Creating folder for storing logs'
    New-Item -Path 'C:\ProgramData\InstallationLogs' -ItemType Directory

    Install-Dependencies -DcvInstallerUrl $Env:DCV_INSTALLER_URL -PythonInstallerUrl $Env:PYTHON_INSTALLER_URL -EdgeInstallerUrl $Env:EDGE_INSTALLER_URL
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script 'Install-Dependencies': $ScriptPath. Error: $_"
    throw
}
