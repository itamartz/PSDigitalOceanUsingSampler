function Get-DigitalOceanSize
{
    <#
      .SYNOPSIS
      Get-DigitalOceanSize.

      .DESCRIPTION
      Retrieves Digital Ocean Size(s) from the DigitalOcean API with support for pagination and filtering.

      .PARAMETER Page
      Which 'page' of paginated results to return.

      .PARAMETER Limit
      Number of items returned per page.

      .PARAMETER All
      If you want to get all the sizes and not the Page / Limit.

      .EXAMPLE
      Get-DigitalOceanSize -Page 1 -Limit 21

      .EXAMPLE
      Get-DigitalOceanSize -All

      .LINK
      https://docs.digitalocean.com/reference/api/digitalocean/#tag/Sizes

      .OUTPUTS
      DigitalOceanSize
  #>

    [CmdletBinding(DefaultParameterSetName = "Limit")]
    [OutputType([DigitalOceanSize[]])]
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

        $AllSizes = @()

        Write-Verbose "about to get all sizes from DigitalOcean"
        Write-Verbose "Page: 1, PerPage: 20"

        $response = Invoke-DigitalOceanAPI -APIPath sizes -Parameters $Parameters

        if ($null -eq $response -or $null -eq $response.sizes)
        {
            throw "Invalid or null response from API"
        }

        $Total = $response.meta.total
        Write-Verbose "DigitalOcean total sizes is $($Total)"

        $AllSizes = $response.sizes

        do
        {
            if ($response.links.pages.next)
            {
                $Split = $response.links.pages.next.Split('?')[1]
                if ($Split -match 'page=(\d+)&per_page=(\d+)')
                {
                    $Parameters = @{
                        page     = $matches[1]
                        per_page = $matches[2]
                    }
                    Write-Verbose "Page: $($matches[1]), PerPage: $($matches[2])"

                    $response = Invoke-DigitalOceanAPI -APIPath sizes -Parameters $Parameters
                    $AllSizes += $response.sizes
                }
                else
                {
                    break
                }
            }
            else
            {
                break
            }
        } while ($response.links.pages.next -and $AllSizes.Count -lt $Total)

        Write-Verbose "finished getting all sizes"

        # Convert to DigitalOceanSize objects
        if ($AllSizes.Count -gt 0)
        {
            $digitalOceanSizes = @()
            foreach ($obj in $AllSizes)
            {
                $digitalOceanSizes += [DigitalOceanSize]::new($obj)
            }
            Write-Output $digitalOceanSizes
        }
        else
        {
            # Return empty array for empty response
            Write-Output @([DigitalOceanSize[]]@())
        }

    }
    else
    {
        $Parameters = @{
            page     = $Page
            per_page = $Limit
        }

        $response = Invoke-DigitalOceanAPI -APIPath sizes -Parameters $Parameters

        if ($null -eq $response -or $null -eq $response.sizes)
        {
            throw "Invalid or null response from API"
        }

        $AllSizes = $response.sizes

        # Convert to DigitalOceanSize objects
        if ($AllSizes.Count -gt 0)
        {
            $digitalOceanSizes = @()
            foreach ($obj in $AllSizes)
            {
                $digitalOceanSizes += [DigitalOceanSize]::new($obj)
            }
            Write-Output $digitalOceanSizes
        }
        else
        {
            # Return empty array for empty response
            Write-Output @([DigitalOceanSize[]]@())
        }
    }
}
