---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/digitalocean/#tag/Droplets
schema: 2.0.0
---

# New-DigitalOceanDroplet

## SYNOPSIS
New-DigitalOceanDroplet

## SYNTAX

```
New-DigitalOceanDroplet -DropletName <String> [-SSHKey <Object>] [-Backups <Boolean>] [-IPV6 <Boolean>]
 [-Monitoring <Boolean>] [-Tags <String[]>] [-UserData <String>] [-Volumes <String[]>] [-Region <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new DigitalOcean Droplet with the specified configuration.
This function allows you to create a virtual machine instance with custom settings including size, image, networking options, monitoring, backups, and additional storage volumes.

## EXAMPLES

### EXAMPLE 1
```
New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64"
```

### EXAMPLE 2
```
New-DigitalOceanDroplet -DropletName "web-server" -Size "s-2vcpu-2gb" -Image "ubuntu-20-04-x64" -Backups $true -Monitoring $true
```

## PARAMETERS

### -DropletName
The human-readable string you wish to use when displaying the Droplet name.
The name, if set to a domain name managed in the DigitalOcean DNS management system, will configure a PTR record for the Droplet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SSHKey
SSH key object to be added to the Droplet for authentication.
Must be a DigitalOcean.Account.SSHKeys object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Backups
A boolean indicating whether automated backups should be enabled for the Droplet.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPV6
A boolean indicating whether to enable IPv6 on the Droplet.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Monitoring
A boolean indicating whether to install the DigitalOcean agent for monitoring.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
A flat array of tag names as strings to apply to the Droplet after it is created.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserData
A string containing 'user data' which may be used to configure the Droplet on first boot, often a 'cloud-config' file or Bash script.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Volumes
An array of IDs for block storage volumes that will be attached to the Droplet once created.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
The slug identifier for the region where the resource will initially be available.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

### DigitalOcean.Droplet
### System.String
## NOTES

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/digitalocean/#tag/Droplets](https://docs.digitalocean.com/reference/api/digitalocean/#tag/Droplets)

