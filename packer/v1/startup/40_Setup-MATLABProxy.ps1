<#
.SYNOPSIS
    Enables matlab-proxy to enable browser access to MATLAB.

.DESCRIPTION
    Creates self-signed certificates for secure communication via matlab-proxy. 
    Sets up matlab-proxy's authentication token to expect the user's VM password.
    Adds a firewall rule to allow matlab-proxy traffic.
    Invokes a task that starts matlab-proxy in the background.

.PARAMETER EnableBrowserAccess
    (Required) Check to determine if the user has enabled browser access.

.PARAMETER AuthToken
    (Required) Used to set the auth-token required to access MATLAB in a browser. Value is equivalent to the system password.

.EXAMPLE
    Set-MATLABProxy -EnableBrowserAccess "Yes" -AuthToken "<AUTH-TOKEN>"

.NOTES
    Copyright 2024-2025 The MathWorks, Inc.
#>

$LAUNCH_FILE = "$Env:ProgramFiles\MathWorks\matlab-proxy\Start-MatlabProxy.ps1"
$MATLAB_PROXY_PORT = "8123"

function Set-MATLABProxyUser {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Username
    )
    
    # Set up user-specifc configuration for matlab-proxy
    $(Get-Content $LAUNCH_FILE -Raw) -Replace '# \$USER=', ('$USER=' + $Username) | Set-Content $LAUNCH_FILE
}

function Set-MATLABProxyAuthToken {
    param(
        [Parameter(Mandatory = $true)]
        [string] $AuthToken
    )

    # Set up token-authentication for matlab-proxy
    $PasswordDec = "[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$AuthToken'))"
    (Get-Content $LAUNCH_FILE -Raw) -Replace '# \$Env:MWI_AUTH_TOKEN=', ('$Env:MWI_AUTH_TOKEN=' + $PasswordDec) | Set-Content $LAUNCH_FILE
}

function Set-MATLABProxyFirewallRule {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Port
    )

    # Open a firewall rule for matlab-proxy
    $RuleName = "matlab-proxy - Allow TCP"
    if (-not (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName $RuleName -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow
    }
}

function Start-MATLABProxy {
    $TaskName = "matlab-proxy-task"
    Enable-ScheduledTask -TaskName $TaskName
    Start-ScheduledTask -TaskName $TaskName
}

function Set-MATLABProxy {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Port,

        [Parameter(Mandatory = $true)]
        [string] $Username,

        [Parameter(Mandatory = $true)]
        [string] $AuthToken
    )
    
    if ($Env:EnableMATLABProxy -eq "Yes") {
        Set-MATLABProxyUser -Username $Username
        Set-MATLABProxyAuthToken -AuthToken $AuthToken
        Set-MATLABProxyFirewallRule -Port $Port 
        Start-MATLABProxy
    }
}

try {
    Set-MATLABProxy -Port $MATLAB_PROXY_PORT -Username $Env:Username -AuthToken $Env:Password
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script: $ScriptPath. Error: $_"
    throw
}