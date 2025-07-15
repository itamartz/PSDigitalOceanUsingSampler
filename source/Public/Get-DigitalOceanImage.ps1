function Get-DigitalOceanImage
{
    <#
      .SYNOPSIS
      Get-DigitalOceanImage.

      .DESCRIPTION
      Retrieves Digital Ocean Image(s) from the DigitalOcean API with support for pagination and filtering.

      .PARAMETER Type
      The type of the image, it can be 'application', 'distribution'
      If no value supply you get all images.

      .PARAMETER Page
      Which 'page' of paginated results to return.

      .PARAMETER Limit
      Number of items returned per page.

      .PARAMETER All
      If you want to get all the images and not the Page / Limit.

      .EXAMPLE
      Get-DigitalOceanImage -Type application -Page 1 -Limit 21

      .EXAMPLE
      Get-DigitalOceanImage -Type distribution -Page 1 -Limit 21

      .EXAMPLE
      Get-DigitalOceanImage -All

      .LINK
      https://docs.digitalocean.com/reference/api/digitalocean/#tag/Images/operation/images_list

      .OUTPUTS
      DigitalOceanImage
  #>

    [CmdletBinding(DefaultParameterSetName = "Limit")]
    [OutputType([DigitalOceanImage[]])]
    param
    (
        [Parameter(ParameterSetName = "Limit")]
        [ValidateSet('application', 'distribution', '')]
        [String]
        $Type,

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

        $AllImages = @()

        Write-Verbose "about to get all images from DigitalOcean"
        Write-Verbose "Page: 1, PerPage: 20"

        $response = Invoke-DigitalOceanAPI -APIPath images -Parameters $Parameters

        if ($null -eq $response -or $null -eq $response.images)
        {
            throw "Invalid or null response from API"
        }

        $Total = $response.meta.total
        Write-Verbose "DigitalOcean total images is $($Total)"

        $AllImages = $response.images

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

                    $response = Invoke-DigitalOceanAPI -APIPath images -Parameters $Parameters
                    $AllImages += $response.images
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
        } while ($response.links.pages.next -and $AllImages.Count -lt $Total)

        Write-Verbose "finished getting all images"

        # Convert to DigitalOceanImage objects
        if ($AllImages.Count -gt 0)
        {
            $digitalOceanImages = @()
            foreach ($obj in $AllImages)
            {
                $digitalOceanImages += [DigitalOceanImage]::new($obj)
            }
            Write-Output $digitalOceanImages
        }
        else
        {
            # Return empty array for empty response
            Write-Output @([DigitalOceanImage[]]@())
        }

    }
    else
    {
        $Parameters = @{
            page     = $Page
            per_page = $Limit
        }

        if (-not [string]::IsNullOrEmpty($Type))
        {
            $Parameters.Add('type', $Type)
        }

        $response = Invoke-DigitalOceanAPI -APIPath images -Parameters $Parameters

        if ($null -eq $response -or $null -eq $response.images)
        {
            throw "Invalid or null response from API"
        }

        $AllImages = $response.images

        # Convert to DigitalOceanImage objects
        if ($AllImages.Count -gt 0)
        {
            $digitalOceanImages = @()
            foreach ($obj in $AllImages)
            {
                $digitalOceanImages += [DigitalOceanImage]::new($obj)
            }
            Write-Output $digitalOceanImages
        }
        else
        {
            # Return empty array for empty response
            Write-Output @([DigitalOceanImage[]]@())
        }
    }
}
