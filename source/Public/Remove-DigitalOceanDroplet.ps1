function Remove-DigitalOceanDroplet
{
    <#
    .SYNOPSIS
        Removes a DigitalOcean Droplet.

    .DESCRIPTION
        The Remove-DigitalOceanDroplet function permanently deletes a Droplet from your DigitalOcean account.
        You can target a single Droplet by its unique identifier or remove all Droplets that share a specific tag.
        The function implements ShouldProcess support (WhatIf/Confirm), high impact confirmation, robust
        error handling with API response parsing, and clear verbose output for traceability.

    .PARAMETER DropletId
        The unique identifier of the Droplet to remove. Mutually exclusive with the Tag parameter.

    .PARAMETER Tag
        Deletes ALL Droplets associated with the specified tag. Mutually exclusive with the DropletId parameter.
        Use with extreme caution as multiple Droplets may be deleted.

    .PARAMETER Force
        Bypasses confirmation prompts and executes the delete operation immediately.

    .OUTPUTS
        System.Boolean
        Returns $true when the delete request was sent successfully. Returns $false when the operation
        was cancelled, the Droplet(s) were not found, or an error occurred (non‑terminating).

    .EXAMPLE
        Remove-DigitalOceanDroplet -DropletId "123456789" -Confirm:$false

        Removes the Droplet with the specified ID after confirmation (or immediately if -Confirm:$false used).

    .EXAMPLE
        Remove-DigitalOceanDroplet -Tag "web-cluster" -Force

        Deletes all Droplets that have the tag "web-cluster" without prompting for confirmation.

    .EXAMPLE
        Remove-DigitalOceanDroplet -DropletId "123456789" -WhatIf

        Shows what would happen if the Droplet were deleted, without performing the operation.

    .EXAMPLE
        $removeParams = @{ DropletId = '987654321'; Force = $true }
        Remove-DigitalOceanDroplet @removeParams

        Removes the specified Droplet using splatting for readability.

    .NOTES
        - Destructive operation: deletion cannot be undone.
        - When using -Tag ALL Droplets with that tag will be deleted.
        - Requires a valid API token configured via Add-DigitalOceanAPIToken.
        - Supports PowerShell 5.1+.
        - Uses private helper Invoke-DigitalOceanAPI for consistent request handling.

    .LINK
        https://docs.digitalocean.com/reference/api/digitalocean/#tag/Droplets/operation/droplets_destroy
        New-DigitalOceanDroplet
    #>

    [CmdletBinding(DefaultParameterSetName = 'ById', SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', HelpMessage = 'The unique identifier of the Droplet to remove.')]
        [ValidateNotNullOrEmpty()]
        [Alias('Id')]
        [string]
        $DropletId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByTag', HelpMessage = 'Deletes ALL Droplets that have the specified tag.')]
        [ValidateNotNullOrEmpty()]
        [Alias('TagName')]
        [string]
        $Tag,

        [Parameter(HelpMessage = 'Bypasses confirmation prompts and removes the Droplet(s) immediately.')]
        [switch]
        $Force
    )

    begin
    {
        Write-Verbose 'Starting Remove-DigitalOceanDroplet function'

        # Token validation (will throw if missing)
        $null = Get-DigitalOceanAPIAuthorizationBearerToken

        if ($Force -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }
    }

    process
    {
        try
        {
            if ($PSCmdlet.ParameterSetName -eq 'ById')
            {
                $escapedId = [uri]::EscapeDataString($DropletId)
                $apiPath = "droplets/$escapedId"
                $target = "Droplet with ID '$DropletId'"
                $parameters = $null
            }
            else
            {
                $escapedTag = [uri]::EscapeDataString($Tag)
                $apiPath = 'droplets'
                $target = "All Droplets with tag '$Tag'"
                $parameters = @{ tag_name = $escapedTag }
            }

            if ($PSCmdlet.ShouldProcess($target, 'Remove'))
            {
                Write-Verbose "Deleting target: $target"
                if ($parameters)
                {
                    Invoke-DigitalOceanAPI -APIPath $apiPath -Method DELETE -Parameters $parameters | Out-Null
                }
                else
                {
                    Invoke-DigitalOceanAPI -APIPath $apiPath -Method DELETE | Out-Null
                }
                Write-Verbose 'Droplet delete request completed successfully'
                Write-Output $true
            }
            else
            {
                Write-Verbose 'Droplet deletion cancelled by user'
                Write-Output $false
            }
        }
        catch
        {
            $errorMessage = "Failed to remove DigitalOcean Droplet(s): $($_.Exception.Message)"

            # Attempt to extract detailed API error (if available)
            if ($_.Exception.Response)
            {
                try
                {
                    $responseStream = $_.Exception.Response.GetResponseStream()
                    $reader = New-Object System.IO.StreamReader($responseStream)
                    $responseBody = $reader.ReadToEnd()
                    $reader.Close()

                    if ($responseBody)
                    {
                        $apiError = $null
                        try { $apiError = $responseBody | ConvertFrom-Json } catch { }
                        if ($apiError -and $apiError.message)
                        {
                            $errorMessage += " API Error: $($apiError.message)"
                        }
                        if ($apiError -and $apiError.id)
                        {
                            $errorMessage += " (id: $($apiError.id))"
                        }
                        Write-Verbose "Full API Response: $responseBody"
                    }
                }
                catch
                {
                    Write-Verbose 'Could not parse API error response'
                }
            }

            # Not Found handling
            if ($_.Exception.Message -like '*404*' -or $_.Exception.Message -like '*Not Found*')
            {
                if ($PSCmdlet.ParameterSetName -eq 'ById')
                {
                    Write-Warning "Droplet with ID '$DropletId' was not found"
                }
                else
                {
                    Write-Warning "No Droplets found with tag '$Tag'"
                }
                Write-Output $false
                return
            }

            # Token / auth errors should bubble up
            if ($_.Exception.Message -like '*401*' -or $_.Exception.Message -match 'token')
            {
                throw $_.Exception
            }

            Write-Error $errorMessage
            Write-Output $false
        }
    }

    end
    {
        Write-Verbose 'Completed Remove-DigitalOceanDroplet function'
    }
}
