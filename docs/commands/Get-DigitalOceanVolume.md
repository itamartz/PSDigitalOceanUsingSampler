---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_list
schema: 2.0.0
---

# Get-DigitalOceanVolume

## SYNOPSIS
Retrieves DigitalOcean block storage volumes with filtering and pagination support.

## SYNTAX

### List (Default)
```
Get-DigitalOceanVolume [-Region <String>] [-Page <Int32>] [-Limit <Int32>] [-All]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById
```
Get-DigitalOceanVolume -VolumeId <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ByName
```
Get-DigitalOceanVolume -VolumeName <String> [-Region <String>] [-All] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### All
```
Get-DigitalOceanVolume [-Region <String>] [-All] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-DigitalOceanVolume retrieves block storage volumes from your DigitalOcean account.
Returns strongly-typed DigitalOceanVolume objects with comprehensive volume information including
size, region, attachment status, and filesystem details.
Supports filtering by region,
retrieving specific volumes by ID or name, and paginated results.

## EXAMPLES

### EXAMPLE 1
```
Get-DigitalOceanVolume -Page 1 -Limit 25
```

Retrieves the first 25 volumes from DigitalOcean, returning DigitalOceanVolume objects
with volume details including size, region, and attachment status.

### EXAMPLE 2
```
Get-DigitalOceanVolume -All
```

Retrieves all volumes from your DigitalOcean account, automatically handling pagination
and returning complete DigitalOceanVolume objects for each volume.

### EXAMPLE 3
```
Get-DigitalOceanVolume -VolumeId "506f78a4-e098-11e5-ad9f-000f53306ae1"
```

Retrieves the specific volume with the provided ID, returning a single DigitalOceanVolume
object with complete volume information.

### EXAMPLE 4
```
Get-DigitalOceanVolume -VolumeName "my-data-volume"
```

Retrieves volumes with the name "my-data-volume", returning DigitalOceanVolume objects
for all matching volumes.

### EXAMPLE 5
```
Get-DigitalOceanVolume -Region "nyc1" -All
```

Retrieves all volumes located in the NYC1 region, returning DigitalOceanVolume objects
with complete volume information for volumes in that region.

### EXAMPLE 6
```
$volumes = Get-DigitalOceanVolume -All
$volumes | Where-Object { $_.Status -eq 'available' } | Select-Object Name, SizeGigabytes, Region
```

Retrieves all volumes and filters for available volumes, displaying their names,
sizes, and regions in a formatted table.

## PARAMETERS

### -VolumeId
Specifies the unique identifier of a specific volume to retrieve.
When provided, returns only the volume with the matching ID.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VolumeName
Specifies the name of a specific volume to retrieve.
When provided, returns volumes with the matching name.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
Filters volumes by the specified region slug (e.g., 'nyc1', 'fra1', 'sgp1').
When provided, returns only volumes located in the specified region.

```yaml
Type: String
Parameter Sets: List, ByName, All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
Specifies which page of paginated results to return.
Must be between 1 and 1000.
Used with the Limit parameter for pagination control.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Specifies the number of volume objects returned per page.
Must be between 20 and 200.
Used with the Page parameter for pagination control.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
When specified, retrieves all available volumes from DigitalOcean API regardless of pagination.
Cannot be used with Page or Limit parameters.

```yaml
Type: SwitchParameter
Parameter Sets: List, ByName, All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-DigitalOceanVolume.
## OUTPUTS

### DigitalOceanVolume[]
### Returns an array of DigitalOceanVolume objects containing volume information.
## NOTES
- Requires a valid DigitalOcean API token configured via Add-DigitalOceanAPIToken
- Volume objects include size, region, filesystem type, attachment status, and metadata
- Uses DigitalOcean API v2 block storage volumes endpoint
- Supports PowerShell 5.1 and later versions
- Follows PowerShell best practices with proper error handling and parameter validation

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_list](https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_list)

[Add-DigitalOceanAPIToken]()

