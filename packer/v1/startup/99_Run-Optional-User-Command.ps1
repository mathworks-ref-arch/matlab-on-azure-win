<#
.SYNOPSIS
    Runs optional user command.

.DESCRIPTION
    Executes an optional user command. This script will run as the final step in the VM startup process,
    potentially overriding any changes applied in previous scripts.

.PARAMETER OptionalUserCommand
    (Optional) Optional user command.

.EXAMPLE
    Invoke-OptionalUserCommand -OptionalUserCommand "<OPTIONAL_USER_COMMAND>"

.NOTES
    Copyright 2024 The MathWorks, Inc.
#>

function Invoke-OptionalUserCommand {

    param(
        [Parameter()]
        [string] $OptionalUserCommand
    )

    Write-Output 'Starting Invoke-OptionalUserCommand...'

    Write-Output "$OptionalUserCommand"

    if ([string]::IsNullOrWhiteSpace("$OptionalUserCommand")) {
        Write-Output 'No optional user command was passed.'
    }
    else {
        Write-Output 'The passed string is an inline PowerShell command.'
        Invoke-Expression "$OptionalUserCommand"
    }

    Write-Output 'Done with Invoke-OptionalUserCommand.'
}


try {
    Invoke-OptionalUserCommand -OptionalUserCommand $Env:OptionalUserCommand
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script '99_Run-Optional-User-Command': $ScriptPath. Error: $_"
    throw
}
