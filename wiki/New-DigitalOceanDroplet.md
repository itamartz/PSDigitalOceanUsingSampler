# New-DigitalOceanDroplet

Creates a new DigitalOcean Droplet with the specified configuration.

## Syntax

```powershell
New-DigitalOceanDroplet [-DropletName] <string> [-Size] <string> [-Image] <string> 
    [-SSHKey <Object>] [-Backups <bool>] [-IPV6 <bool>] [-Monitoring <bool>] 
    [-Tags <string[]>] [-UserData <string>] [-WhatIf] [-Confirm] [<CommonParameters>]

New-DigitalOceanDroplet [-DropletName] <string> [-Size] <string> [-Image] <string> 
    [-SSHKey <Object>] [-Backups <bool>] [-IPV6 <bool>] [-Monitoring <bool>] 
    [-Tags <string[]>] [-UserData <string>] [-Volumes <string[]>] [-Region <string>] 
    [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Description

The `New-DigitalOceanDroplet` function creates a new virtual machine instance (Droplet) in DigitalOcean with customizable settings including size, image, networking options, monitoring, backups, and additional storage volumes. This function supports PowerShell's `ShouldProcess` functionality for safe operations with `-WhatIf` and `-Confirm` parameters.

The function uses dynamic parameters for `Size` and `Image` that are populated from the available options in your DigitalOcean account, ensuring you can only select valid configurations.

## Parameters

### -DropletName

The human-readable string you wish to use when displaying the Droplet name. If set to a domain name managed in the DigitalOcean DNS management system, it will configure a PTR record for the Droplet. The name set during creation will also determine the hostname for the Droplet in its internal configuration.

- **Type**: String
- **Required**: True
- **Position**: Named
- **Validation**: Must match pattern `^[a-zA-Z0-9]?[a-z0-9A-Z.\-]*[a-z0-9A-Z]$`

### -Size

The slug identifier for the size that you wish to select for this Droplet. This is a dynamic parameter populated from available sizes in your DigitalOcean account.

- **Type**: String
- **Required**: True
- **Position**: Named
- **Dynamic**: Yes (populated from Get-DigitalOceanSize)

### -Image

The slug identifier for a public image. This image will be the base image for your Droplet. This is a dynamic parameter populated from available images in your DigitalOcean account.

- **Type**: String
- **Required**: True
- **Position**: Named
- **Dynamic**: Yes (populated from Get-DigitalOceanImage)

### -SSHKey

SSH key object to be added to the Droplet for authentication. Must be a `DigitalOcean.Account.SSHKeys` object obtained from DigitalOcean API.

- **Type**: Object
- **Required**: False
- **Position**: Named
- **Validation**: Must be of type `DigitalOcean.Account.SSHKeys`

### -Backups

A boolean indicating whether automated backups should be enabled for the Droplet.

- **Type**: Boolean
- **Required**: False
- **Position**: Named
- **Default**: False

### -IPV6

A boolean indicating whether to enable IPv6 on the Droplet.

- **Type**: Boolean
- **Required**: False
- **Position**: Named
- **Default**: False

### -Monitoring

A boolean indicating whether to install the DigitalOcean agent for monitoring.

- **Type**: Boolean
- **Required**: False
- **Position**: Named
- **Default**: False

### -Tags

A flat array of tag names as strings to apply to the Droplet after it is created. Tag names can either be existing or new tags.

- **Type**: String[]
- **Required**: False
- **Position**: Named

### -UserData

A string containing 'user data' which may be used to configure the Droplet on first boot, often a 'cloud-config' file or Bash script. It must be plain text and may not exceed 64 KiB in size.

- **Type**: String
- **Required**: False
- **Position**: Named

### -Volumes

An array of IDs for block storage volumes that will be attached to the Droplet once created. The volumes must not already be attached to an existing Droplet. This parameter is part of the "Volume" parameter set.

- **Type**: String[]
- **Required**: False
- **Position**: Named
- **Parameter Set**: Volume

### -Region

The slug identifier for the region where the resource will initially be available. This parameter is part of the "Volume" parameter set and is used when attaching volumes.

- **Type**: String
- **Required**: False
- **Position**: Named
- **Parameter Set**: Volume

## Examples

### Example 1: Create a basic Droplet

```powershell
New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64"
```

Creates a basic Ubuntu 20.04 Droplet with 1GB RAM and 1 vCPU.

### Example 2: Create a Droplet with backups and monitoring

```powershell
$dropletParams = @{
    DropletName = "web-server"
    Size        = "s-2vcpu-2gb"
    Image       = "ubuntu-20-04-x64"
    Backups     = $true
    Monitoring  = $true
}
New-DigitalOceanDroplet @dropletParams
```

Creates a Droplet with automated backups and monitoring enabled.

### Example 3: Create a Droplet with SSH key authentication

```powershell
$sshKey = Get-DigitalOceanSSHKey | Where-Object { $_.name -eq "my-key" }
$dropletParams = @{
    DropletName = "secure-server"
    Size        = "s-1vcpu-1gb"
    Image       = "ubuntu-20-04-x64"
    SSHKey      = $sshKey
}
New-DigitalOceanDroplet @dropletParams
```

Creates a Droplet with SSH key authentication configured.

### Example 4: Create a Droplet with user data script

```powershell
$userData = @"
#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
"@

