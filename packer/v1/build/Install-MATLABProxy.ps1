<#
.SYNOPSIS
    Installs the matlab-proxy Python package.

.DESCRIPTION
    Installs the matlab-proxy Python package.

.PARAMETER Version
    matlab-proxy version number. e.g. 0.10.0

.EXAMPLE
    Install-MATLABProxy -Version "0.23.0"

.LINK
    https://github.com/mathworks/matlab-proxy

.NOTES
    Copyright 2024-2025 The MathWorks, Inc.
    The function sets $ErrorActionPreference to 'Stop' to ensure that any errors encountered during the installation process will cause the script to stop and throw an error.
#>

$MATLAB_PROXY_FOLDER = "$Env:ProgramFiles\MathWorks\matlab-proxy"

function Install-MATLABProxyPythonPackage {

    param(
        [Parameter(Mandatory = $false)]
        [string] $Version
    )
    
    Write-Output 'Starting Install-MATLABProxyPythonPackage...'

    $InstallLocation = "$MATLAB_PROXY_FOLDER\python-package"

    if ($Version -eq "") {
        & $Env:ProgramFiles\Python310\python.exe -m pip install matlab-proxy --target $InstallLocation 
    }
    else {
        & $Env:ProgramFiles\Python310\python.exe -m pip install matlab-proxy==$Version --target $InstallLocation 
    }

    Write-Output 'Done with Install-MATLABProxyPythonPackage.'
}

function Install-MATLABProxyLauncherScript {
    Write-Output 'Starting Install-MATLABProxyLauncherScript...'

    $RuntimeSource = 'C:\Windows\Temp\runtime'
    $DestinationFolder = "$MATLAB_PROXY_FOLDER"
    
    New-Item $DestinationFolder -Type Directory -Force
    Copy-Item "$RuntimeSource\Start-MatlabProxy.ps1" -Destination "$DestinationFolder\Start-MatlabProxy.ps1"
    
    Write-Output 'Done with Install-MATLABProxyLauncherScript.'
}

function Install-MATLABProxyTask {
    Write-Output 'Starting Install-MATLABProxyTask...'

    # Create a new Scheduled Task
    $taskName = "matlab-proxy-task"
    $taskDescription = "Starts matlab-proxy on system boot."

    # Define task parameters
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$MATLAB_PROXY_FOLDER\Start-MatlabProxy.ps1`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
    
    # Create and register the task
    $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description $taskDescription
    Register-ScheduledTask -TaskName $taskName -InputObject $task

    # Disable the task so it does not run before the startup scripts (on first machine boot)
    Disable-ScheduledTask -TaskName $taskName

    Write-Output 'Done with Install-MATLABProxyTask.'
}

function Install-MATLABProxy {

    param(
        [Parameter(Mandatory = $false)]
        [string] $Version
    )

    Install-MATLABProxyPythonPackage -Version $Version
    Install-MATLABProxyLauncherScript
    Install-MATLABProxyTask
}

try {
    $ErrorActionPreference = 'Stop'
    Install-MATLABProxy -Version $Env:MATLAB_PROXY_VERSION
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script: $ScriptPath. Error: $_"
    throw
}
