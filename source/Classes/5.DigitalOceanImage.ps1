class DigitalOceanImage
{
    [int] $Id
    [string] $Name
    [string] $Type
    [string] $Distribution
    [string] $Slug
    [bool] $Public
    [string[]] $Regions
    [datetime] $CreatedAt
    [string] $Status
    [string] $ErrorMessage
    [int] $SizeGigabytes
    [int] $MinDiskSize
    [string] $Description
    [hashtable] $Tags

    # Default constructor
    DigitalOceanImage()
    {
        $this.Id = 0
        $this.Name = ''
        $this.Type = ''
        $this.Distribution = ''
        $this.Slug = ''
        $this.Public = $false
        $this.Regions = @()
        $this.CreatedAt = [datetime]::MinValue
        $this.Status = ''
        $this.ErrorMessage = ''
        $this.SizeGigabytes = 0
        $this.MinDiskSize = 0
        $this.Description = ''
        $this.Tags = @{}
    }

    # Constructor with parameters
    DigitalOceanImage([PSCustomObject] $ImageObject)
    {
        $this.Id = if ($ImageObject.id)
        {
            [int]$ImageObject.id
        }
        else
        {
            0
        }
        $this.Name = if ($ImageObject.name)
        {
            [string]$ImageObject.name
        }
        else
        {
            ''
        }
        $this.Type = if ($ImageObject.type)
        {
            [string]$ImageObject.type
        }
        else
        {
            ''
        }
        $this.Distribution = if ($ImageObject.distribution)
        {
            [string]$ImageObject.distribution
        }
        else
        {
            ''
        }
        $this.Slug = if ($ImageObject.slug)
        {
            [string]$ImageObject.slug
        }
        else
        {
            ''
        }
        $this.Public = if ($null -ne $ImageObject.public)
        {
            [bool]$ImageObject.public
        }
        else
        {
            $false
        }
        # Handle regions - ensure it's always a string array
        if ($ImageObject.regions)
        {
            # Force array type by creating new array and adding items
            $this.Regions = @()
            if ($ImageObject.regions -is [array])
            {
                $this.Regions = $ImageObject.regions | ForEach-Object { [string]$_ }
            }
            else
            {
                $this.Regions = @([string]$ImageObject.regions)
            }
        }
        else
        {
            $this.Regions = @()
        }

        # Handle datetime conversion
        if ($ImageObject.created_at)
        {
            try
            {
                $this.CreatedAt = [datetime]::Parse($ImageObject.created_at)
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

        $this.Status = if ($ImageObject.status)
        {
            [string]$ImageObject.status
        }
        else
        {
            ''
        }
        $this.ErrorMessage = if ($ImageObject.error_message)
        {
            [string]$ImageObject.error_message
        }
        else
        {
            ''
        }
        $this.SizeGigabytes = if ($ImageObject.size_gigabytes)
        {
            [int]$ImageObject.size_gigabytes
        }
        else
        {
            0
        }
        $this.MinDiskSize = if ($ImageObject.min_disk_size)
        {
            [int]$ImageObject.min_disk_size
        }
        else
        {
            0
        }
        $this.Description = if ($ImageObject.description)
        {
            [string]$ImageObject.description
        }
        else
        {
            ''
        }
        $this.Tags = if ($ImageObject.tags)
        {
            [hashtable]$ImageObject.tags
        }
        else
        {
            @{}
        }
    }

    # Method to convert to hashtable
    [hashtable] ToHashtable()
    {
        return @{
            Id            = $this.Id
            Name          = $this.Name
            Type          = $this.Type
            Distribution  = $this.Distribution
            Slug          = $this.Slug
            Public        = $this.Public
            Regions       = $this.Regions
            CreatedAt     = $this.CreatedAt
            Status        = $this.Status
            ErrorMessage  = $this.ErrorMessage
            SizeGigabytes = $this.SizeGigabytes
            MinDiskSize   = $this.MinDiskSize
            Description   = $this.Description
            Tags          = $this.Tags
        }
    }

    # Method to convert to string representation
    [string] ToString()
    {
        return "DigitalOceanImage: $($this.Name) (ID: $($this.Id), Type: $($this.Type))"
    }
}
