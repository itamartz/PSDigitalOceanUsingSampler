# Remove-DigitalOceanVolume

## Synopsis
Removes a Block Storage volume from DigitalOcean.

## Description
The Remove-DigitalOceanVolume function removes a Block Storage volume from DigitalOcean. Volumes can be deleted by their unique ID or by their name and region combination. This function supports both deletion methods and includes comprehensive error handling with detailed API error parsing.

## Syntax

### ById (Default)
```powershell
Remove-DigitalOceanVolume -VolumeId <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByName
```powershell
Remove-DigitalOceanVolume -Name <String> -Region <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Parameters

### -VolumeId
The unique identifier of the volume to remove.

| Parameter | Value |
|-----------|-------|
| Type | String |
| Position | Named |
| Default value | None |
| Accept pipeline input | False |
| Accept wildcard characters | False |
| Mandatory | True (in ById parameter set) |
| Aliases | Id |

### -Name
The name of the volume to remove (must be used with -Region).

| Parameter | Value |
|-----------|-------|
| Type | String |
| Position | Named |
| Default value | None |
| Accept pipeline input | False |
| Accept wildcard characters | False |
| Mandatory | True (in ByName parameter set) |
| Aliases | VolumeName |

### -Region
The region where the volume is located (must be used with -Name).

| Parameter | Value |
|-----------|-------|
| Type | String |
| Position | Named |
| Default value | None |
| Accept pipeline input | False |
| Accept wildcard characters | False |
| Mandatory | True (in ByName parameter set) |

### -Force
Bypasses the confirmation prompt. Use with caution as this operation is irreversible.

| Parameter | Value |
|-----------|-------|
| Type | SwitchParameter |
| Position | Named |
| Default value | False |
| Accept pipeline input | False |
| Accept wildcard characters | False |
| Mandatory | False |

### -WhatIf
Shows what would happen if the function runs without actually executing the operation.

### -Confirm
Prompts for confirmation before executing the operation.

## Examples

### Example 1: Remove volume by ID
```powershell
Remove-DigitalOceanVolume -VolumeId "3d80cb72-342b-4aaa-b92e-4e4abb24a933"
```
Removes the volume with the specified ID after prompting for confirmation.

### Example 2: Remove volume by name and region
```powershell
Remove-DigitalOceanVolume -Name "my-volume" -Region "nyc1" -Force
```
Removes the volume named "my-volume" in the NYC1 region without prompting for confirmation.

### Example 3: Test removal with WhatIf
```powershell
Remove-DigitalOceanVolume -VolumeId "3d80cb72-342b-4aaa-b92e-4e4abb24a933" -WhatIf
```
Shows what would happen if the volume with the specified ID were to be removed.

### Example 4: Remove volume using splatting
```powershell
$volumeParams = @{
    Name = "production-data"
    Region = "nyc3"
    Force = $true
}
Remove-DigitalOceanVolume @volumeParams
```
Removes the volume using splatting for better readability with multiple parameters.

## Outputs

### System.Boolean
Returns `$true` if the volume was successfully removed, `$false` if the operation was cancelled or the volume was not found.

## Notes

- **Destructive Operation**: This function permanently deletes volumes. Ensure you have backups if needed.
- **Prerequisites**: Requires a valid DigitalOcean API token configured with `Add-DigitalOceanAPIToken`.
- **ShouldProcess Support**: Supports `-WhatIf` and `-Confirm` parameters for safe operation.
- **Error Handling**: Provides detailed error messages including API response parsing.
- **Volume State**: Volumes must be detached from droplets before deletion.

## Security Considerations

- The function has a **High** confirm impact level, requiring explicit confirmation by default
- Use the `-Force` parameter only when you're certain about the deletion
- Always verify the volume ID or name/region combination before execution
- Consider using `-WhatIf` first to preview the operation

## Error Handling

The function handles various error scenarios:

- **401 Unauthorized**: Invalid or expired API token
- **404 Not Found**: Volume does not exist
- **422 Unprocessable Entity**: Volume is still attached to a droplet
- **Network Errors**: Connection issues with DigitalOcean API

For attached volumes, the function provides clear error messages indicating the volume must be detached first.

## Related Functions

- `Get-DigitalOceanVolume` - Retrieve volume information
- `New-DigitalOceanVolume` - Create new volumes
- `Add-DigitalOceanAPIToken` - Configure API authentication

## Version History

- **v1.7.0** (2025-08-10): Initial release with comprehensive volume deletion support

---

*Last updated: August 10, 2025*
