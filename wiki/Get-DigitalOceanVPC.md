# Get-DigitalOceanVPC

## Synopsis

Retrieves Virtual Private Cloud (VPC) information from DigitalOcean.

## Syntax

```powershell
Get-DigitalOceanVPC
```

## Description

The `Get-DigitalOceanVPC` function retrieves information about Virtual Private Clouds (VPCs) from your DigitalOcean account. VPCs allow you to create isolated networks for your DigitalOcean resources within a specific region. This function returns detailed information about each VPC including network configuration and associated resources.

## Examples

### Example 1: Get all VPCs

```powershell
Get-DigitalOceanVPC
```

Retrieves all VPCs in your DigitalOcean account.

### Example 2: Filter VPCs by name

```powershell
Get-DigitalOceanVPC | Where-Object { $_.name -like "*production*" }
```

Retrieves all VPCs and filters for those containing "production" in the name.

### Example 3: Select specific VPC properties

```powershell
Get-DigitalOceanVPC | Select-Object name, ip_range, region
```

Retrieves all VPCs and displays only the name, IP range, and region information.

### Example 4: Count VPCs by region

```powershell
Get-DigitalOceanVPC | Group-Object -Property { $_.region.slug } | Select-Object Name, Count
```

Groups VPCs by region and shows the count in each region.

### Example 5: Export VPC information to CSV

```powershell
Get-DigitalOceanVPC | Export-Csv -Path "vpcs.csv" -NoTypeInformation
```

Exports all VPC information to a CSV file for further analysis.

## Parameters

This function does not take any parameters. It retrieves all VPCs available in your DigitalOcean account.

## Outputs

**System.Object[]**

Returns an array of VPC objects containing the following properties:

- **id**: Unique identifier for the VPC
- **name**: Name assigned to the VPC
- **ip_range**: IP address range for the VPC (CIDR notation)
- **region**: Region object containing the VPC's location details
- **created_at**: Timestamp when the VPC was created
- **default**: Boolean indicating if this is the default VPC for the region

## Notes

- Requires a valid DigitalOcean API token to be set in the `DIGITALOCEAN_TOKEN` environment variable
- VPCs are region-specific resources in DigitalOcean
- Each VPC includes network configuration details and associated resource information
- The function uses the DigitalOcean API v2 endpoint for VPCs
- Results are automatically paginated with a limit of 200 VPCs per API call

## Related Links

- [Get-DigitalOceanAccount](Get-DigitalOceanAccount.md) - Retrieve account information
- [Get-DigitalOceanRegion](Get-DigitalOceanRegion.md) - View available regions for VPCs
- [New-DigitalOceanDroplet](New-DigitalOceanDroplet.md) - Create droplets within VPCs
- [Add-DigitalOceanAPIToken](Add-DigitalOceanAPIToken.md) - Configure API access
- [DigitalOcean VPC API Documentation](https://docs.digitalocean.com/reference/api/api-reference/#operation/vpc_list)
