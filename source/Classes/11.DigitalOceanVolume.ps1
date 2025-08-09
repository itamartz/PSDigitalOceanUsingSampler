class DigitalOceanVolume
{
    # Core volume properties
    [string]$Id
    [string]$Name
    [string]$Description
    [int]$SizeGigabytes
    [string]$Region
    [string]$FilesystemType
    [string]$FilesystemLabel

    # Status and timestamps
    [string]$Status
    [datetime]$CreatedAt

    # Attachment information
    [string[]]$DropletIds
    [string[]]$Tags

    # Default constructor
    DigitalOceanVolume()
    {
        $this.Id = ''
        $this.Name = ''
        $this.Description = ''
        $this.SizeGigabytes = 0
        $this.Region = ''
        $this.FilesystemType = ''
        $this.FilesystemLabel = ''
        $this.Status = ''
        $this.CreatedAt = [datetime]::MinValue
        $this.DropletIds = [string[]]@()
        $this.Tags = [string[]]@()
    }

    # Constructor for API response
    DigitalOceanVolume([PSCustomObject]$ApiResponse)
    {
        if ($null -eq $ApiResponse)
        {
            # Initialize with default values when API response is null
            $this.Id = ''
            $this.Name = ''
            $this.Description = ''
            $this.SizeGigabytes = 0
            $this.Region = ''
            $this.FilesystemType = ''
            $this.FilesystemLabel = ''
            $this.Status = ''
            $this.CreatedAt = [datetime]::MinValue
            $this.DropletIds = [string[]]@()
            $this.Tags = [string[]]@()
            return
        }

        # Core properties
        $this.Id = if ($ApiResponse.id)
        {
            $ApiResponse.id
        }
        else
        {
            ''
        }
        $this.Name = if ($ApiResponse.name)
        {
            $ApiResponse.name
        }
        else
        {
            ''
        }
        $this.Description = if ($ApiResponse.description)
        {
            $ApiResponse.description
        }
        else
        {
            ''
        }
        $this.SizeGigabytes = if ($ApiResponse.size_gigabytes)
        {
            [int]$ApiResponse.size_gigabytes
        }
        else
        {
            0
        }
        $this.Region = if ($ApiResponse.region -is [string])
        {
            $ApiResponse.region
        }
        else
        {
            if ($ApiResponse.region.slug)
            {
                $ApiResponse.region.slug
            }
            else
            {
                ''
            }
        }
        $this.FilesystemType = if ($ApiResponse.filesystem_type)
        {
            $ApiResponse.filesystem_type
        }
        else
        {
            ''
        }
        $this.FilesystemLabel = if ($ApiResponse.filesystem_label)
        {
            $ApiResponse.filesystem_label
        }
        else
        {
            ''
        }

        # Status and timestamps
        $this.Status = if ($ApiResponse.status)
        {
            $ApiResponse.status
        }
        else
        {
            ''
        }
        if ($ApiResponse.created_at)
        {
            try
            {
                $this.CreatedAt = [datetime]::Parse($ApiResponse.created_at)
            }
            catch
            {
                $this.CreatedAt = [datetime]::MinValue
            }
        }
        else
        {
            $this.CreatedAt = [datetime]::MinValue
        }

        # Attachment information - handle both array and null cases
        if ($ApiResponse.droplet_ids -and $ApiResponse.droplet_ids.Count -gt 0)
        {
            $this.DropletIds = @($ApiResponse.droplet_ids | ForEach-Object { [string]$_ })
        }
        else
        {
            $this.DropletIds = @()
        }

        # Tags - handle both array and null cases
        if ($ApiResponse.tags -and $ApiResponse.tags.Count -gt 0)
        {
            $this.Tags = @($ApiResponse.tags | ForEach-Object {
                    if ($_ -is [hashtable])
                    {
                        return if ($_.name) { [string]$_.name } else { [string]$_ }
                    }
                    elseif ($_ -is [string])
                    {
                        return $_
                    }
                    else
                    {
                        return [string]$_
                    }
                })
        }
        else
        {
            $this.Tags = @()
        }
    }

    # Method to convert to hashtable for API requests
    [hashtable] ToHashtable()
    {
        return @{
            Id              = $this.Id
            Name            = $this.Name
            Description     = $this.Description
            SizeGigabytes   = $this.SizeGigabytes
            Region          = $this.Region
            FilesystemType  = $this.FilesystemType
            FilesystemLabel = $this.FilesystemLabel
            Status          = $this.Status
            CreatedAt       = $this.CreatedAt.ToString('yyyy-MM-ddTHH:mm:ssZ')
            DropletIds      = $this.DropletIds
            Tags            = $this.Tags
        }
    }

    # String representation
    [string] ToString()
    {
        return "$($this.Name) ($($this.Id)) - $($this.SizeGigabytes)GB in $($this.Region)"
    }
}
