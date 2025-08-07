class DigitalOceanDroplet
{
    [int]$Id
    [string]$Name
    [int]$Memory
    [int]$Vcpus
    [int]$Disk
    [bool]$Locked
    [string]$Status
    [datetime]$CreatedAt
    [string[]]$Features
    [hashtable]$Region
    [hashtable]$Image
    [hashtable]$Size
    [hashtable]$Networks
    [int[]]$BackupIds
    [int[]]$SnapshotIds
    [string[]]$NextBackupWindow
    [string[]]$Tags
    [string[]]$VolumeIds
    [string]$VpcUuid

    # Default constructor
    DigitalOceanDroplet()
    {
        $this.Id = 0
        $this.Name = ''
        $this.Memory = 0
        $this.Vcpus = 0
        $this.Disk = 0
        $this.Locked = $false
        $this.Status = ''
        $this.CreatedAt = [datetime]::MinValue
        $this.Features = [string[]]@()
        $this.Region = @{}
        $this.Image = @{}
        $this.Size = @{}
        $this.Networks = @{}
        $this.BackupIds = [int[]]@()
        $this.SnapshotIds = [int[]]@()
        $this.NextBackupWindow = [string[]]@()
        $this.Tags = [string[]]@()
        $this.VolumeIds = [string[]]@()
        $this.VpcUuid = ''
    }

    # Constructor with PSCustomObject parameter
    DigitalOceanDroplet([PSCustomObject]$DropletObject)
    {
        $this.Id = if ($DropletObject.id)
        {
            [int]$DropletObject.id
        }
        else
        {
            0
        }

        $this.Name = if ($DropletObject.name)
        {
            [string]$DropletObject.name
        }
        else
        {
            ''
        }

        $this.Memory = if ($DropletObject.memory)
        {
            [int]$DropletObject.memory
        }
        else
        {
            0
        }

        $this.Vcpus = if ($DropletObject.vcpus)
        {
            [int]$DropletObject.vcpus
        }
        else
        {
            0
        }

        $this.Disk = if ($DropletObject.disk)
        {
            [int]$DropletObject.disk
        }
        else
        {
            0
        }

        $this.Locked = if ($null -ne $DropletObject.locked)
        {
            [bool]$DropletObject.locked
        }
        else
        {
            $false
        }

        $this.Status = if ($DropletObject.status)
        {
            [string]$DropletObject.status
        }
        else
        {
            ''
        }

        $this.CreatedAt = if ($DropletObject.created_at)
        {
            try
            {
                [datetime]$DropletObject.created_at
            }
            catch
            {
                [datetime]::MinValue
            }
        }
        else
        {
            [datetime]::MinValue
        }

        $this.Features = if ($DropletObject.features)
        {
            @([string[]]$DropletObject.features)
        }
        else
        {
            @()
        }

        $this.Region = if ($DropletObject.region)
        {
            if ($DropletObject.region -is [hashtable])
            {
                $DropletObject.region
            }
            else
            {
                @{
                    name = if ($DropletObject.region.name) { [string]$DropletObject.region.name } else { '' }
                    slug = if ($DropletObject.region.slug) { [string]$DropletObject.region.slug } else { '' }
                }
            }
        }
        else
        {
            @{}
        }

        $this.Image = if ($DropletObject.image)
        {
            if ($DropletObject.image -is [hashtable])
            {
                $DropletObject.image
            }
            else
            {
                @{
                    id           = if ($DropletObject.image.id) { [int]$DropletObject.image.id } else { 0 }
                    name         = if ($DropletObject.image.name) { [string]$DropletObject.image.name } else { '' }
                    slug         = if ($DropletObject.image.slug) { [string]$DropletObject.image.slug } else { '' }
                    distribution = if ($DropletObject.image.distribution) { [string]$DropletObject.image.distribution } else { '' }
                }
            }
        }
        else
        {
            @{}
        }

        $this.Size = if ($DropletObject.size)
        {
            if ($DropletObject.size -is [hashtable])
            {
                $DropletObject.size
            }
            else
            {
                @{
                    slug          = if ($DropletObject.size.slug) { [string]$DropletObject.size.slug } else { '' }
                    memory        = if ($DropletObject.size.memory) { [int]$DropletObject.size.memory } else { 0 }
                    vcpus         = if ($DropletObject.size.vcpus) { [int]$DropletObject.size.vcpus } else { 0 }
                    disk          = if ($DropletObject.size.disk) { [int]$DropletObject.size.disk } else { 0 }
                    price_monthly = if ($DropletObject.size.price_monthly) { [decimal]$DropletObject.size.price_monthly } else { 0 }
                    price_hourly  = if ($DropletObject.size.price_hourly) { [decimal]$DropletObject.size.price_hourly } else { 0 }
                }
            }
        }
        else
        {
            @{}
        }

        $this.Networks = if ($DropletObject.networks)
        {
            if ($DropletObject.networks -is [hashtable])
            {
                $DropletObject.networks
            }
            else
            {
                @{
                    v4 = if ($DropletObject.networks.v4) { $DropletObject.networks.v4 } else { @() }
                    v6 = if ($DropletObject.networks.v6) { $DropletObject.networks.v6 } else { @() }
                }
            }
        }
        else
        {
            @{}
        }

        $this.BackupIds = if ($DropletObject.backup_ids)
        {
            @([int[]]$DropletObject.backup_ids)
        }
        else
        {
            @()
        }

        $this.SnapshotIds = if ($DropletObject.snapshot_ids)
        {
            @([int[]]$DropletObject.snapshot_ids)
        }
        else
        {
            @()
        }

        $this.NextBackupWindow = if ($DropletObject.next_backup_window)
        {
            @([string[]]$DropletObject.next_backup_window)
        }
        else
        {
            @()
        }

        $this.Tags = if ($DropletObject.tags)
        {
            @([string[]]$DropletObject.tags)
        }
        else
        {
            @()
        }

        $this.VolumeIds = if ($DropletObject.volume_ids)
        {
            @([string[]]$DropletObject.volume_ids)
        }
        else
        {
            @()
        }

        $this.VpcUuid = if ($DropletObject.vpc_uuid)
        {
            [string]$DropletObject.vpc_uuid
        }
        else
        {
            ''
        }
    }

    # ToString method
    [string] ToString()
    {
        return "$($this.Name) (ID: $($this.Id))"
    }

    # ToHashtable method
    [hashtable] ToHashtable()
    {
        return @{
            Id                = $this.Id
            Name              = $this.Name
            Memory            = $this.Memory
            Vcpus             = $this.Vcpus
            Disk              = $this.Disk
            Locked            = $this.Locked
            Status            = $this.Status
            CreatedAt         = $this.CreatedAt
            Features          = $this.Features
            Region            = $this.Region
            Image             = $this.Image
            Size              = $this.Size
            Networks          = $this.Networks
            BackupIds         = $this.BackupIds
            SnapshotIds       = $this.SnapshotIds
            NextBackupWindow  = $this.NextBackupWindow
            Tags              = $this.Tags
            VolumeIds         = $this.VolumeIds
            VpcUuid           = $this.VpcUuid
        }
    }
}
