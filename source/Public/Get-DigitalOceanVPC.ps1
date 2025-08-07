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
        Get-DigitalOceanVPC | Where-Object { $_.Name -like "*production*" }

        Retrieves all VPCs and filters for those containing "production" in the name.

    .EXAMPLE
        Get-DigitalOceanVPC | Select-Object Name, IpRange, Region

        Retrieves all VPCs and displays only the name, IP range, and region information.

    .OUTPUTS
        DigitalOceanVPC
        Returns an array of DigitalOceanVPC objects containing information such as ID, name, IP range, region, and creation date.

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
    [OutputType([DigitalOceanVPC])]
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
            Write-Output @([DigitalOceanVPC[]]@())
            return
        }

        Write-Verbose "Found $($response.vpcs.Count) VPCs"

        # Convert to DigitalOceanVPC class objects
        $vpcObjects = foreach ($vpc in $response.vpcs)
        {
            [DigitalOceanVPC]::new($vpc)
        }

        Write-Output $vpcObjects
    }
    catch
    {
        $errorMessage = $_.Exception.Message
        Write-Error "Failed to retrieve VPC information. Error: $errorMessage"
        throw
    }
}
