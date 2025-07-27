# Get-DigitalOceanSize

Retrieves DigitalOcean Droplet sizes with comprehensive filtering and pagination support.

## Syntax

```powershell
Get-DigitalOceanSize [-Page <Int32>] [-Limit <Int32>] [<CommonParameters>]

Get-DigitalOceanSize [-All] [<CommonParameters>]
```

## Description

The `Get-DigitalOceanSize` cmdlet retrieves information about available DigitalOcean Droplet sizes including specifications like memory, vCPUs, disk space, and pricing information. It supports pagination for efficient data retrieval and can return all sizes at once.

## Parameters

### -Page
The page number to retrieve (1-1000). Used for pagination when not using -All parameter.

```yaml
Type: Int32
Parameter Sets: Pagination
Aliases: 
Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
The number of items to retrieve per page (20-200). Used for pagination when not using -All parameter.

```yaml
Type: Int32
Parameter Sets: Pagination
Aliases: 
Required: False
Position: Named
Default value: 20
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Retrieve all available sizes without pagination.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases: 
Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## Inputs

None. You cannot pipe objects to `Get-DigitalOceanSize`.

## Outputs

### DigitalOceanSize
Returns strongly-typed DigitalOceanSize objects with the following properties:
- **Slug**: Unique identifier for the size
- **Memory**: RAM in MB
- **Vcpus**: Number of virtual CPUs
- **Disk**: Disk space in GB
- **Transfer**: Data transfer allowance
- **PriceMonthly**: Monthly price in USD
- **PriceHourly**: Hourly price in USD
- **Regions**: Array of available regions
- **Available**: Availability status

## Examples

### Example 1: Get first page of sizes
```powershell
Get-DigitalOceanSize
```

Retrieves the first page of DigitalOcean Droplet sizes (default: 20 items).

### Example 2: Get all sizes
```powershell
Get-DigitalOceanSize -All
```

Retrieves all available DigitalOcean Droplet sizes without pagination.

### Example 3: Get specific page with custom limit
```powershell
Get-DigitalOceanSize -Page 2 -Limit 50
```

Retrieves the second page with 50 sizes per page.

### Example 4: Filter sizes by memory
```powershell
Get-DigitalOceanSize -All | Where-Object { $_.Memory -ge 4096 }
```

Retrieves all sizes and filters for those with 4GB or more RAM.

### Example 5: Get sizes available in specific region
```powershell
Get-DigitalOceanSize -All | Where-Object { $_.Regions -contains "nyc1" }
```

Retrieves all sizes available in the NYC1 region.

## Notes

- Requires a valid DigitalOcean API token set in the `DIGITALOCEAN_TOKEN` environment variable
- Uses the DigitalOcean API v2 endpoint `/v2/sizes`
- Returns strongly-typed PowerShell objects for better integration
- Supports both paginated and bulk retrieval methods
- Regional availability information is included for deployment planning

## Related Links

- [Get-DigitalOceanAccount](Get-DigitalOceanAccount)
- [Get-DigitalOceanRegion](Get-DigitalOceanRegion)
- [Get-DigitalOceanImage](Get-DigitalOceanImage)
- [DigitalOcean API Documentation](https://docs.digitalocean.com/reference/api/api-reference/#operation/sizes_list)
