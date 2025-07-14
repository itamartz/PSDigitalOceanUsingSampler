function Get-DigitalOceanAPIAuthorizationBearerToken
{
    <#
    .SYNOPSIS
    Get-DigitalOceanAPIAuthorizationBearerToken

    .DESCRIPTION
    Get Digital Ocean API Authorization Bearer Token.

    .EXAMPLE
    Get-DigitalOceanAPIAuthorizationBearerToken

    .OUTPUTS
    [System.String]
  #>


    [CmdletBinding()]
    [OutputType([System.String])]
    param()
    begin
    {
        #Content

    }
    process
    {
        [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    }
    end
    {
        #Content

    }



}
