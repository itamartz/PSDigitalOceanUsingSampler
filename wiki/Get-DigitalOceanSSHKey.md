# Get-DigitalOceanSSHKey

Retrieves SSH keys from your DigitalOcean account with filtering support.

## Syntax

```powershell
Get-DigitalOceanSSHKey [[-SSHKeyName] <string>] [<CommonParameters>]
```

## Description

The `Get-DigitalOceanSSHKey` function retrieves SSH keys associated with your 
DigitalOcean account. You can retrieve all SSH keys or filter by a specific 
SSH key name. SSH keys are used to securely access DigitalOcean Droplets 
without using passwords.

## Parameters

### -SSHKeyName

Optional. The name of a specific SSH key to retrieve. If not provided, all SSH keys will be returned.

- **Type**: String
- **Default**: None (returns all SSH keys)
- **Required**: False
- **Pipeline Input**: False

## Examples

### Example 1: Get all SSH keys

```powershell
Get-DigitalOceanSSHKey
```

This command retrieves all SSH keys from your DigitalOcean account.

### Example 2: Get a specific SSH key by name

```powershell
Get-DigitalOceanSSHKey -SSHKeyName "my-laptop-key"
```

This command retrieves the SSH key named "my-laptop-key" from your DigitalOcean account.

### Example 3: Filter SSH keys containing "production"

```powershell
$sshKeys = Get-DigitalOceanSSHKey
$sshKeys | Where-Object { $_.name -like "*production*" }
```

This command gets all SSH keys and filters for those containing "production" in the name.

### Example 4: Display SSH key details

```powershell
Get-DigitalOceanSSHKey | Select-Object name, fingerprint, public_key
```

This command retrieves all SSH keys and displays only the name, fingerprint, and public key.

### Example 5: Use SSH key with New-DigitalOceanDroplet

```powershell
$sshKey = Get-DigitalOceanSSHKey -SSHKeyName "my-key"
New-DigitalOceanDroplet -DropletName "web-server" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -SSHKey $sshKey
```

This command retrieves a specific SSH key and uses it when creating a new Droplet.

## Outputs

### DigitalOcean.Account.SSHKeys

Returns SSH key objects with the following properties:

- **id**: The unique identifier for the SSH key
- **name**: The name of the SSH key
- **fingerprint**: The SSH key fingerprint
- **public_key**: The full public key content

## Notes

- Requires a valid DigitalOcean API token to be configured using `Add-DigitalOceanAPIToken`
- SSH keys are essential for secure access to DigitalOcean Droplets
- The function returns detailed information about each SSH key including the public key content
- If a specific SSH key name is not found, a warning message will be displayed
- The function uses a per_page limit of 200 to efficiently retrieve SSH keys

## Related Links

- [Add-DigitalOceanAPIToken](Add-DigitalOceanAPIToken.md)
- [New-DigitalOceanDroplet](New-DigitalOceanDroplet.md)
- [DigitalOcean SSH Keys API Documentation](https://docs.digitalocean.com/reference/api/digitalocean/#tag/SSH-Keys)

## See Also

- [Configuration](Configuration.md)
- [Quick Start Guide](Quick-Start.md)
- [Installation Guide](Installation-Guide.md)
