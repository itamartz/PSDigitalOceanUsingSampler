---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/reference/api/digitalocean/#tag/SSH-Keys
schema: 2.0.0
---

# Get-DigitalOceanSSHKey

## SYNOPSIS
Retrieves SSH keys from your DigitalOcean account.

## SYNTAX

```
Get-DigitalOceanSSHKey [[-SSHKeyName] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-DigitalOceanSSHKey function retrieves SSH keys associated with your DigitalOcean account.
You can retrieve all SSH keys or filter by a specific SSH key name.
SSH keys are used to
securely access DigitalOcean Droplets without using passwords.

## EXAMPLES

### EXAMPLE 1
```
Get-DigitalOceanSSHKey
```

Retrieves all SSH keys from your DigitalOcean account.

### EXAMPLE 2
```
Get-DigitalOceanSSHKey -SSHKeyName "my-laptop-key"
```

Retrieves the SSH key named "my-laptop-key" from your DigitalOcean account.

### EXAMPLE 3
```
$sshKeys = Get-DigitalOceanSSHKey
$sshKeys | Where-Object { $_.name -like "*production*" }
```

Gets all SSH keys and filters for those containing "production" in the name.

### EXAMPLE 4
```
Get-DigitalOceanSSHKey | Select-Object name, fingerprint, public_key
```

Retrieves all SSH keys and displays only the name, fingerprint, and public key.

## PARAMETERS

### -SSHKeyName
Optional.
The name of a specific SSH key to retrieve.
If not provided, all SSH keys will be returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

### None. You cannot pipe objects to Get-DigitalOceanSSHKey.
## OUTPUTS

### DigitalOcean.Account.SSHKeys
### Returns SSH key objects with properties including name, fingerprint, public_key, and id.
## NOTES
- Requires a valid DigitalOcean API token to be configured
- SSH keys are essential for secure access to DigitalOcean Droplets
- The function returns detailed information about each SSH key including the public key content

## RELATED LINKS

[https://docs.digitalocean.com/reference/api/digitalocean/#tag/SSH-Keys](https://docs.digitalocean.com/reference/api/digitalocean/#tag/SSH-Keys)

[Add-DigitalOceanAPIToken]()

