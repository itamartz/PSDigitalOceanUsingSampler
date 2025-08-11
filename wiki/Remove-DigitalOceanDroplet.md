# Remove-DigitalOceanDroplet

## Synopsis

Removes DigitalOcean droplets by ID or tag.

## Description

The `Remove-DigitalOceanDroplet` function provides a secure way to delete  
DigitalOcean droplets either individually by ID or in bulk using tags. The  
function includes comprehensive error handling, detailed API error parsing,  
and full ShouldProcess support for safe operations.

## Syntax

### ById (Default)

```powershell
Remove-DigitalOceanDroplet
    [-DropletId] <String>
    [-WhatIf]
    [-Confirm]
    [<CommonParameters>]
```

### ByTag

```powershell
Remove-DigitalOceanDroplet
    -Tag <String>
    [-WhatIf]
    [-Confirm]
    [<CommonParameters>]
```

## Parameters

### -DropletId

The ID of the droplet to delete.

- **Type**: String
- **Parameter Sets**: ById
- **Position**: 0
- **Default Value**: None
- **Accept Pipeline Input**: True
- **Accept Wildcard Characters**: False

### -Tag

The tag to use for bulk deletion of droplets.

- **Type**: String  
- **Parameter Sets**: ByTag
- **Position**: Named
- **Default Value**: None
- **Accept Pipeline Input**: False
- **Accept Wildcard Characters**: False

### -WhatIf

Shows what would happen if the cmdlet runs without actually performing the deletion.

### -Confirm

Prompts for confirmation before performing the deletion.

## Examples

### Example 1: Remove a droplet by ID

```powershell
Remove-DigitalOceanDroplet -DropletId "123456789"
```

Removes the droplet with ID "123456789".

### Example 2: Remove multiple droplets by tag

```powershell
Remove-DigitalOceanDroplet -Tag "test-environment"
```

Removes all droplets tagged with "test-environment".

### Example 3: Preview removal with WhatIf

```powershell
Remove-DigitalOceanDroplet -DropletId "123456789" -WhatIf
```

Shows what would happen without actually removing the droplet.

### Example 4: Remove with confirmation

```powershell
Remove-DigitalOceanDroplet -Tag "staging" -Confirm
```

Prompts for confirmation before removing all droplets tagged with "staging".

## Outputs

### System.Boolean

Returns `$true` if the deletion was successful, `$false` otherwise.

## Notes

- **API Token Required**: Ensure you have configured your DigitalOcean API  
  token using `Add-DigitalOceanAPIToken`
- **Irreversible Action**: Droplet deletion cannot be undone
- **Tag Operations**: When using tags, all droplets with that tag will be deleted
- **Error Handling**: Comprehensive error handling with detailed API error messages
- **URL Encoding**: Parameters are automatically URL-encoded for safe API transmission

## Related Links

- [DigitalOcean API - Delete Droplet](https://docs.digitalocean.com/reference/api/api-reference/#operation/destroy_droplet)
- [DigitalOcean API - Delete Droplets by Tag](https://docs.digitalocean.com/reference/api/api-reference/#operation/destroy_droplets_by_tag)
- [Add-DigitalOceanAPIToken](Add-DigitalOceanAPIToken)
- [Get-DigitalOceanDroplet](Get-DigitalOceanDroplet)
- [New-DigitalOceanDroplet](New-DigitalOceanDroplet)

---

**Last Updated**: August 11, 2025  
**Module Version**: 1.8.0
