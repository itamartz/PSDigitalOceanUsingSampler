---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/digitalocean/#tag/Sizes
schema: 2.0.0
---

# Get-DigitalOceanSize

## SYNOPSIS
Get-DigitalOceanSize.

## SYNTAX

### Limit (Default)
```
Get-DigitalOceanSize [-Page <Int32>] [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-DigitalOceanSize [-All] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves Digital Ocean Size(s) from the DigitalOcean API with support for pagination and filtering.

## EXAMPLES

### EXAMPLE 1
```
Get-DigitalOceanSize -Page 1 -Limit 21
```

### EXAMPLE 2
```
Get-DigitalOceanSize -All
```

## PARAMETERS

### -Page
Which 'page' of paginated results to return.

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
Number of items returned per page.

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
If you want to get all the sizes and not the Page / Limit.

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

### DigitalOceanSize
## NOTES

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/digitalocean/#tag/Sizes](https://docs.digitalocean.com/reference/api/digitalocean/#tag/Sizes)

