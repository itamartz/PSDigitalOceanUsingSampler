---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version:
schema: 2.0.0
---

# Add-DigitalOceanAPIToken

## SYNOPSIS
Adds a DigitalOcean API token to the user environment.

## SYNTAX

```
Add-DigitalOceanAPIToken [-Token] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function securely stores a DigitalOcean API token in the user's environment variables.
The token is required for authenticating with the DigitalOcean API and should have appropriate permissions for the operations you plan to perform.

## EXAMPLES

### EXAMPLE 1
```
Add-DigitalOceanAPIToken -Token "dop_v1_53f12345678901234567890abcdef"
```

This example adds the specified DigitalOcean API token to the user environment.

### EXAMPLE 2
```
"dop_v1_53f12345678901234567890abcdef" | Add-DigitalOceanAPIToken
```

This example demonstrates using pipeline input to add the API token to the user environment.

## PARAMETERS

### -Token
The DigitalOcean API token to store in the environment.
This should be a valid API token with appropriate permissions for your intended operations.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

## NOTES

## RELATED LINKS