$dropletParams = @{
    DropletName = "web-server"
    Size        = "s-1vcpu-1gb"
    Image       = "ubuntu-20-04-x64"
    UserData    = $userData
}
New-DigitalOceanDroplet @dropletParams
```

Creates a Droplet with a user data script that installs and starts nginx.

### Example 5: Create a Droplet with tags

```powershell
$dropletParams = @{
    DropletName = "api-server"
    Size        = "s-2vcpu-4gb"
    Image       = "ubuntu-20-04-x64"
    Tags        = @("production", "api", "backend")
}
New-DigitalOceanDroplet @dropletParams
```

Creates a Droplet with multiple tags for organization and management.

### Example 6: Create a Droplet with all features enabled

```powershell
$sshKey = Get-DigitalOceanSSHKey | Where-Object { $_.name -eq "production-key" }
$userData = "#!/bin/bash`necho 'Production server setup' >> /var/log/setup.log"

$dropletParams = @{
    DropletName = "prod-web-01"
    Size        = "s-4vcpu-8gb"
    Image       = "ubuntu-20-04-x64"
    SSHKey      = $sshKey
    Backups     = $true
    IPV6        = $true
    Monitoring  = $true
    Tags        = @("production", "web", "load-balanced")
    UserData    = $userData
}
New-DigitalOceanDroplet @dropletParams
```

Creates a production-ready Droplet with all available features enabled.

### Example 7: Use -WhatIf to preview the operation

```powershell
$dropletParams = @{
    DropletName = "test-server"
    Size        = "s-1vcpu-1gb"
    Image       = "ubuntu-20-04-x64"
    WhatIf      = $true
}
New-DigitalOceanDroplet @dropletParams
```

Shows what would happen when creating the Droplet without actually creating it.

## Outputs

### DigitalOcean.Droplet

Returns a Droplet object with the following properties when successful:

- **id**: Unique identifier for the Droplet
- **name**: The name of the Droplet
- **memory**: Amount of RAM in MB
- **vcpus**: Number of virtual CPUs
- **disk**: Disk size in GB
- **status**: Current status of the Droplet
- **region**: Region information
- **image**: Image information
- **size**: Size configuration
- **created_at**: Creation timestamp

### System.String

Returns error messages as strings when the operation fails.

## Notes

- This function requires a valid DigitalOcean API token to be configured
- The `Size` and `Image` parameters are dynamic and populated from your DigitalOcean account
- Droplet names must follow the validation pattern for DNS compatibility
- User data scripts must not exceed 64 KiB in size
- SSH keys must be properly configured in your DigitalOcean account before use
- The function supports PowerShell's `ShouldProcess` for safe operations

## Related Links

- [DigitalOcean Droplets API Documentation](https://docs.digitalocean.com/reference/api/digitalocean/#tag/Droplets)
- [Get-DigitalOceanSize](Get-DigitalOceanSize)
- [Get-DigitalOceanImage](Get-DigitalOceanImage)
- [Get-DigitalOceanAccount](Get-DigitalOceanAccount)

## Error Handling

The function includes comprehensive error handling for common scenarios:

- **401 Unauthorized**: Invalid or missing API token
- **403 Forbidden**: Insufficient permissions
- **422 Unprocessable Entity**: Invalid parameters or configuration
- **429 Too Many Requests**: Rate limiting exceeded
- **Network Errors**: Connection timeouts or network failures

All errors are returned as descriptive strings rather than thrown exceptions for better integration with PowerShell workflows.
