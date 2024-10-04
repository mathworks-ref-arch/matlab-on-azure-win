<#
.SYNOPSIS
    Invokes the Microsoft Sysprep tool to capture custom Windows image.

.DESCRIPTION
    Invokes the Microsoft Sysprep tool to capture custom Windows image. 

.EXAMPLE
    Invoke-Sysprep

.NOTES
    Copyright 2024 The MathWorks, Inc.
    The $ErrorActionPreference variable is set to 'Stop' to ensure that any errors encountered during the function execution will cause the script to stop and throw an error.
#>
function Invoke-Sysprep {
    Write-Output 'Starting Invoke-Sysprep...'

    & "$Env:SystemRoot\System32\Sysprep\Sysprep.exe" /oobe /generalize /quiet /quit
    
    # Start a stopwatch for timing
    $TimeoutDuration = 300
    $ExpectedImageState = 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE'
    $Stopwatch = New-Object System.Diagnostics.Stopwatch
    $Stopwatch.Start()
    while($Stopwatch.Elapsed.TotalSeconds -le $TimeoutDuration) { 
        $ImageState = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State'
        if ($ImageState.ImageState -ne $ExpectedImageState) { 
            Write-Output $ImageState.ImageState
            Start-Sleep -Seconds 10  
        } 
        else { 
            break 
        } 
    }
    $Stopwatch.Stop()
    if ($ImageState.ImageState -ne $ExpectedImageState) { 
        $FinalImageState = $ImageState.ImageState
        Write-Error "Image stage is $FinalImageState after $TimeoutDuration but was expected to be $ExpectedImageState"
    }

    Write-Output 'Done with Invoke-Sysprep.'
}


try {
    $ErrorActionPreference = 'Stop'
    Invoke-Sysprep
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "ERROR - An error occurred while running script 'Invoke-Sysprep': $ScriptPath. Error: $_"
    throw
}
