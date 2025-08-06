function Get-DigitalOceanSSHKey
{
    <#
    .SYNOPSIS
    Retrieves SSH keys from your DigitalOcean account.

    .DESCRIPTION
    The Get-DigitalOceanSSHKey function retrieves SSH keys associated with your DigitalOcean account.
    You can retrieve all SSH keys or filter by a specific SSH key name. SSH keys are used to
    securely access DigitalOcean Droplets without using passwords.

    .PARAMETER SSHKeyName
    Optional. The name of a specific SSH key to retrieve. If not provided, all SSH keys will be returned.

    .EXAMPLE
    Get-DigitalOceanSSHKey

    Retrieves all SSH keys from your DigitalOcean account.

    .EXAMPLE
    Get-DigitalOceanSSHKey -SSHKeyName "my-laptop-key"

    Retrieves the SSH key named "my-laptop-key" from your DigitalOcean account.

    .EXAMPLE
    $sshKeys = Get-DigitalOceanSSHKey
    $sshKeys | Where-Object { $_.name -like "*production*" }

    Gets all SSH keys and filters for those containing "production" in the name.

    .EXAMPLE
    Get-DigitalOceanSSHKey | Select-Object name, fingerprint, public_key

    Retrieves all SSH keys and displays only the name, fingerprint, and public key.

    .INPUTS
    None. You cannot pipe objects to Get-DigitalOceanSSHKey.

    .OUTPUTS
    DigitalOcean.Account.SSHKeys
    Returns SSH key objects with properties including name, fingerprint, public_key, and id.

    .NOTES
    - Requires a valid DigitalOcean API token to be configured
    - SSH keys are essential for secure access to DigitalOcean Droplets
    - The function returns detailed information about each SSH key including the public key content

    .LINK
    https://docs.digitalocean.com/reference/api/digitalocean/#tag/SSH-Keys

    .LINK
    Add-DigitalOceanAPIToken
    #>

    [CmdletBinding()]
    [OutputType('DigitalOcean.Account.SSHKeys')]
    param
    (
        [Parameter(
            HelpMessage = "The name of a specific SSH key to retrieve"
        )]
        [String]
        $SSHKeyName
    )

    try
    {
        Write-Verbose "Retrieving SSH keys from DigitalOcean account"

        $Parameters = @{
            per_page = 200
        }

        $response = Invoke-DigitalOceanAPI -APIPath "account/keys" -Parameters $Parameters

        if ($null -eq $response.ssh_keys)
        {
            Write-Warning "No SSH keys found in your DigitalOcean account"
            return
        }

        # Apply type name to each SSH key object
        foreach ($item in $response.ssh_keys)
        {
            $item.PSObject.TypeNames.Insert(0, 'DigitalOcean.Account.SSHKeys')
        }

        # Filter by SSH key name if specified
        if ($PSBoundParameters.ContainsKey('SSHKeyName'))
        {
            Write-Verbose "Filtering for SSH key: $SSHKeyName"
            $filteredKeys = $response.ssh_keys | Where-Object { $_.name -eq $SSHKeyName }

            if ($null -eq $filteredKeys)
            {
                Write-Warning "SSH key '$SSHKeyName' not found in your DigitalOcean account"
                return
            }

            Write-Output $filteredKeys
        }
        else
        {
            Write-Verbose "Found $($response.ssh_keys.Count) SSH key(s)"
            Write-Output $response.ssh_keys
        }
    }
    catch
    {
        Write-Error "Failed to retrieve SSH keys from DigitalOcean: $($_.Exception.Message)"
    }
}
