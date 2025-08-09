# New-DigitalOceanVolume

Creates a new DigitalOcean Block Storage volume with comprehensive  
configuration options.

## Syntax

```powershell
New-DigitalOceanVolume -Name <string> -Size <int> -Region <string> 
    [-Description <string>] [-FilesystemType <string>] 
    [-FilesystemLabel <string>] [-Tags <string[]>] [-WhatIf] [-Confirm] 
    [<CommonParameters>]
```

## Description

The `New-DigitalOceanVolume` function creates a new DigitalOcean Block Storage  
volume. Block Storage volumes are network-attached drives that can be attached  
to Droplets to provide additional storage capacity.

Key features:

- Create volumes from 1GB to 16TB in size
- Support for ext4 and xfs filesystem types
- Optional filesystem labels with validation
- Comprehensive parameter validation
- Built-in error handling and API retry logic

## Parameters

### -Name

Specifies the name for the new volume. Must be unique within the region.

- **Type**: String
- **Mandatory**: Yes
- **Position**: Named

### -Size

Specifies the size of the volume in gigabytes (GB). Must be between 1 and 16384 GB.

- **Type**: Int32
- **Mandatory**: Yes
- **Position**: Named
- **Validation**: Range 1-16384

### -Region

Specifies the region where the volume will be created (e.g., 'nyc1', 'sfo3').

- **Type**: String
- **Mandatory**: Yes
- **Position**: Named

### -Description

Optional description for the volume.

- **Type**: String
- **Mandatory**: No
- **Position**: Named

### -FilesystemType

Specifies the filesystem type to format the volume with. Supported values  
are 'ext4' and 'xfs'.

- **Type**: String
- **Mandatory**: No
- **Position**: Named
- **Valid Values**: 'ext4', 'xfs'

### -FilesystemLabel

Specifies a label for the filesystem. Requires FilesystemType to be specified.

- **Type**: String
- **Mandatory**: No
- **Position**: Named
- **Validation**: 
  - Maximum 16 characters for ext4
  - Maximum 12 characters for xfs

### -Tags

Specifies an array of tags to assign to the volume.

- **Type**: String[]
- **Mandatory**: No
- **Position**: Named

### -WhatIf

Shows what would happen if the cmdlet runs without actually creating the volume.

- **Type**: SwitchParameter
- **Mandatory**: No

### -Confirm

Prompts for confirmation before creating the volume.

- **Type**: SwitchParameter
- **Mandatory**: No

## Examples

### Example 1: Create a basic volume

```powershell
New-DigitalOceanVolume -Name "data-volume-01" -Size 100 -Region "nyc1"
```

Creates a 100GB volume named "data-volume-01" in the NYC1 region.

### Example 2: Create a volume with ext4 filesystem

```powershell
New-DigitalOceanVolume -Name "app-storage" -Size 250 -Region "sfo3" -FilesystemType "ext4" -FilesystemLabel "appdata"
```

Creates a 250GB volume with ext4 filesystem and custom label.

### Example 3: Create a volume with description and tags

```powershell
New-DigitalOceanVolume -Name "backup-volume" -Size 500 -Region "fra1" -Description "Weekly backup storage" -Tags @("backup", "production")
```

Creates a 500GB volume with description and tags for organization.

### Example 4: Create an XFS volume

```powershell
New-DigitalOceanVolume -Name "database-vol" -Size 1000 -Region "nyc3" -FilesystemType "xfs" -FilesystemLabel "dbstorage"
```

Creates a 1TB volume with XFS filesystem for database storage.

### Example 5: Preview volume creation

```powershell
New-DigitalOceanVolume -Name "test-volume" -Size 50 -Region "tor1" -WhatIf
```

Shows what would happen without actually creating the volume.

## Outputs

### DigitalOceanVolume

Returns a DigitalOceanVolume object containing:

```powershell
Id              : vol-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Name            : data-volume-01
Description     : 
SizeGigabytes   : 100
Region          : nyc1
Status          : available
FilesystemType  : ext4
FilesystemLabel : 
DropletIds      : {}
Tags            : {}
CreatedAt       : 2024-01-15T10:30:00Z
```

## Notes

### Volume Limits

- Minimum size: 1GB
- Maximum size: 16TB (16,384GB)
- Volumes are region-specific
- Volume names must be unique within a region

### Filesystem Labels

- **ext4**: Maximum 16 characters
- **xfs**: Maximum 12 characters
- Labels can only be used with a specified filesystem type

### Performance

- Volumes provide consistent baseline performance
- IOPS and throughput scale with volume size
- Volumes can be resized after creation (via web interface)

### Best Practices

1. Use descriptive names for easy identification
2. Add relevant tags for organization and billing
3. Consider filesystem type based on your use case:
   - **ext4**: General purpose, widely compatible
   - **xfs**: Better for large files and high-performance applications

## Related Commands

- [Get-DigitalOceanVolume](Get-DigitalOceanVolume.md) - Retrieve volume information
- [Get-DigitalOceanRegion](Get-DigitalOceanRegion.md) - List available regions

## Error Handling

The function includes comprehensive error handling for:

- Invalid volume names or sizes
- Unsupported regions
- API rate limiting
- Network connectivity issues
- Invalid filesystem label lengths

Common error scenarios:

```powershell
# Invalid size
New-DigitalOceanVolume -Name "test" -Size 0 -Region "nyc1"
# Error: Size must be between 1 and 16384 GB

# Invalid filesystem label
New-DigitalOceanVolume -Name "test" -Size 100 -Region "nyc1" -FilesystemType "xfs" -FilesystemLabel "this-label-is-too-long"
# Error: Filesystem label cannot exceed 12 characters for xfs filesystem
```

## Version History

- **v1.6.0**: Initial implementation with full parameter validation and error handling
