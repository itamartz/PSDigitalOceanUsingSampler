function Get-DigitalOceanRegion
{
    <#
    .SYNOPSIS
    Retrieves DigitalOcean regions with filtering and pagination support.

    .DESCRIPTION
    Get-DigitalOceanRegion retrieves available DigitalOcean regions where resources can be deployed.
    Returns strongly-typed DigitalOceanRegion objects with comprehensive region information including
    available features, sizes, and availability status. Supports both paginated results and
    retrieving all regions at once.

    .PARAMETER Page
    Specifies which page of paginated results to return. Must be between 1 and 1000.
    Used with the Limit parameter for pagination control.

    .PARAMETER Limit
    Specifies the number of region objects returned per page. Must be between 20 and 200.
    Used with the Page parameter for pagination control.

    .PARAMETER All
    When specified, retrieves all available regions from DigitalOcean API regardless of pagination.
    Cannot be used with Page or Limit parameters.

    .EXAMPLE
    Get-DigitalOceanRegion -Page 1 -Limit 25

    Retrieves the first 25 regions from DigitalOcean, returning DigitalOceanRegion objects
    with name, slug, features, availability status, and supported sizes.

    .EXAMPLE
    Get-DigitalOceanRegion -All

    Retrieves all available regions from DigitalOcean API, automatically handling pagination
    to return complete results as DigitalOceanRegion objects.

    .EXAMPLE
    $regions = Get-DigitalOceanRegion -All | Where-Object { $_.Available -eq $true }
    $regions | Select-Object Name, Slug, Features

    Gets all available regions, filters for active ones, and displays key properties
    using the strongly-typed DigitalOceanRegion objects.

    .LINK
    https://docs.digitalocean.com/reference/api/digitalocean/#tag/Regions

    .OUTPUTS
    DigitalOceanRegion
    Returns strongly-typed DigitalOceanRegion objects with properties:
    - Name: Human-readable region name
    - Slug: Region identifier for API calls
    - Features: Array of available features in the region
    - Available: Boolean indicating if region accepts new resources
    - Sizes: Array of droplet sizes available in the region
    #>


    [CmdletBinding(DefaultParameterSetName = "Limit")]
    [OutputType([DigitalOceanRegion])]
    param
    (
        [Parameter(ParameterSetName = "Limit")]
        [ValidateRange(1, 1000)]
        [int]
        $Page = 1,

        [Parameter(ParameterSetName = "Limit")]
        [ValidateRange(20, 200)]
        [int]
        $Limit = 20,

        [Parameter(ParameterSetName = "All")]
        [Switch]
        $All
    )

    if ($All.IsPresent)
    {
        $Parameters = @{
            page     = 1
            per_page = 20
        }

        $AllRegions = @()

        Write-Verbose "Retrieving all regions from DigitalOcean API"
        Write-Verbose "Starting with Page: 1, PerPage: 20"

        $response = Invoke-DigitalOceanAPI -APIPath regions -Parameters $Parameters

        if (-not $response -or -not $response.regions)
        {
            Write-Warning "No regions data received from DigitalOcean API"
            return
        }

        $Total = $response.meta.total
        Write-Verbose "DigitalOcean reports total of $Total regions available"

        # Convert API response to DigitalOceanRegion objects
        foreach ($regionData in $response.regions)
        {
            $AllRegions += [DigitalOceanRegion]::new($regionData)
        }

        # Handle pagination for remaining regions
        while ($response.links.pages.next -and $AllRegions.Count -lt $Total)
        {
            $Split = $response.links.pages.next.Split('?')[1]
            if ($Split -match 'page=(\d+)&per_page=(\d+)')
            {
                $Parameters = @{
                    page     = $matches[1]
                    per_page = $matches[2]
                }
                Write-Verbose "Fetching Page: $($matches[1]), PerPage: $($matches[2])"

                $response = Invoke-DigitalOceanAPI -APIPath regions -Parameters $Parameters

                if ($response -and $response.regions)
                {
                    foreach ($regionData in $response.regions)
                    {
                        $AllRegions += [DigitalOceanRegion]::new($regionData)
                    }
                }
            }
            else
            {
                break
            }
        }

        Write-Verbose "Successfully retrieved $($AllRegions.Count) regions"
        Write-Output $AllRegions

    }
    else
    {
        $Parameters = @{
            page     = $Page
            per_page = $Limit
        }

        Write-Verbose "Retrieving regions - Page: $Page, Limit: $Limit"
        $response = Invoke-DigitalOceanAPI -APIPath regions -Parameters $Parameters

        if (-not $response -or -not $response.regions)
        {
            Write-Warning "No regions data received from DigitalOcean API"
            return
        }

        $RegionObjects = @()
        foreach ($regionData in $response.regions)
        {
            $RegionObjects += [DigitalOceanRegion]::new($regionData)
        }

        Write-Verbose "Retrieved $($RegionObjects.Count) regions for page $Page"
        Write-Output $RegionObjects
    }
}
