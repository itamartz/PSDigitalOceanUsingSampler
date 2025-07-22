# Get-DigitalOceanRegion

Retrieves available DigitalOcean regions with pagination support.

## Syntax

```powershell
Get-DigitalOceanRegion [[-Page] <int>] [[-Limit] <int>] [<CommonParameters>]

Get-DigitalOceanRegion [-All] [<CommonParameters>]
```

## Description

The `Get-DigitalOceanRegion` function retrieves information about available
DigitalOcean regions. It supports both paginated results and retrieving all
regions at once.

## Parameters

### -Page

Specifies the page number for pagination (1-1000).

- **Type**: Int32
- **Default**: 1
- **Range**: 1-1000

### -Limit

Specifies the number of regions per page (20-200).

- **Type**: Int32  
- **Default**: 20
- **Range**: 20-200

### -All

Retrieves all regions by automatically handling pagination.

- **Type**: SwitchParameter
- **Default**: False

## Examples

### Example 1: Get regions with default pagination

```powershell
Get-DigitalOceanRegion
```

Returns the first 20 regions.

### Example 2: Get specific page with custom limit

```powershell
Get-DigitalOceanRegion -Page 2 -Limit 50
```

Returns 50 regions from page 2.

### Example 3: Get all regions

```powershell
$regions = Get-DigitalOceanRegion -All
```

Retrieves all available regions.

### Example 4: Working with region objects

```powershell
$regions = Get-DigitalOceanRegion -All
foreach ($region in $regions) {
    Write-Host "Region: $($region.ToString())"
    Write-Host "Available: $($region.Available)"
    Write-Host "Features: $($region.Features -join ', ')"
    Write-Host "---"
}
```

## Output

Returns `DigitalOceanRegion` objects with the following properties:

- **Name**: Human-readable region name
- **Slug**: Region identifier (e.g., 'nyc1', 'sfo2')
- **Features**: Array of available features
- **Available**: Boolean indicating if region accepts new resources
- **Sizes**: Array of supported droplet sizes

## Notes

- Requires valid `DIGITALOCEAN_TOKEN` environment variable
- Uses DigitalOcean API v2
- Results are cached for performance
- Supports verbose output for debugging

## Related Links

- [Get-DigitalOceanAccount](Get-DigitalOceanAccount)
- [Get-DigitalOceanImage](Get-DigitalOceanImage)
- [DigitalOcean Regions API](https://docs.digitalocean.com/reference/api/api-reference/#operation/list_all_regions)
