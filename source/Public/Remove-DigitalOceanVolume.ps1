function Remove-DigitalOceanVolume
{
    <#
    .SYNOPSIS
        Removes a DigitalOcean Block Storage volume.

    .DESCRIPTION
        The Remove-DigitalOceanVolume function removes a Block Storage volume from DigitalOcean.
        Volumes can be deleted by their unique ID or by their name and region combination.
        This function supports both deletion methods and includes comprehensive error handling
        with confirmation prompts to prevent accidental deletion of important data.

    .PARAMETER VolumeId
        The unique identifier of the volume to remove. This parameter is used for the
        ID-based deletion method and is mutually exclusive with the Name/Region parameters.

    .PARAMETER Name
        The name of the volume to remove. When using this parameter, the Region parameter
        is also required. This parameter is used for the name-based deletion method.

    .PARAMETER Region
        The region where the volume is located. This parameter is required when using
        the Name parameter for name-based deletion.

    .PARAMETER Force
        Bypasses the confirmation prompt and removes the volume immediately. Use with
        caution as this action cannot be undone.

    .PARAMETER WhatIf
        Shows what would happen if the cmdlet runs without actually executing the operation.

    .PARAMETER Confirm
        Prompts for confirmation before executing the volume deletion operation.

    .OUTPUTS
        System.Boolean
        Returns $true if the volume was successfully deleted, $false otherwise.

    .EXAMPLE
        Remove-DigitalOceanVolume -VolumeId "3d80cb72-342b-4aaa-b92e-4e4abb24a933"

        Removes the volume with the specified ID after prompting for confirmation.

    .EXAMPLE
        Remove-DigitalOceanVolume -Name "my-volume" -Region "nyc1" -Force

        Removes the volume named "my-volume" in the NYC1 region without prompting for confirmation.

    .EXAMPLE
        Remove-DigitalOceanVolume -VolumeId "3d80cb72-342b-4aaa-b92e-4e4abb24a933" -WhatIf

        Shows what would happen if the volume with the specified ID were to be removed.

    .EXAMPLE
        $volumeParams = @{
            Name   = "production-data"
            Region = "ams3"
            Force  = $true
        }
        Remove-DigitalOceanVolume @volumeParams

        Removes the volume using splatting for better readability with multiple parameters.

    .NOTES
        - Requires a valid DigitalOcean API token to be set using Add-DigitalOceanAPIToken
        - Volume deletion is permanent and cannot be undone
        - Volumes must be detached from any Droplets before they can be deleted
        - The Force parameter bypasses all confirmation prompts - use with extreme caution
        - Name-based deletion requires both Name and Region parameters
        - ID-based deletion only requires the VolumeId parameter

    .LINK
        https://docs.digitalocean.com/products/volumes/
        https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_delete
        https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_delete_byName
        Get-DigitalOceanVolume
        New-DigitalOceanVolume
    #>

    [CmdletBinding(DefaultParameterSetName = 'ById', SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', HelpMessage = 'The unique identifier of the volume to remove')]
        [ValidateNotNullOrEmpty()]
        [Alias('Id')]
        [string]$VolumeId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName', HelpMessage = 'The name of the volume to remove')]
        [ValidateNotNullOrEmpty()]
        [Alias('VolumeName')]
        [string]$Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName', HelpMessage = 'The region where the volume is located')]
        [ValidateNotNullOrEmpty()]
        [string]$Region,

        [Parameter(HelpMessage = 'Bypasses confirmation prompts and removes the volume immediately')]
        [switch]$Force
    )

    begin
    {
        Write-Verbose "Starting Remove-DigitalOceanVolume function"

        # Validate API token
        $token = Get-DigitalOceanAPIAuthorizationBearerToken
        if (-not $token)
        {
            throw "DigitalOcean API token not found. Please run Add-DigitalOceanAPIToken first."
        }

        # Set confirmation preference if Force is specified
        if ($Force -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }
    }

    process
    {
        try
        {
            # Determine deletion method and build target description
            if ($PSCmdlet.ParameterSetName -eq 'ById')
            {
                Write-Verbose "Removing volume by ID: $VolumeId"
                $target = "Volume with ID '$VolumeId'"
                $uri = "https://api.digitalocean.com/v2/volumes/$([uri]::EscapeDataString($VolumeId))"
            }
            else
            {
                Write-Verbose "Removing volume by name '$Name' in region '$Region'"
                $target = "Volume '$Name' in region '$Region'"
                $encodedName = [uri]::EscapeDataString($Name)
                $encodedRegion = [uri]::EscapeDataString($Region)
                $uri = "https://api.digitalocean.com/v2/volumes?name=$encodedName&region=$encodedRegion"
            }

            Write-Verbose "Target URI: $uri"

            # ShouldProcess check
            if ($PSCmdlet.ShouldProcess($target, "Remove"))
            {
                Write-Verbose "Calling DigitalOcean API to remove volume"

                # Get API token
                $Token = Get-DigitalOceanAPIAuthorizationBearerToken

                if ([string]::IsNullOrEmpty($Token))
                {
                    throw "DigitalOcean API token not found. Please run Add-DigitalOceanAPIToken first."
                }

                # Prepare headers
                $Headers = @{
                    "Content-Type"  = "application/json"
                    "Authorization" = "Bearer $Token"
                }

                # Make the API call
                Invoke-RestMethod -Method Delete -Uri $uri -Headers $Headers -ErrorAction Stop | Out-Null

                Write-Verbose "Volume deletion request completed successfully"
                Write-Output $true
            }
            else
            {
                Write-Verbose "Volume deletion cancelled by user"
                Write-Output $false
            }
        }
        catch
        {
            $errorMessage = "Failed to remove DigitalOcean volume: $($_.Exception.Message)"

            # Try to extract API error details
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
                        $apiError = $responseBody | ConvertFrom-Json
                        if ($apiError.message)
                        {
                            $errorMessage += " API Error: $($apiError.message)"
                        }
                        if ($apiError.errors)
                        {
                            $errorMessage += " Details: $($apiError.errors | ConvertTo-Json -Compress)"
                        }
                        Write-Verbose "Full API Response: $responseBody"
                    }
                }
                catch
                {
                    Write-Verbose "Could not parse API error response"
                }
            }

            # Handle specific error scenarios
            if ($_.Exception.Message -like "*404*" -or $_.Exception.Message -like "*Not Found*")
            {
                if ($PSCmdlet.ParameterSetName -eq 'ById')
                {
                    Write-Warning "Volume with ID '$VolumeId' was not found"
                }
                else
                {
                    Write-Warning "Volume '$Name' was not found in region '$Region'"
                }
                Write-Output $false
                return
            }

            # Re-throw specific token-related errors
            if ($_.Exception.Message -like "*token*" -or $_.Exception.Message -like "*401*")
            {
                throw $_.Exception.Message
            }

            Write-Error $errorMessage
            Write-Output $false
        }
    }

    end
    {
        Write-Verbose "Completed Remove-DigitalOceanVolume function"
    }
}
