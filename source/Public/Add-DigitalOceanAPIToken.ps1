function Add-DigitalOceanAPIToken
{
    <#
    .SYNOPSIS
    Adds a DigitalOcean API token to the user environment.

    .DESCRIPTION
    This function securely stores a DigitalOcean API token in the user's environment variables. The token is required for authenticating with the DigitalOcean API and should have appropriate permissions for the operations you plan to perform.

    .PARAMETER Token
    The DigitalOcean API token to store in the environment. This should be a valid API token with appropriate permissions for your intended operations.

    .EXAMPLE
    Add-DigitalOceanAPIToken -Token "dop_v1_53f12345678901234567890abcdef"

    This example adds the specified DigitalOcean API token to the user environment.

    .EXAMPLE
    "dop_v1_53f12345678901234567890abcdef" | Add-DigitalOceanAPIToken

    This example demonstrates using pipeline input to add the API token to the user environment.
    #>


    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [String]
        $Token
    )
    begin
    {
        #Content

    }
    process
    {
        Write-Verbose "Preparing to set the environment variable DIGITALOCEAN_TOKEN for DigitalOcean API authentication."

        try
        {
            if ([System.Environment]::OSVersion.Platform -eq 'Win32NT')
            {
                # Windows - use User scope for persistent storage
                Write-Verbose "Setting environment variable for Windows using User scope."
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $Token, [System.EnvironmentVariableTarget]::User)
            }
            else
            {
                # Linux/macOS - use Process scope and recommend manual persistence
                Write-Verbose "Setting environment variable for Linux/macOS using Process scope."
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $Token, [System.EnvironmentVariableTarget]::Process)

                Write-Warning "On Linux/macOS, the token is set for the current session only. To persist across sessions, add 'export DIGITALOCEAN_TOKEN=`"$Token`"' to your shell profile (~/.bashrc, ~/.zshrc, etc.)"
            }

            Write-Verbose "Environment variable DIGITALOCEAN_TOKEN for DigitalOcean API has been set successfully."
        }
        catch
        {
            Write-Error "Failed to set environment variable DIGITALOCEAN_TOKEN. Error: $($_.Exception.Message)"
        }
    }
    end
    {
        #Content

    }
}
