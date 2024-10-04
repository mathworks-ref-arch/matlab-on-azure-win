<#
.SYNOPSIS
    Sets MATLABRoot environment variable

.DESCRIPTION
    Sets the MATLABRoot environment variable to the full path of the parent directory of the MATLAB installation.

.NOTES
    Copyright 2024 The MathWorks, Inc.
#>

try {
   $Env:MATLABRoot = (Get-Item (Get-Command matlab).Path).Directory.Parent.FullName
}
catch {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Output "WARNING - An error occurred while running script 'env': $ScriptPath. Error: $_"
}
