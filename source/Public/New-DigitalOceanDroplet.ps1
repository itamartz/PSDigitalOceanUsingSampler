function New-DigitalOceanDroplet
{
    <#
    .SYNOPSIS
    New-DigitalOceanDroplet

    .DESCRIPTION
    Creates a new DigitalOcean Droplet with the specified configuration. This function allows you to create a virtual machine instance with custom settings including size, image, networking options, monitoring, backups, and additional storage volumes.

    .PARAMETER DropletName
    The human-readable string you wish to use when displaying the Droplet name. The name, if set to a domain name managed in the DigitalOcean DNS management system, will configure a PTR record for the Droplet.

    .PARAMETER SSHKey
    SSH key object to be added to the Droplet for authentication. Must be a DigitalOcean.Account.SSHKeys object.

    .PARAMETER Backups
    A boolean indicating whether automated backups should be enabled for the Droplet.

    .PARAMETER IPV6
    A boolean indicating whether to enable IPv6 on the Droplet.

    .PARAMETER Monitoring
    A boolean indicating whether to install the DigitalOcean agent for monitoring.

    .PARAMETER Tags
    A flat array of tag names as strings to apply to the Droplet after it is created.

    .PARAMETER UserData
    A string containing 'user data' which may be used to configure the Droplet on first boot, often a 'cloud-config' file or Bash script.

    .PARAMETER Volumes
    An array of IDs for block storage volumes that will be attached to the Droplet once created.

    .PARAMETER Region
    The slug identifier for the region where the resource will initially be available.

    .PARAMETER Size
    The slug identifier for the size that you wish to select for this Droplet. This is a dynamic parameter populated from available sizes.

    .PARAMETER Image
    The slug identifier for a public image. This image will be the base image for your Droplet. This is a dynamic parameter populated from available images.

    .EXAMPLE
    New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64"

    .EXAMPLE
    New-DigitalOceanDroplet -DropletName "web-server" -Size "s-2vcpu-2gb" -Image "ubuntu-20-04-x64" -Backups $true -Monitoring $true

    .LINK
    https://docs.digitalocean.com/reference/api/digitalocean/#tag/Droplets

    .OUTPUTS
    DigitalOcean.Droplet
    System.String
  #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Object], [String])]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = "The human-readable string you wish to use when displaying the Droplet name. The name, if set to a domain name managed in the DigitalOcean DNS management system, will configure a PTR record for the Droplet. The name set during creation will also determine the hostname for the Droplet in its internal configuration.")]
        [ValidatePattern("^[a-zA-Z0-9]?[a-z0-9A-Z.\-]*[a-z0-9A-Z]$")]
        [String]
        $DropletName,

        [Parameter(HelpMessage = "SSH key object to be added to the Droplet for authentication. Must be a DigitalOcean.Account.SSHKeys object.")]
        [ValidateScript({ $_.PSObject.TypeNames[0] -eq 'DigitalOcean.Account.SSHKeys' })]
        $SSHKey,

        [Parameter(HelpMessage = "A boolean indicating whether automated backups should be enabled for the Droplet.")]
        [bool]
        $Backups,

        [Parameter(HelpMessage = "A boolean indicating whether to enable IPv6 on the Droplet.")]
        [bool]
        $IPV6,

        [Parameter(HelpMessage = "A boolean indicating whether to install the DigitalOcean agent for monitoring.")]
        [bool]
        $Monitoring,

        [Parameter(HelpMessage = "A flat array of tag names as strings to apply to the Droplet after it is created. Tag names can either be existing or new tags.")]
        [string[]]
        $Tags,

        [Parameter(HelpMessage = "A string containing 'user data' which may be used to configure the Droplet on first boot, often a 'cloud-config' file or Bash script. It must be plain text and may not exceed 64 KiB in size.")]
        [string]
        $UserData,

        [Parameter(ParameterSetName = "Volume", HelpMessage = "An array of IDs for block storage volumes that will be attached to the Droplet once created. The volumes must not already be attached to an existing Droplet.")]
        [string[]]
        $Volumes,

        [Parameter(ParameterSetName = "Volume", HelpMessage = "The slug identifier for the region where the resource will initially be available.")]
        [string]
        $Region
    )

    dynamicparam
    {
        # Define the runtime parameter dictionary
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        #region Size

        # Define attributes for the dynamic parameter
        $attributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Make it mandatory
        $attr = New-Object System.Management.Automation.ParameterAttribute
        $attr.Mandatory = $true
        $attr.HelpMessage = 'The slug identifier for the size that you wish to select for this Droplet.'
        $attributes.Add($attr)

        $AllDigitalOceanDropletSize = Get-DigitalOceanSize
        $validateAttr = New-Object System.Management.Automation.ValidateSetAttribute($AllDigitalOceanDropletSize.slug)
        $attributes.Add($validateAttr)

        $parameterName = 'Size'
        $runtimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($parameterName, [string], $attributes)

        # Add it to the dictionary
        $paramDictionary.Add($parameterName, $runtimeParam)

        #endregion Size

        #region Image

        # Define attributes for the dynamic parameter
        $attributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Make it mandatory
        $attr = New-Object System.Management.Automation.ParameterAttribute
        $attr.Mandatory = $true
        $attr.HelpMessage = "The slug identifier for a public image. This image will be the base image for your Droplet."
        $attributes.Add($attr)

        $AllDigitalOceanDropletImage = Get-DigitalOceanImage
        $validateAttr = $null
        $validateAttr = New-Object System.Management.Automation.ValidateSetAttribute($AllDigitalOceanDropletImage.slug)
        $attributes.Add($validateAttr)

        $parameterName = 'Image'
        $runtimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($parameterName, [string], $attributes)

        # Add it to the dictionary
        $paramDictionary.Add($parameterName, $runtimeParam)

        #endregion Image

        return $paramDictionary
    }

    process
    {
        #Content
        $DigitalOceanConfiguration = Get-Variable -Name DigitalOceanConfiguration -ValueOnly -Scope Global
        $URL = "$($DigitalOceanConfiguration.URL)/droplets"

        $Body = @{
            name  = $DropletName
            image = $PSBoundParameters['Image']
            size  = $PSBoundParameters['Size']

        }
        if ($SSHKey)
        {
            $Body.Add('ssh_keys', @($($SSHKey.id)))
        }
        if ($Backups)
        {
            $Body.Add('backups', $Backups)
        }
        if ($IPV6)
        {
            $Body.Add('ipv6', $IPV6)
        }
        if ($Monitoring)
        {
            $Body.Add('monitoring', $Monitoring)
        }
        if ($Tags.Count -gt 0)
        {
            $Body.Add('tags', $Tags)
        }
        if ($UserData)
        {
            $Body.Add('user_data', $UserData)
        }
        if ($Volumes.Count -gt 0)
        {
            $Body.Add('volumes', $Volumes)
            # TODO: Add Get-DigitalOceanVolume call when function is available
            # Get-DigitalOceanVolume
        }

        try
        {
            # TODO: Add droplet existence check when Get-DigitalOceanDroplet function is available
            # For now, proceed directly to creation
            if ($PSCmdlet.ShouldProcess("$($Body | ConvertTo-Json)", "Create"))
            {
                $response = Invoke-RestMethod -Method Post -Uri $URL -Headers $DigitalOceanConfiguration.Headers -Body ($Body | ConvertTo-Json) -ErrorAction Stop
                $response.droplet.PSObject.TypeNames.Insert(0, 'DigitalOcean.Droplet')
                $response.droplet
            }
        }
        catch
        {
            "Error was $_"
            $line = $_.InvocationInfo.ScriptLineNumber
            "Error was in Line $line"
        }


    }

}
