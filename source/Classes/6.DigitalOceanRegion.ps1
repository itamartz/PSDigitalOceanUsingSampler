# DigitalOceanRegion class for representing DigitalOcean region objects
class DigitalOceanRegion {
    [string] $Name
    [string] $Slug
    [string[]] $Features
    [bool] $Available
    [string[]] $Sizes

    # Constructor from API response object
    DigitalOceanRegion([PSCustomObject] $APIResponse) {
        $this.Name = $APIResponse.name
        $this.Slug = $APIResponse.slug
        $this.Features = $APIResponse.features
        $this.Available = $APIResponse.available
        $this.Sizes = $APIResponse.sizes
    }

    # Default constructor
    DigitalOceanRegion() {}

    # ToString method for display
    [string] ToString() {
        return "$($this.Name) ($($this.Slug)) - Available: $($this.Available)"
    }

    # Convert to hashtable for easy property access
    [hashtable] ToHashtable() {
        return @{
            Name = $this.Name
            Slug = $this.Slug
            Features = $this.Features
            Available = $this.Available
            Sizes = $this.Sizes
        }
    }
}
