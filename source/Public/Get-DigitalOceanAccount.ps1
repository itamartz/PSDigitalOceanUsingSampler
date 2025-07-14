function Get-DigitalOceanAccount
{
    <#
    .SYNOPSIS
    Get-DigitalOceanAccount

    .DESCRIPTION
    Retrieves Digital Ocean account information including account details, limits, and verification status. Supports pagination to retrieve multiple accounts or use the -All parameter to get all accounts at once.

    .PARAMETER Page
    Which 'page' of paginated results to return.

    .PARAMETER Limit
    Number of items returned per page.

    .PARAMETER All
    If you want to get all the images and not the Page / Limit.

    .EXAMPLE
    Get-DigitalOceanAccount -Page 1 -Limit 20

    .EXAMPLE
    Get-DigitalOceanAccount -All

    .LINK
    https://docs.digitalocean.com/reference/api/digitalocean/#tag/Account

    .OUTPUTS
    DigitalOcean.Account
  #>


    [CmdletBinding(DefaultParameterSetName = "Limit")]
    [OutputType('DigitalOcean.Account')]
    param
    (
        [int]
        [ValidateRange(1, 1000)]
        [Parameter(ParameterSetName = "Limit")]
        $Page = 1,

        [int]
        [ValidateRange(20, 200)]
        [Parameter(ParameterSetName = "Limit")]
        $Limit = 20,

        [Switch]
        [Parameter(ParameterSetName = "All")]
        $All
    )

    if ($All.IsPresent)
    {
        $Parameters = @{
            page     = 1
            per_page = 20
        }

        $AllArray = @()

        Write-Verbose "about to get all account from DigitalOcean"
        Write-Verbose "Page: 1, PerPage: 20"

        $response = Invoke-DigitalOceanAPI -APIPath account -Parameters $Parameters
        $Total = $response.meta.total
        Write-Verbose "DigitalOcean total account is $($Total)"

        $AllArray = $response.account

        do
        {
            # Check if there's a next page URL
            if ($response.links.pages.PSObject.Properties.Name -contains 'next' -and
                $null -ne $response.links.pages.next -and
                $response.links.pages.next -ne "")
            {
                $Split = $response.links.pages.next.Split('?')[1]
                if ($Split -match 'page=(\d+)&per_page=(\d+)')
                {
                    $Parameters = @{
                        page     = $matches[1]
                        per_page = $matches[2]
                    }
                    Write-Verbose "Page: $($matches[1]), PerPage: $($matches[2])"

                    Write-Verbose "the next url is $($response.links.pages.next)"
                    $response = Invoke-DigitalOceanAPI -APIPath account -Parameters $Parameters
                    $AllArray += $response.account
                }
                else
                {
                    # URL doesn't match pattern, break the loop
                    break
                }
            }
            else
            {
                # No next page, break the loop
                break
            }

        } while ($AllArray.Count -lt $Total)

        Write-Verbose "finished getting all sizes"

        # Convert API response objects to PowerShell class objects
        $ConvertedArray = @()
        foreach ($obj in $AllArray)
        {
            # Create Team object if team data exists
            $teamObject = $null
            if ($obj.team)
            {
                $teamObject = [Team]::new(
                    $(if ($null -ne $obj.team.uuid) { $obj.team.uuid } else { "" }),
                    $(if ($null -ne $obj.team.name) { $obj.team.name } else { "" })
                )
            }

            # Create Account object with all properties, providing defaults for missing values
            $accountObject = [Account]::new(
                $(if ($null -ne $obj.droplet_limit) { $obj.droplet_limit } else { 0 }),
                $(if ($null -ne $obj.floating_ip_limit) { $obj.floating_ip_limit } else { 0 }),
                $(if ($null -ne $obj.email) { $obj.email } else { "" }),
                $(if ($null -ne $obj.name) { $obj.name } else { "" }),
                $(if ($null -ne $obj.uuid) { $obj.uuid } else { "" }),
                $(if ($null -ne $obj.email_verified) { $obj.email_verified } else { $false }),
                $(if ($null -ne $obj.status) { $obj.status } else { "" }),
                $(if ($null -ne $obj.status_message) { $obj.status_message } else { "" }),
                $teamObject
            )

            $ConvertedArray += $accountObject
        }
        $ConvertedArray

    }
    else
    {
        $Parameters = @{
            page     = $Page
            per_page = $Limit
        }

        $AllArray = @()
        $response = Invoke-DigitalOceanAPI -APIPath account -Parameters $Parameters
        $AllArray = $response.account

        # Convert API response objects to PowerShell class objects
        $ConvertedArray = @()
        foreach ($obj in $AllArray)
        {
            # Create Team object if team data exists
            $teamObject = $null
            if ($obj.team)
            {
                $teamObject = [Team]::new(
                    $(if ($null -ne $obj.team.uuid) { $obj.team.uuid } else { "" }),
                    $(if ($null -ne $obj.team.name) { $obj.team.name } else { "" })
                )
            }

            # Create Account object with all properties, providing defaults for missing values
            $accountObject = [Account]::new(
                $(if ($null -ne $obj.droplet_limit) { $obj.droplet_limit } else { 0 }),
                $(if ($null -ne $obj.floating_ip_limit) { $obj.floating_ip_limit } else { 0 }),
                $(if ($null -ne $obj.email) { $obj.email } else { "" }),
                $(if ($null -ne $obj.name) { $obj.name } else { "" }),
                $(if ($null -ne $obj.uuid) { $obj.uuid } else { "" }),
                $(if ($null -ne $obj.email_verified) { $obj.email_verified } else { $false }),
                $(if ($null -ne $obj.status) { $obj.status } else { "" }),
                $(if ($null -ne $obj.status_message) { $obj.status_message } else { "" }),
                $teamObject
            )

            $ConvertedArray += $accountObject
        }
        $ConvertedArray
    }
}
