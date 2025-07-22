---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/digitalocean/#tag/Regions
schema: 2.0.0
---

# Get-DigitalOceanRegion

## SYNOPSIS
Retrieves DigitalOcean regions with filtering and pagination support.

## SYNTAX

### Limit (Default)
```
Get-DigitalOceanRegion [-Page <Int32>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### All
```
Get-DigitalOceanRegion [-All] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-DigitalOceanRegion retrieves available DigitalOcean regions where resources can be deployed.
Returns strongly-typed DigitalOceanRegion objects with comprehensive region information including
available features, sizes, and availability status.
Supports both paginated results and
retrieving all regions at once.

## EXAMPLES

### EXAMPLE 1
```
Get-DigitalOceanRegion -Page 1 -Limit 25
```

Retrieves the first 25 regions from DigitalOcean, returning DigitalOceanRegion objects
with name, slug, features, availability status, and supported sizes.

### EXAMPLE 2
```
Get-DigitalOceanRegion -All
```

Retrieves all available regions from DigitalOcean API, automatically handling pagination
to return complete results as DigitalOceanRegion objects.

### EXAMPLE 3
```
$regions = Get-DigitalOceanRegion -All | Where-Object { $_.Available -eq $true }
$regions | Select-Object Name, Slug, Features
```

Gets all available regions, filters for active ones, and displays key properties
using the strongly-typed DigitalOceanRegion objects.

## PARAMETERS

### -Page
Specifies which page of paginated results to return.
Must be between 1 and 1000.
Used with the Limit parameter for pagination control.

```yaml
Type: Int32
Parameter Sets: Limit
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Specifies the number of region objects returned per page.
Must be between 20 and 200.
Used with the Page parameter for pagination control.

```yaml
Type: Int32
Parameter Sets: Limit
Aliases:

Required: False
Position: Named
Default value: 20
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
When specified, retrieves all available regions from DigitalOcean API regardless of pagination.
Cannot be used with Page or Limit parameters.

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

## OUTPUTS

### DigitalOceanRegion
### Returns strongly-typed DigitalOceanRegion objects with properties:
### - Name: Human-readable region name
### - Slug: Region identifier for API calls
### - Features: Array of available features in the region
### - Available: Boolean indicating if region accepts new resources
### - Sizes: Array of droplet sizes available in the region
## NOTES

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/digitalocean/#tag/Regions](https://docs.digitalocean.com/reference/api/digitalocean/#tag/Regions)

