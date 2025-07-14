function Invoke-DigitalOceanAPI
{
    <#
    .SYNOPSIS
    This private function invokes the DigitalOcean API.
    .DESCRIPTION
    This function is used to make API calls to DigitalOcean. It requires an API token to authenticate the request.
    .PARAMETER APIPath
    The API path to call, such as 'account', 'droplets', 'tags', etc.
    .PARAMETER APIVersion
    The API version to use, currently defaults to 'v2'.
    If you need to use a different version, you can specify it here.
    .PARAMETER Method
    The HTTP method to use.
    Valid values are 'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'TRACE', and 'PATCH'.
    Defaults to 'GET'.
    .PARAMETER Parameters
    The query parameters to include in the request.
    This should be a hashtable where the keys are parameter names and the values are parameter values.
    .EXAMPLE
    Invoke-DigitalOceanAPI -APIPath 'account' -APIVersion 'v2' -Method 'GET' -Parameters @{ page = 1; per_page = 10 }
    This example retrieves the account information from the DigitalOcean API.
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $APIPath,

        [Parameter()]
        [String]
        $APIVersion = 'v2',

        [Parameter()]
        [ValidateSet('GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'TRACE', 'PATCH')]
        $Method = 'GET',

        [Parameter()]
        [hashtable]
        $Parameters
    )

    $Token = Get-DigitalOceanAPIAuthorizationBearerToken

    if ([string]::IsNullOrEmpty($Token))
    {
        throw "DigitalOcean API token is not set. Please set the DIGITALOCEAN_TOKEN environment variable."
    }

    $Headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $($Token)"
    }

    if ($null -ne $Parameters -and $Parameters.Count -gt 0)
    {
        $query = ($Parameters.GetEnumerator() | ForEach-Object {
                "$([uri]::EscapeDataString($_.Key))=$([uri]::EscapeDataString($_.Value.ToString()))"
            }) -join "&"
    }
    if (-not [string]::IsNullOrEmpty($query))
    {
        $URI = "https://api.digitalocean.com/$($APIVersion)/$($APIPath)?$($query)"
    }
    else
    {
        $URI = "https://api.digitalocean.com/$($APIVersion)/$($APIPath)"
    }

    Write-Verbose "about to run $($URI)"
    $Response = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $URI
    $Response
}
