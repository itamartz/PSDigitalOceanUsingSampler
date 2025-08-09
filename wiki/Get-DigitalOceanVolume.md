# Get-DigitalOceanVolume

Retrieves DigitalOcean volume information with support for ID, name, and region-based filtering.

## Syntax

```powershell
Get-DigitalOceanVolume -VolumeId <string> [<CommonParameters>]

Get-DigitalOceanVolume -VolumeName <string> [-Region <string>] [-All] [<CommonParameters>]

Get-DigitalOceanVolume [[-Page] <int>] [[-Limit] <int>] [-Region <string>] [<CommonParameters>]

Get-DigitalOceanVolume [-All] [-Region <string>] [<CommonParameters>]
```

## Description

The `Get-DigitalOceanVolume` function retrieves information about DigitalOcean volumes. It supports multiple parameter sets for different use cases:

- **ById**: Retrieve a specific volume by its ID
- **ByName**: Retrieve volumes by name with optional region filtering
- **List**: List volumes with pagination support
- **All**: Retrieve all volumes with automatic pagination

## Parameters

### -VolumeId

Specifies the unique identifier of the volume to retrieve.

- **Type**: String
- **Parameter Set**: ById
- **Mandatory**: Yes
- **Position**: Named

### -VolumeName

Specifies the name of the volume(s) to retrieve.

- **Type**: String
- **Parameter Set**: ByName
- **Mandatory**: Yes
- **Position**: Named

### -Region

Filters volumes by region. Can be used with ByName, List, or All parameter sets.

- **Type**: String
- **Parameter Set**: ByName, List, All
- **Mandatory**: No
- **Position**: Named

### -Page

Specifies the page number for pagination (1-1000).

- **Type**: Int32
- **Parameter Set**: List
- **Default**: 1
- **Range**: 1-1000

### -Limit

Specifies the number of items per page (1-200).

- **Type**: Int32
- **Parameter Set**: List
- **Default**: 50
- **Range**: 1-200

### -All

Retrieves all volumes by automatically handling pagination.

- **Type**: SwitchParameter
- **Parameter Set**: ByName, All
- **Default**: False

## Examples

### Example 1: Get volume by ID

```powershell
Get-DigitalOceanVolume -VolumeId "506f78a4-e098-11e5-ad9f-000f53306ae1"
```

This command retrieves a specific volume using its unique identifier.

### Example 2: Get volumes by name

```powershell
Get-DigitalOceanVolume -VolumeName "my-volume"
```

This command retrieves all volumes with the name "my-volume".

### Example 3: Get volumes by name in a specific region

```powershell
Get-DigitalOceanVolume -VolumeName "database-volume" -Region "nyc1"
```

This command retrieves volumes named "database-volume" in the New York 1 region.

### Example 4: List volumes with pagination

```powershell
Get-DigitalOceanVolume -Page 1 -Limit 20
```

This command lists the first 20 volumes using pagination.

### Example 5: Get volumes in a specific region

```powershell
Get-DigitalOceanVolume -Region "fra1"
```

This command lists all volumes in the Frankfurt 1 region.

### Example 6: Get all volumes

```powershell
Get-DigitalOceanVolume -All
```

This command retrieves all volumes by automatically handling pagination.

### Example 7: Get all volumes by name

```powershell
Get-DigitalOceanVolume -VolumeName "backup-volume" -All
```

This command retrieves all volumes named "backup-volume" across all regions.

## Outputs

### DigitalOceanVolume

Returns DigitalOceanVolume objects with the following properties:

- **Id**: Unique identifier of the volume
- **Name**: Name of the volume
- **Description**: Description of the volume
- **SizeGigabytes**: Size of the volume in gigabytes
- **Region**: Region where the volume is located
- **FilesystemType**: Type of filesystem (e.g., ext4, xfs)
- **FilesystemLabel**: Label of the filesystem
- **DropletIds**: Array of Droplet IDs attached to the volume
- **CreatedAt**: Creation timestamp
- **Status**: Current status of the volume
- **Tags**: Array of tags associated with the volume

## Notes

- Requires a valid DigitalOcean API token set via `Add-DigitalOceanAPIToken`
- All parameters support URL encoding for special characters
- The function uses different API endpoints depending on the parameter set:
  - ById: `/volumes/{id}`
  - ByName/List/All: `/volumes` with query parameters
- Regional filtering can significantly reduce response time and data transfer
- The All parameter automatically handles pagination for large result sets

## Related Links

- [Add-DigitalOceanAPIToken](Add-DigitalOceanAPIToken.md)
- [DigitalOcean Block Storage API Documentation](https://docs.digitalocean.com/reference/api/api-reference/#tag/Block-Storage)
