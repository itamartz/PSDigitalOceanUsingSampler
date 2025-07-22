---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/digitalocean/#tag/Account
schema: 2.0.0
---

# Get-DigitalOceanAccount

## SYNOPSIS
Get-DigitalOceanAccount

## SYNTAX

### Limit (Default)
```
Get-DigitalOceanAccount [-Page <Int32>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### All
```
Get-DigitalOceanAccount [-All] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves Digital Ocean account information including account details, limits, and verification status.
Supports pagination to retrieve multiple accounts or use the -All parameter to get all accounts at once.

## EXAMPLES

### EXAMPLE 1
```
Get-DigitalOceanAccount -Page 1 -Limit 20
```

### EXAMPLE 2
```
Get-DigitalOceanAccount -All
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

### DigitalOcean.Account
## NOTES

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/digitalocean/#tag/Account](https://docs.digitalocean.com/reference/api/digitalocean/#tag/Account)

