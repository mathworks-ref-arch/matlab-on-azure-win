<#
.SYNOPSIS
    Installs dependencies for reference architecture features.

.DESCRIPTION
    The Install-Dependencies function installs the required dependencies for the application.

.PARAMETER DcvInstallerUrl
    The URL for the NICE DCV installer.

.NOTES
    Copyright 2024 The MathWorks, Inc.
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
    Start-Process msiexec.exe -Wait -ArgumentList '/i C:\Windows\Temp\MicrosoftEdgeEnterpriseX64.msi /quiet /norestart /l*v C:\ProgramData\InstallationLogs\edge_install_msi.log'


    Write-Output 'Done with Install-EdgeBrowser.'
}

function Install-AzCLI {
    Write-Output 'Starting Install-AzCLI...'
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    Remove-Item .\AzureCLI.msi
    Write-Output 'Done with Install-AzCLI.'
}

function Install-Dependencies {
    param(
        [Parameter(Mandatory = $true)]
        [string] $DcvInstallerUrl,

        [Parameter(Mandatory = $true)]
        [string] $EdgeInstallerUrl
    )
   
    Get-NICEDCV -DcvInstallerUrl $DcvInstallerUrl
    Install-EdgeBrowser -EdgeInstallerUrl $EdgeInstallerUrl
    Install-AzCLI
}

try {
    $ErrorActionPreference = 'Stop'
    
    Write-Output 'Creating folder for storing logs'
    New-Item -Path 'C:\ProgramData\InstallationLogs' -ItemType Directory

    Install-Dependencies -DcvInstallerUrl $Env:DCV_INSTALLER_URL -EdgeInstallerUrl $Env:EDGE_INSTALLER_URL
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script 'Install-Dependencies': $ScriptPath. Error: $_"
    throw
}
