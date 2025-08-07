class DigitalOceanSSHKey
{
    [int]$Id
    [string]$Name
    [string]$Fingerprint
    [string]$PublicKey

    # Default constructor
    DigitalOceanSSHKey()
    {
        $this.Id = 0
        $this.Name = ''
        $this.Fingerprint = ''
        $this.PublicKey = ''
    }

    # Constructor with properties
    DigitalOceanSSHKey([int]$Id, [string]$Name, [string]$Fingerprint, [string]$PublicKey)
    {
        $this.Id = $Id
        $this.Name = $Name
        $this.Fingerprint = $Fingerprint
        $this.PublicKey = $PublicKey
    }

    # Method to display SSH key information
    [string] ToString()
    {
        return "SSH Key: $($this.Name) (ID: $($this.Id))"
    }
}
