---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/digitalocean/#tag/Images/operation/images_list
schema: 2.0.0
---

# Get-DigitalOceanImage

## SYNOPSIS
Get-DigitalOceanImage.

## SYNTAX

### Limit (Default)
```
Get-DigitalOceanImage [-Type <String>] [-Page <Int32>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### All
```
Get-DigitalOceanImage [-All] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves Digital Ocean Image(s) from the DigitalOcean API with support for pagination and filtering.

## EXAMPLES

### EXAMPLE 1
```
Get-DigitalOceanImage -Type application -Page 1 -Limit 21
```

### EXAMPLE 2
```
Get-DigitalOceanImage -Type distribution -Page 1 -Limit 21
```

### EXAMPLE 3
```
Get-DigitalOceanImage -All
```

## PARAMETERS

### -Type
The type of the image, it can be 'application', 'distribution'
If no value supply you get all images.

```yaml
Type: String
Parameter Sets: Limit
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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
If you want to get all the images and not the Page / Limit.

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

### DigitalOceanImage
## NOTES

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/digitalocean/#tag/Images/operation/images_list](https://docs.digitalocean.com/reference/api/digitalocean/#tag/Images/operation/images_list)

