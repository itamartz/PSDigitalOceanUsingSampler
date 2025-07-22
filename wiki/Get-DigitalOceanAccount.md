# Get-DigitalOceanAccount

Retrieves DigitalOcean account information with pagination support.

## Syntax

```powershell
Get-DigitalOceanAccount [[-Page] <int>] [[-Limit] <int>] [<CommonParameters>]

Get-DigitalOceanAccount [-All] [<CommonParameters>]
```

## Description

The `Get-DigitalOceanAccount` function retrieves information about your
DigitalOcean account, including limits, verification status, and team
association. It supports both paginated results and retrieving all
account data at once.

## Parameters

### -Page

Specifies the page number for pagination (1-1000).

- **Type**: Int32
- **Default**: 1
- **Range**: 1-1000

### -Limit

Specifies the number of items per page (20-200).

- **Type**: Int32
- **Default**: 20
- **Range**: 20-200

### -All

Retrieves all account data by automatically handling pagination.

- **Type**: SwitchParameter
- **Default**: False

## Examples

### Example 1: Get account with default pagination

```powershell
Get-DigitalOceanAccount
```

Returns account information with default pagination settings.

### Example 2: Get specific page with custom limit

```powershell
Get-DigitalOceanAccount -Page 1 -Limit 50
```

Returns account data with a custom page limit.

### Example 3: Get all account data

```powershell
$account = Get-DigitalOceanAccount -All
```

Retrieves all available account information.

### Example 4: Working with account objects

```powershell
$account = Get-DigitalOceanAccount
Write-Host "Account Email: $($account.email)"
Write-Host "Droplet Limit: $($account.droplet_limit)"
Write-Host "Floating IP Limit: $($account.floating_ip_limit)"
Write-Host "Volume Limit: $($account.volume_limit)"
Write-Host "Email Verified: $($account.email_verified)"
Write-Host "Status: $($account.status)"
Write-Host "Status Message: $($account.status_message)"

if ($account.team) {
    Write-Host "Team Name: $($account.team.name)"
    Write-Host "Team UUID: $($account.team.uuid)"
}
```

### Example 5: Check account verification status

```powershell
$account = Get-DigitalOceanAccount
if ($account.email_verified) {
    Write-Host "✅ Account email is verified" -ForegroundColor Green
} else {
    Write-Host "⚠️ Account email needs verification" -ForegroundColor Yellow
}
```

## Output

Returns `Account` objects with the following properties:

- **droplet_limit**: Maximum number of droplets allowed
- **floating_ip_limit**: Maximum number of floating IPs allowed
- **volume_limit**: Maximum number of volumes allowed
- **email**: Account email address
- **uuid**: Unique account identifier
- **email_verified**: Boolean indicating if email is verified
- **status**: Account status (active, warning, locked)
- **status_message**: Additional status information
- **team**: Team object (if account is part of a team)
  - **name**: Team name
  - **uuid**: Team unique identifier

## Notes

- Requires valid `DIGITALOCEAN_TOKEN` environment variable
- Uses DigitalOcean API v2
- Account information is sensitive - handle with care
- Supports verbose output for debugging
- Returns strongly-typed PowerShell class objects

## Related Links

- [Get-DigitalOceanImage](Get-DigitalOceanImage)
- [Get-DigitalOceanRegion](Get-DigitalOceanRegion)
- [DigitalOcean Account API](https://docs.digitalocean.com/reference/api/api-reference/#operation/get_account)
