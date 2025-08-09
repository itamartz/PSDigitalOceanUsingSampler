---
external help file: PSDigitalOcean-help.xml
Module Name: PSDigitalOcean
online version: https://docs.digitalocean.com/products/volumes/
https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_create
Get-DigitalOceanVolume
Remove-DigitalOceanVolume
schema: 2.0.0
---

# New-DigitalOceanVolume

## SYNOPSIS
Creates a new DigitalOcean Block Storage volume.

## SYNTAX

### CreateNew (Default)
```
New-DigitalOceanVolume -Name <String> -SizeGigabytes <Int32> -Region <String> [-FilesystemType <String>]
 [-FilesystemLabel <String>] [-Description <String>] [-Tags <String[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### FromSnapshot
```
New-DigitalOceanVolume -Name <String> -Region <String> [-Description <String>] [-Tags <String[]>]
 -SnapshotId <String> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The New-DigitalOceanVolume function creates a new Block Storage volume in DigitalOcean.
Volumes provide additional storage that can be attached to Droplets and provide persistent
storage that survives Droplet destruction.
This function supports creating volumes with
custom names, sizes, regions, filesystem types, and labels.

## EXAMPLES

### EXAMPLE 1
```
New-DigitalOceanVolume -Name "my-volume" -SizeGigabytes 100 -Region "nyc1"
```

Creates a new 100GB volume named "my-volume" in the NYC1 region without formatting.

### EXAMPLE 2
```
New-DigitalOceanVolume -Name "database-storage" -SizeGigabytes 500 -Region "sfo2" -FilesystemType "ext4" -FilesystemLabel "dbdata"
```

Creates a new 500GB volume with ext4 filesystem and label "dbdata" in the SFO2 region.

### EXAMPLE 3
```
$tags = @("production", "database", "mysql")
New-DigitalOceanVolume -Name "prod-db-vol" -SizeGigabytes 1000 -Region "ams3" -Description "Production MySQL database storage" -Tags $tags
```

Creates a production database volume with tags and description.

### EXAMPLE 4
```
New-DigitalOceanVolume -Name "backup-restore" -Region "nyc1" -SnapshotId "3d80cb72-342b-4aaa-b92e-4e4abb24a933"
```

Creates a volume from an existing snapshot, inheriting the snapshot's size and data.

## PARAMETERS

### -Name
The name of the volume.
Must be unique within the region.
The name must be lowercase
and contain only letters, numbers, and hyphens.
Must be between 1-64 characters and
begin with a letter.

```yaml
Type: String
Parameter Sets: (All)
Aliases: VolumeName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SizeGigabytes
The size of the volume in gigabytes (GiB).
Must be between 1 and 16384 GB.
The volume size
cannot be decreased after creation, but can be increased later.

```yaml
Type: Int32
Parameter Sets: CreateNew
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
The DigitalOcean region where the volume will be created (e.g., 'nyc1', 'sfo2', 'ams3').
The volume must be created in the same region as the Droplet it will be attached to.

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

### -FilesystemType
The filesystem to format the volume with.
Valid options are 'ext4' and 'xfs'.
If not specified, the volume will be created without formatting.

```yaml
Type: String
Parameter Sets: CreateNew
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilesystemLabel
An optional label for the filesystem.
Only applicable when FilesystemType is specified.
Maximum 16 characters for ext4 filesystems or 12 characters for xfs filesystems.

```yaml
Type: String
Parameter Sets: CreateNew
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
An optional description for the volume to help identify its purpose or contents.

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

### -Tags
An array of tags to apply to the volume for organization and billing purposes.
Tags must be valid tag names (letters, numbers, hyphens, and underscores).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -SnapshotId
The ID of a volume snapshot to create the volume from.
When specified, the volume
will be created as a copy of the snapshot with the snapshot's data and size.

```yaml
Type: String
Parameter Sets: FromSnapshot
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs without actually executing the operation.

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
Prompts for confirmation before executing the volume creation operation.

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

### DigitalOceanVolume
### Returns a DigitalOceanVolume object representing the newly created volume.
## NOTES
- Requires a valid DigitalOcean API token to be set using Add-DigitalOceanAPIToken
- Volume names must be unique within the region
- Volumes can only be attached to Droplets in the same region
- Volume size cannot be decreased after creation
- Some regions may have different available filesystem types
- Volume creation may take a few moments to complete

## RELATED LINKS

[https://docs.digitalocean.com/products/volumes/
https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_create
Get-DigitalOceanVolume
Remove-DigitalOceanVolume](https://docs.digitalocean.com/products/volumes/
https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_create
Get-DigitalOceanVolume
Remove-DigitalOceanVolume)

[https://docs.digitalocean.com/products/volumes/
https://docs.digitalocean.com/reference/api/api-reference/#operation/volumes_create
Get-DigitalOceanVolume
Remove-DigitalOceanVolume]()

