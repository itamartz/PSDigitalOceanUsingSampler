class DigitalOceanSize
{
    [string]$Slug
    [int]$Memory
    [int]$Vcpus
    [int]$Disk
    [int]$Transfer
    [decimal]$PriceMonthly
    [decimal]$PriceHourly
    [string[]]$Regions
    [bool]$Available
    [string]$Description

    DigitalOceanSize()
    {
    }

    DigitalOceanSize([PSCustomObject]$InputObject)
    {
        $this.Slug = if ($InputObject.slug)
        {
            [string]$InputObject.slug 
        }
        else
        {
            '' 
        }
        $this.Memory = if ($InputObject.memory)
        {
            [int]$InputObject.memory 
        }
        else
        {
            0 
        }
        $this.Vcpus = if ($InputObject.vcpus)
        {
            [int]$InputObject.vcpus 
        }
        else
        {
            0 
        }
        $this.Disk = if ($InputObject.disk)
        {
            [int]$InputObject.disk 
        }
        else
        {
            0 
        }
        $this.Transfer = if ($InputObject.transfer)
        {
            [int]$InputObject.transfer 
        }
        else
        {
            0 
        }
        $this.PriceMonthly = if ($InputObject.price_monthly)
        {
            [decimal]$InputObject.price_monthly 
        }
        else
        {
            0 
        }
        $this.PriceHourly = if ($InputObject.price_hourly)
        {
            [decimal]$InputObject.price_hourly 
        }
        else
        {
            0 
        }
        $this.Regions = if ($InputObject.regions)
        {
            if ($InputObject.regions -is [array])
            {
                [string[]]$InputObject.regions
            }
            else
            {
                @([string]$InputObject.regions)
            }
        }
        else
        {
            @() 
        }
        $this.Available = if ($null -ne $InputObject.available)
        {
            [bool]$InputObject.available 
        }
        else
        {
            $false 
        }
        $this.Description = if ($InputObject.description)
        {
            [string]$InputObject.description 
        }
        else
        {
            '' 
        }
    }

    [string]ToString()
    {
        return $this.Slug
    }
}
