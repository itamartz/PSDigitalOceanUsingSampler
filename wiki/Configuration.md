# Configuration

Learn how to configure the PSDigitalOcean module for use with your DigitalOcean account.

## Prerequisites

- PowerShell 5.1 or PowerShell 7+
- Active DigitalOcean account
- DigitalOcean API token

## Getting Your API Token

1. Log in to your [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
1. Navigate to **API** section in the left sidebar
1. Click **Generate New Token**
1. Enter a descriptive name for your token
1. Select appropriate scopes (Read/Write recommended)
1. Click **Generate Token**
1. **Important**: Copy the token immediately - it won't be shown again!

## Setting Up the API Token

### Method 1: Environment Variable (Recommended)

Set the token as a persistent environment variable:

```powershell
# For current user only
[Environment]::SetEnvironmentVariable(
    "DIGITALOCEAN_TOKEN",
    "your-api-token-here",
    [System.EnvironmentVariableTarget]::User
)

# For system-wide access (requires admin privileges)
[Environment]::SetEnvironmentVariable(
    "DIGITALOCEAN_TOKEN",
    "your-api-token-here",
    [System.EnvironmentVariableTarget]::Machine
)
```

### Method 2: Session Variable (Temporary)

Set the token for the current PowerShell session only:

```powershell
$env:DIGITALOCEAN_TOKEN = "your-api-token-here"
```

## Verification

Verify your configuration by testing account access:

```powershell
# Import the module
Import-Module PSDigitalOcean

# Test API connection
try {
    $account = Get-DigitalOceanAccount
    Write-Host "✅ Configuration successful!" -ForegroundColor Green
    Write-Host "Account Email: $($account.email)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Configuration failed: $_" -ForegroundColor Red
}
```

## Security Best Practices

### Token Security

- **Never** commit tokens to source control
- Use environment variables instead of hardcoding
- Regularly rotate your API tokens
- Use minimal required scopes for your use case

### PowerShell Profile Setup

Add to your PowerShell profile for automatic loading:

```powershell
# Check if profile exists, create if it doesn't
if (!(Test-Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force
}

# Add to profile
Add-Content $PROFILE @"
# PSDigitalOcean Auto-Import
if (Get-Module -ListAvailable PSDigitalOcean) {
    Import-Module PSDigitalOcean -Force
}
"@
```

## Troubleshooting

### Common Issues

## Error: "No DIGITALOCEAN_TOKEN environment variable found"

- Ensure the environment variable is set correctly
- Restart PowerShell after setting system-wide variables
- Verify the variable name is exactly `DIGITALOCEAN_TOKEN`

## Error: "401 Unauthorized"

- Check that your API token is valid and not expired
- Verify the token has appropriate scopes
- Regenerate the token if necessary

## Error: "Module not found"

- Ensure PSDigitalOcean is installed: `Get-Module -ListAvailable PSDigitalOcean`
- Try importing explicitly: `Import-Module PSDigitalOcean -Force`

### Getting Help

If you need assistance:

- Check the [Common Issues](Common-Issues) page
- Review the [API Error Codes](API-Error-Codes) documentation
- Submit an issue on [GitHub](https://github.com/Itamartz/PSDigitalOceanUsingSampler/issues)

## Next Steps

- [Quick Start](Quick-Start) - Basic usage examples
- [Get-DigitalOceanAccount](Get-DigitalOceanAccount) - Account management
- [Get-DigitalOceanImage](Get-DigitalOceanImage) - Image operations
- [Get-DigitalOceanRegion](Get-DigitalOceanRegion) - Region information
