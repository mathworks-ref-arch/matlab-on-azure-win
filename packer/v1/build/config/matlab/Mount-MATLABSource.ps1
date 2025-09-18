<#
.SYNOPSIS
    This script sets up a connection to an Azure File Share and mounts it as a drive on the local system.

.DESCRIPTION
    The `Mount-MATLABSource` function logs into Azure using a managed identity, retrieves the necessary credentials from Azure Key Vault, and attempts to mount an Azure File Share to a specified drive letter. The function includes a retry mechanism to handle temporary connectivity issues.

.PARAMETER SourceLocation
    The name of the Azure File Share.

.PARAMETER FileShareAlias
    The alias of the secret in Azure Key Vault that contains the username for the Azure File Share.

.PARAMETER ShareKeyAlias
    The alias of the secret in Azure Key Vault that contains the key for the Azure File Share.

.PARAMETER AzureKeyVault
    The name of the Azure Key Vault where the secrets are stored.

.PARAMETER DriveToMount
    The drive letter to which the Azure File Share will be mounted.

.EXAMPLE
    Mount-MATLABSource -SourceLocation "myfileshare" -FileShareAlias "myFileShareUsername" -ShareKeyAlias "myFileShareKey" -AzureKeyVault "myKeyVault" -DriveToMount "Z"

    This example mounts the Azure File Share "myfileshare" to the "Z" drive using credentials stored in the Azure Key Vault "myKeyVault".

.NOTES
    Copyright 2024-2025 The MathWorks, Inc.
#>

function Mount-MATLABSource {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceLocation,

        [Parameter(Mandatory=$true)]
        [string]$FileShareAlias,

        [Parameter(Mandatory=$true)]
        [string]$ShareKeyAlias,

        [Parameter(Mandatory=$true)]
        [string]$AzureKeyVault,

        [Parameter(Mandatory=$true)]
        [string]$DriveToMount
    )

    # Refresh the PATH to find az cli installation path.
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    az login --identity

    $Username = az keyvault secret show --name $FileShareAlias --vault-name $AzureKeyVault --query value -o tsv
    $Password = az keyvault secret show --name $ShareKeyAlias --vault-name $AzureKeyVault --query value -o tsv

    az logout
    # Mount credentials to mount with the Azure File Share
    $SecurePassword = ConvertTo-SecureString "$Password" -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential ("Azure\$Username", $SecurePassword)

    # Retry loop
    $MaxRetries = 5
    $DelaySeconds = 2
    for ($i = 1; $i -le $MaxRetries; $i++) {
        Write-Output "Attempt $i of $MaxRetries"
        $ConnectionTestResult = Test-NetConnection -ComputerName "$Username.file.core.windows.net" -Port 445
    
        if ($ConnectionTestResult.TcpTestSucceeded) {
            Write-Output "Connection successful on attempt $i."
            New-PSDrive -Name $DriveToMount -PSProvider FileSystem -Root "\\$Username.file.core.windows.net\$SourceLocation" -Credential $Credentials -Scope 'Global' -Persist
            Write-Output "The file share was successfully mounted to drive $DriveToMount!"
            return
        } else {
            $ExponentialDelay = [math]::Pow(2, $i - 1)
            Write-Output "Connection failed on attempt $i. Retrying in $($DelaySeconds * $ExponentialDelay) seconds..."
            Start-Sleep -Seconds ($DelaySeconds * $ExponentialDelay)
        }
    }
    
    if (-not $ConnectionTestResult.TcpTestSucceeded) {
        Write-Output "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
        exit 1
    }
}
