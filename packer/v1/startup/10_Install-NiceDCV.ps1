<#
.SYNOPSIS
    Installs NiceDCV on the VM 

.DESCRIPTION
    Installs NiceDCV on the VM

.PARAMETER Username
    (Required) Admin username for the Virtual Machine

.EXAMPLE
    Install-NiceDCV -Username "<Username>"

.NOTES
    Copyright 2024 The MathWorks, Inc.
#>
function Install-NiceDCV {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Username
    )
    
    Write-Output 'Starting Install-NICEDCV...'

    Write-Output 'Silent Install NiceDCV installer with default OWNER=$Username'
    Start-Process msiexec.exe -Wait -ArgumentList "/i C:\Windows\Temp\nice-dcv-server.msi /quiet /norestart /l*v C:\ProgramData\InstallationLogs\dcv_install_msi.log AUTOMATIC_SESSION_OWNER=$Username"
    
    Write-Output 'Starting sleep to avoid registry key not found errors'
    Start-Sleep -Seconds 10
    
    $NiceDCVRegistryKey='Microsoft.PowerShell.Core\Registry::\HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv'

    Write-Output 'Setting the Maximum number of concurrent clients per session'
    New-ItemProperty -Path "$NiceDCVRegistryKey\session-management\automatic-console-session" -Name 'max-concurrent-clients' -PropertyType DWord -Value 1 -Force

    Write-Output 'Enabling NiceDCV clipboard feature'
    New-ItemProperty -Path "$NiceDCVRegistryKey\clipboard" -Name 'enabled' -PropertyType DWord -Value 1 -Force

    Write-Output 'Enabling File Sharing feature'
    New-ItemProperty -Path "$NiceDCVRegistryKey\session-management\automatic-console-session" -Name 'storage-root' -PropertyType String -Value '%home%' -Force
    
    Write-Output 'Putting the DCV exe on PATH'
    [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";C:\Program Files\NICE\DCV\Server\bin", [EnvironmentVariableTarget]::Machine)
    
    If ($Env:NiceDCVLicense -match '.+@.+') {
        Write-Output "License NICE DCV using license: $Env:NiceDCVLicense"
        New-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::\HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\license" -Name 'license-file' -PropertyType String -Value $Env:NiceDCVLicense -Force
    } Else {
        Write-Output 'License NICE DCV using demo license'
    }
    
    Write-Output 'Restarting the DCV Server to allow the changes to take place'
    Restart-Service dcvserver

    Write-Output 'Done with Install-NICEDCV.'
}


try {
    If ($Env:EnableNiceDCV -eq 'Yes') {
        Install-NiceDCV -Username $Env:Username
    }
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "WARNING - An error occurred while running script '10_Install-NiceDCV': $ScriptPath. Error: $_"
}
