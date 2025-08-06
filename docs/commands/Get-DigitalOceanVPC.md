---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/api-reference/#operation/vpc_list
schema: 2.0.0
---

# Get-DigitalOceanVPC

## SYNOPSIS
Retrieves Virtual Private Cloud (VPC) information from DigitalOcean.

## SYNTAX

```
Get-DigitalOceanVPC [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-DigitalOceanVPC function retrieves information about Virtual Private Clouds (VPCs) from your DigitalOcean account.
VPCs allow you to create isolated networks for your DigitalOcean resources within a specific region.
This function returns detailed information about each VPC including network configuration and associated resources.

## EXAMPLES

### EXAMPLE 1
```
Get-DigitalOceanVPC
```

Retrieves all VPCs in your DigitalOcean account.

### EXAMPLE 2
```
Get-DigitalOceanVPC | Where-Object { $_.name -like "*production*" }
```

Retrieves all VPCs and filters for those containing "production" in the name.

### EXAMPLE 3
```
Get-DigitalOceanVPC | Select-Object name, ip_range, region
```

Retrieves all VPCs and displays only the name, IP range, and region information.

## PARAMETERS

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

### System.Object[]
### Returns an array of VPC objects containing information such as ID, name, IP range, region, and creation date.
## NOTES
- Requires a valid DigitalOcean API token to be set in the DIGITALOCEAN_TOKEN environment variable
- VPCs are region-specific resources in DigitalOcean
- Each VPC includes network configuration details and associated resource information

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/api-reference/#operation/vpc_list](https://docs.digitalocean.com/reference/api/api-reference/#operation/vpc_list)

[Add-DigitalOceanAPIToken]()

