class DigitalOceanSize {
    [string]$Slug
    [int]$Memory
    [int]$Vcpus
    [int]$Disk
    [int]$Transfer
    [decimal]$PriceMonthly
    [decimal]$PriceHourly
    [array]$Regions
    [bool]$Available
    [string]$Description

    DigitalOceanSize() {}

    DigitalOceanSize([PSCustomObject]$InputObject) {
        $this.Slug = $InputObject.slug
        $this.Memory = $InputObject.memory
        $this.Vcpus = $InputObject.vcpus
        $this.Disk = $InputObject.disk
        $this.Transfer = $InputObject.transfer
        $this.PriceMonthly = $InputObject.price_monthly
        $this.PriceHourly = $InputObject.price_hourly
        $this.Regions = $InputObject.regions
        $this.Available = $InputObject.available
        $this.Description = $InputObject.description
    }

    [string]ToString() {
        return $this.Slug
    }
}
