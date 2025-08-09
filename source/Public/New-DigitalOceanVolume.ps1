function New-DigitalOceanVolume
{
    <#
    .SYNOPSIS
        Creates a new DigitalOcean Block Storage volume.

    .DESCRIPTION
        The New-DigitalOceanVolume function creates a new Block Storage volume in DigitalOcean.
        Volumes provide additional storage that can be attached to Droplets and provide persistent
        storage that survives Droplet destruction. This function supports creating volumes with
        custom names, sizes, regions, filesystem types, and labels.

    .PARAMETER Name
        The name of the volume. Must be unique within the region. The name must be lowercase
        and contain only letters, numbers, and hyphens. Must be between 1-64 characters and
        begin with a letter.

    .PARAMETER SizeGigabytes
        The size of the volume in gigabytes (GiB). Must be between 1 and 16384 GB. The volume size
        cannot be decreased after creation, but can be increased later.

    .PARAMETER Region
        The DigitalOcean region where the volume will be created (e.g., 'nyc1', 'sfo2', 'ams3').
        The volume must be created in the same region as the Droplet it will be attached to.

    .PARAMETER FilesystemType
        The filesystem to format the volume with. Valid options are 'ext4' and 'xfs'.
        If not specified, the volume will be created without formatting.

    .PARAMETER FilesystemLabel
        An optional label for the filesystem. Only applicable when FilesystemType is specified.
        Maximum 16 characters for ext4 filesystems or 12 characters for xfs filesystems.

    .PARAMETER Description
        An optional description for the volume to help identify its purpose or contents.

    .PARAMETER Tags
        An array of tags to apply to the volume for organization and billing purposes.
        Tags must be valid tag names (letters, numbers, hyphens, and underscores).

    .PARAMETER SnapshotId
        The ID of a volume snapshot to create the volume from. When specified, the volume
        will be created as a copy of the snapshot with the snapshot's data and size.

    .PARAMETER WhatIf
        Shows what would happen if the cmdlet runs without actually executing the operation.

    .PARAMETER Confirm
        Prompts for confirmation before executing the volume creation operation.

    .OUTPUTS
        DigitalOceanVolume
        Returns a DigitalOceanVolume object representing the newly created volume.

    .EXAMPLE
        New-DigitalOceanVolume -Name "my-volume" -SizeGigabytes 100 -Region "nyc1"

        Creates a new 100GB volume named "my-volume" in the NYC1 region without formatting.

    .EXAMPLE
        New-DigitalOceanVolume -Name "database-storage" -SizeGigabytes 500 -Region "sfo2" -FilesystemType "ext4" -FilesystemLabel "dbdata"

        Creates a new 500GB volume with ext4 filesystem and label "dbdata" in the SFO2 region.

    .EXAMPLE
        $tags = @("production", "database", "mysql")
        New-DigitalOceanVolume -Name "prod-db-vol" -SizeGigabytes 1000 -Region "ams3" -Description "Production MySQL database storage" -Tags $tags

        Creates a production database volume with tags and description.

    .EXAMPLE
        New-DigitalOceanVolume -Name "backup-restore" -Region "nyc1" -SnapshotId "3d80cb72-342b-4aaa-b92e-4e4abb24a933"

        Creates a volume from an existing snapshot, inheriting the snapshot's size and data.

    .NOTES
        - Requires a valid DigitalOcean API token to be set using Add-DigitalOceanAPIToken
        - Volume names must be unique within the region
        - Volumes can only be attached to Droplets in the same region
        - Volume size cannot be decreased after creation
        - Some regions may have different available filesystem types
        - Volume creation may take a few moments to complete

    .LINK
        https://docs.digitalocean.com/products/volumes/
        https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_create
        Get-DigitalOceanVolume
        Remove-DigitalOceanVolume
    #>

    [CmdletBinding(DefaultParameterSetName = 'CreateNew', SupportsShouldProcess)]
    [OutputType([DigitalOceanVolume])]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'The name of the volume')]
        [ValidatePattern('^[a-z][a-z0-9-]{0,63}$')]
        [Alias('VolumeName')]
        [string]$Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'CreateNew', HelpMessage = 'The size of the volume in gigabytes (1-16384)')]
        [ValidateRange(1, 16384)]
        [int]$SizeGigabytes,

        [Parameter(Mandatory = $true, HelpMessage = 'The DigitalOcean region where the volume will be created')]
        [ValidateNotNullOrEmpty()]
        [string]$Region,

        [Parameter(ParameterSetName = 'CreateNew', HelpMessage = 'The filesystem type to format the volume with')]
        [ValidateSet('ext4', 'xfs')]
        [string]$FilesystemType,

        [Parameter(ParameterSetName = 'CreateNew', HelpMessage = 'The filesystem label')]
        [ValidateScript({
            param($Value)
            if ($Value.Length -gt 16) {
                throw "FilesystemLabel cannot exceed 16 characters (ext4) or 12 characters (xfs)"
            }
            return $true
        })]
        [string]$FilesystemLabel,

        [Parameter(HelpMessage = 'Description for the volume')]
        [ValidateLength(0, 512)]
        [string]$Description,

        [Parameter(HelpMessage = 'Tags to apply to the volume')]
        [ValidateNotNull()]
        [string[]]$Tags = @(),

        [Parameter(Mandatory = $true, ParameterSetName = 'FromSnapshot', HelpMessage = 'The ID of a volume snapshot to create the volume from')]
        [ValidateNotNullOrEmpty()]
        [string]$SnapshotId
    )

    begin
    {
        Write-Verbose "Starting New-DigitalOceanVolume function"

        # Additional parameter validation
        if ($Name -cnotmatch '^[a-z][a-z0-9-]{0,63}$')
        {
            throw "Volume name '$Name' is invalid. Names must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
        }

        if ($PSBoundParameters.ContainsKey('FilesystemLabel'))
        {
            if ($PSBoundParameters.ContainsKey('FilesystemType'))
            {
                if ($FilesystemType -eq 'ext4' -and $FilesystemLabel.Length -gt 16)
                {
                    throw "Filesystem label cannot exceed 16 characters for ext4 filesystem"
                }
                elseif ($FilesystemType -eq 'xfs' -and $FilesystemLabel.Length -gt 12)
                {
                    throw "Filesystem label cannot exceed 12 characters for xfs filesystem"
                }
            }
            else
            {
                throw "FilesystemLabel cannot be specified without FilesystemType"
            }
        }

        # Validate API token
        $token = Get-DigitalOceanAPIAuthorizationBearerToken
        if (-not $token)
        {
            throw "DigitalOcean API token not found. Please run Add-DigitalOceanAPIToken first."
        }
    }

    process
    {
        try
        {
            Write-Verbose "Creating volume '$Name' in region '$Region'"

            # Build the request body
            $body = @{
                name   = $Name
                region = $Region
            }

            # Add parameters based on parameter set
            if ($PSCmdlet.ParameterSetName -eq 'CreateNew')
            {
                $body.size_gigabytes = $SizeGigabytes

                if ($PSBoundParameters.ContainsKey('FilesystemType'))
                {
                    $body.filesystem_type = $FilesystemType
                    Write-Verbose "Setting filesystem type to: $FilesystemType"
                }

                if ($PSBoundParameters.ContainsKey('FilesystemLabel'))
                {
                    if (-not $PSBoundParameters.ContainsKey('FilesystemType'))
                    {
                        Write-Warning "FilesystemLabel specified without FilesystemType. Label will be ignored."
                    }
                    else
                    {
                        $body.filesystem_label = $FilesystemLabel
                        Write-Verbose "Setting filesystem label to: $FilesystemLabel"
                    }
                }

                Write-Verbose "Creating new volume with size: ${SizeGigabytes}GB"
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'FromSnapshot')
            {
                $body.snapshot_id = $SnapshotId
                Write-Verbose "Creating volume from snapshot: $SnapshotId"
            }

            # Add optional parameters
            if ($PSBoundParameters.ContainsKey('Description'))
            {
                $body.description = $Description
                Write-Verbose "Setting description: $Description"
            }

            if ($Tags.Count -gt 0)
            {
                $body.tags = $Tags
                Write-Verbose "Setting tags: $($Tags -join ', ')"
            }

            # Convert body to JSON
            $jsonBody = $body | ConvertTo-Json -Depth 10
            Write-Verbose "Request body: $jsonBody"

            # ShouldProcess check
            $target = "Volume '$Name' in region '$Region'"
            if ($PSCmdlet.ParameterSetName -eq 'CreateNew')
            {
                $target += " (${SizeGigabytes}GB)"
            }
            else
            {
                $target += " (from snapshot $SnapshotId)"
            }

            if ($PSCmdlet.ShouldProcess($target, "Create"))
            {
                Write-Verbose "Calling DigitalOcean API to create volume"

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
                $response = Invoke-RestMethod -Method Post -Uri "https://api.digitalocean.com/v2/volumes" -Headers $Headers -Body $jsonBody -ErrorAction Stop

                if ($response -and $response.volume)
                {
                    Write-Verbose "Volume created successfully"

                    # Return the volume object
                    $volumeObject = [DigitalOceanVolume]::new($response.volume)
                    Write-Output $volumeObject
                }
                else
                {
                    Write-Warning "No valid response received from DigitalOcean API"
                    return $null
                }
            }
        }
        catch
        {
            $errorMessage = "Failed to create DigitalOcean volume '$Name': $($_.Exception.Message)"

            # Re-throw specific token-related errors
            if ($_.Exception.Message -like "*token*")
            {
                throw $_.Exception.Message
            }

            Write-Error $errorMessage
            return $null
        }
    }

    end
    {
        Write-Verbose "Completed New-DigitalOceanVolume function"
    }
}
