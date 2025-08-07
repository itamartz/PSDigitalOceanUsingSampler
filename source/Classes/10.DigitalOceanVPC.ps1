class DigitalOceanVPC
{
    [string]$Id
    [string]$Name
    [string]$IpRange
    [hashtable]$Region
    [string]$Description
    [bool]$Default
    [datetime]$CreatedAt

    # Default constructor
    DigitalOceanVPC()
    {
        $this.Id = ''
        $this.Name = ''
        $this.IpRange = ''
        $this.Region = @{}
        $this.Description = ''
        $this.Default = $false
        $this.CreatedAt = [datetime]::MinValue
    }

    # Constructor with VPC object parameter
    DigitalOceanVPC([object]$VPCObject)
    {
        if ($null -eq $VPCObject)
        {
            # Use default constructor values
            $this.Id = ''
            $this.Name = ''
            $this.IpRange = ''
            $this.Region = @{}
            $this.Description = ''
            $this.Default = $false
            $this.CreatedAt = [datetime]::MinValue
            return
        }

        # Set VPC properties from the API response object
        $this.Id = if ($VPCObject.id) { [string]$VPCObject.id } else { '' }
        $this.Name = if ($VPCObject.name) { [string]$VPCObject.name } else { '' }
        $this.IpRange = if ($VPCObject.ip_range) { [string]$VPCObject.ip_range } else { '' }
        $this.Description = if ($VPCObject.description) { [string]$VPCObject.description } else { '' }
        $this.Default = if ($VPCObject.default) { [bool]$VPCObject.default } else { $false }

        # Handle region object
        if ($VPCObject.region)
        {
            $this.Region = @{
                name = if ($VPCObject.region.name) { [string]$VPCObject.region.name } else { '' }
                slug = if ($VPCObject.region.slug) { [string]$VPCObject.region.slug } else { '' }
                sizes = if ($VPCObject.region.sizes) { @([string[]]$VPCObject.region.sizes) } else { @() }
                features = if ($VPCObject.region.features) { @([string[]]$VPCObject.region.features) } else { @() }
                available = if ($VPCObject.region.available) { [bool]$VPCObject.region.available } else { $false }
            }
        }
        else
        {
            $this.Region = @{}
        }

        # Handle created_at timestamp
        if ($VPCObject.created_at)
        {
            try
            {
                $this.CreatedAt = [datetime]::Parse($VPCObject.created_at)
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
    }

    # Convert to hashtable for easier manipulation
    [hashtable] ToHashtable()
    {
        return @{
            Id = $this.Id
            Name = $this.Name
            IpRange = $this.IpRange
            Region = $this.Region
            Description = $this.Description
            Default = $this.Default
            CreatedAt = $this.CreatedAt
        }
    }

    # String representation
    [string] ToString()
    {
        return "$($this.Name) ($($this.IpRange))"
    }
}
