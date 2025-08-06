function Get-DigitalOceanVPC
{
    <#
    .SYNOPSIS
        Retrieves Virtual Private Cloud (VPC) information from DigitalOcean.

    .DESCRIPTION
        The Get-DigitalOceanVPC function retrieves information about Virtual Private Clouds (VPCs) from your DigitalOcean account.
        VPCs allow you to create isolated networks for your DigitalOcean resources within a specific region.
        This function returns detailed information about each VPC including network configuration and associated resources.

    .EXAMPLE
        Get-DigitalOceanVPC

        Retrieves all VPCs in your DigitalOcean account.

    .EXAMPLE
        Get-DigitalOceanVPC | Where-Object { $_.name -like "*production*" }

        Retrieves all VPCs and filters for those containing "production" in the name.

    .EXAMPLE
        Get-DigitalOceanVPC | Select-Object name, ip_range, region

        Retrieves all VPCs and displays only the name, IP range, and region information.

    .OUTPUTS
        System.Object[]
        Returns an array of VPC objects containing information such as ID, name, IP range, region, and creation date.

    .NOTES
        - Requires a valid DigitalOcean API token to be set in the DIGITALOCEAN_TOKEN environment variable
        - VPCs are region-specific resources in DigitalOcean
        - Each VPC includes network configuration details and associated resource information

    .LINK
        https://docs.digitalocean.com/reference/api/api-reference/#operation/vpc_list

    .LINK
        Add-DigitalOceanAPIToken
    #>

    [CmdletBinding()]
    [OutputType('DigitalOcean.Account.VPCs')]
    param
    (
    )

    try
    {
        Write-Verbose "Retrieving VPCs from DigitalOcean account"

        $Parameters = @{
            per_page = 200
        }

        $response = Invoke-DigitalOceanAPI -APIPath "vpcs" -Parameters $Parameters

        if ($null -eq $response.vpcs)
        {
            Write-Warning "No VPCs found in your DigitalOcean account"
            return
        }

        Write-Verbose "Found $($response.vpcs.Count) VPCs"

        foreach ($vpc in $response.vpcs)
        {
            Write-Output $vpc
        }
    }
    catch
    {
        $errorMessage = $_.Exception.Message
        Write-Error "Failed to retrieve VPC information. Error: $errorMessage"
        throw
    }
}
