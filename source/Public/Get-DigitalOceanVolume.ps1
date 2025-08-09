function Get-DigitalOceanVolume
{
    <#
    .SYNOPSIS
    Retrieves DigitalOcean block storage volumes with filtering and pagination support.

    .DESCRIPTION
    Get-DigitalOceanVolume retrieves block storage volumes from your DigitalOcean account.
    Returns strongly-typed DigitalOceanVolume objects with comprehensive volume information including
    size, region, attachment status, and filesystem details. Supports filtering by region,
    retrieving specific volumes by ID or name, and paginated results.

    .PARAMETER VolumeId
    Specifies the unique identifier of a specific volume to retrieve.
    When provided, returns only the volume with the matching ID.

    .PARAMETER VolumeName
    Specifies the name of a specific volume to retrieve.
    When provided, returns volumes with the matching name.

    .PARAMETER Region
    Filters volumes by the specified region slug (e.g., 'nyc1', 'fra1', 'sgp1').
    When provided, returns only volumes located in the specified region.

    .PARAMETER Page
    Specifies which page of paginated results to return. Must be between 1 and 1000.
    Used with the Limit parameter for pagination control.

    .PARAMETER Limit
    Specifies the number of volume objects returned per page. Must be between 20 and 200.
    Used with the Page parameter for pagination control.

    .PARAMETER All
    When specified, retrieves all available volumes from DigitalOcean API regardless of pagination.
    Cannot be used with Page or Limit parameters.

    .EXAMPLE
    Get-DigitalOceanVolume -Page 1 -Limit 25

    Retrieves the first 25 volumes from DigitalOcean, returning DigitalOceanVolume objects
    with volume details including size, region, and attachment status.

    .EXAMPLE
    Get-DigitalOceanVolume -All

    Retrieves all volumes from your DigitalOcean account, automatically handling pagination
    and returning complete DigitalOceanVolume objects for each volume.

    .EXAMPLE
    Get-DigitalOceanVolume -VolumeId "506f78a4-e098-11e5-ad9f-000f53306ae1"

    Retrieves the specific volume with the provided ID, returning a single DigitalOceanVolume
    object with complete volume information.

    .EXAMPLE
    Get-DigitalOceanVolume -VolumeName "my-data-volume"

    Retrieves volumes with the name "my-data-volume", returning DigitalOceanVolume objects
    for all matching volumes.

    .EXAMPLE
    Get-DigitalOceanVolume -Region "nyc1" -All

    Retrieves all volumes located in the NYC1 region, returning DigitalOceanVolume objects
    with complete volume information for volumes in that region.

    .EXAMPLE
    $volumes = Get-DigitalOceanVolume -All
    $volumes | Where-Object { $_.Status -eq 'available' } | Select-Object Name, SizeGigabytes, Region

    Retrieves all volumes and filters for available volumes, displaying their names,
    sizes, and regions in a formatted table.

    .INPUTS
    None. You cannot pipe objects to Get-DigitalOceanVolume.

    .OUTPUTS
    DigitalOceanVolume[]
    Returns an array of DigitalOceanVolume objects containing volume information.

    .NOTES
    - Requires a valid DigitalOcean API token configured via Add-DigitalOceanAPIToken
    - Volume objects include size, region, filesystem type, attachment status, and metadata
    - Uses DigitalOcean API v2 block storage volumes endpoint
    - Supports PowerShell 5.1 and later versions
    - Follows PowerShell best practices with proper error handling and parameter validation

    .LINK
    https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_list

    .LINK
    Add-DigitalOceanAPIToken
    #>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ById',
            HelpMessage = 'The unique identifier of the volume to retrieve'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$VolumeId,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByName',
            HelpMessage = 'The name of the volume to retrieve'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$VolumeName,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'List',
            HelpMessage = 'Filter volumes by region slug'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByName',
            HelpMessage = 'Filter volumes by region slug'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'All',
            HelpMessage = 'Filter volumes by region slug'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Region,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'List',
            HelpMessage = 'Page number for paginated results (1-1000)'
        )]
        [ValidateRange(1, 1000)]
        [int]$Page = 1,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'List',
            HelpMessage = 'Number of items per page (20-200)'
        )]
        [ValidateRange(20, 200)]
        [int]$Limit = 50,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'All',
            HelpMessage = 'Retrieve all volumes (ignores pagination)'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByName',
            HelpMessage = 'Retrieve all volumes with the specified name'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'List',
            HelpMessage = 'Retrieve all volumes in a region (ignores pagination)'
        )]
        [switch]$All
    )

    begin
    {
        Write-Verbose "Starting Get-DigitalOceanVolume function"

        # Initialize variables for collecting results
        $allVolumes = @()
        $currentPage = if ($Page)
        {
            $Page
        }
        else
        {
            1
        }
        $pageSize = if ($Limit)
        {
            $Limit
        }
        else
        {
            50
        }
    }

    process
    {
        try
        {
            do
            {
                # Build the API endpoint based on parameter set
                switch ($PSCmdlet.ParameterSetName)
                {
                    'ById'
                    {
                        $endpoint = "volumes/$([uri]::EscapeDataString($VolumeId))"
                        Write-Verbose "Retrieving volume by ID: $VolumeId"
                        break
                    }
                    'ByName'
                    {
                        $endpoint = "volumes"
                        $queryParams = @{
                            name = [uri]::EscapeDataString($VolumeName)
                        }
                        if ($Region)
                        {
                            $queryParams.region = [uri]::EscapeDataString($Region)
                        }
                        if (-not $All)
                        {
                            $queryParams.page = $currentPage
                            $queryParams.per_page = $pageSize
                        }

                        $queryString = ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
                        $endpoint = "volumes?$queryString"
                        Write-Verbose "Retrieving volumes by name: $VolumeName"
                        break
                    }
                    default # 'List' and 'All'
                    {
                        $endpoint = "volumes"
                        $queryParams = @{}

                        if ($Region)
                        {
                            $queryParams.region = [uri]::EscapeDataString($Region)
                        }

                        if (-not $All)
                        {
                            $queryParams.page = $currentPage
                            $queryParams.per_page = $pageSize
                        }

                        if ($queryParams.Count -gt 0)
                        {
                            $queryString = ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
                            $endpoint = "volumes?$queryString"
                        }

                        Write-Verbose "Retrieving volumes list (Page: $currentPage, Limit: $pageSize)"
                        break
                    }
                }

                # Make the API call
                Write-Verbose "Making API call to endpoint: $endpoint"
                $response = Invoke-DigitalOceanAPI -APIPath $endpoint -Method 'GET'

                if ($null -eq $response)
                {
                    Write-Warning "No response received from DigitalOcean API"
                    return
                }

                # Process the response based on endpoint type
                if ($PSCmdlet.ParameterSetName -eq 'ById')
                {
                    # Single volume response
                    if ($response.volume)
                    {
                        Write-Verbose "Successfully retrieved volume: $($response.volume.name)"
                        $volumeObject = [DigitalOceanVolume]::new($response.volume)
                        Write-Output $volumeObject
                    }
                    else
                    {
                        Write-Warning "Volume not found with ID: $VolumeId"
                    }
                    return
                }
                else
                {
                    # Multiple volumes response
                    if ($response.volumes -and $response.volumes.Count -gt 0)
                    {
                        Write-Verbose "Processing $($response.volumes.Count) volume(s) from API response"

                        $currentPageVolumes = @()
                        foreach ($volumeData in $response.volumes)
                        {
                            try
                            {
                                $volumeObject = [DigitalOceanVolume]::new($volumeData)
                                $currentPageVolumes += $volumeObject
                                Write-Verbose "Processed volume: $($volumeObject.Name) (ID: $($volumeObject.Id))"
                            }
                            catch
                            {
                                Write-Warning "Failed to process volume data: $($_.Exception.Message)"
                                continue
                            }
                        }

                        $allVolumes += $currentPageVolumes

                        # Handle pagination for 'All' parameter set
                        if ($All -and $response.links -and $response.links.pages -and $response.links.pages.next)
                        {
                            $currentPage++
                            Write-Verbose "Fetching next page: $currentPage"
                            continue
                        }
                        else
                        {
                            break
                        }
                    }
                    else
                    {
                        Write-Verbose "No volumes found in API response"
                        if ($currentPage -eq 1)
                        {
                            Write-Verbose "No volumes available"
                        }
                        break
                    }
                }
            } while ($All)

            # Return results
            if ($allVolumes.Count -gt 0)
            {
                Write-Verbose "Returning $($allVolumes.Count) volume(s)"
                Write-Output $allVolumes
            }
            else
            {
                Write-Verbose "No volumes found matching the specified criteria"
            }
        }
        catch
        {
            $errorMessage = "Failed to retrieve DigitalOcean volumes: $($_.Exception.Message)"
            Write-Error $errorMessage
            throw
        }
    }

    end
    {
        Write-Verbose "Completed Get-DigitalOceanVolume function"
    }
}
