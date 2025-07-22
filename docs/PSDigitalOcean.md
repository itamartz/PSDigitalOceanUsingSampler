# PSDigitalOcean

## Description

PSDigitalOcean is a comprehensive PowerShell module for managing DigitalOcean  
resources through their REST API. The module provides a complete set of  
cmdlets for interacting with DigitalOcean services including account  
management, image retrieval, and region information.

## Key Features

- **Complete API Coverage**: Access to DigitalOcean's REST API v2
- **Class-Based Architecture**: Strongly-typed PowerShell classes for all objects
- **Pagination Support**: Automatic handling of paginated API responses
- **Error Handling**: Comprehensive error handling and validation
- **Security**: Secure API token management through environment variables

## Getting Started

### Prerequisites

- PowerShell 5.1 or PowerShell 7+
- DigitalOcean account with API access
- Valid DigitalOcean API token

### Installation

Install from PowerShell Gallery:

```powershell
Install-Module -Name PSDigitalOcean -Scope CurrentUser
```

### Configuration

Set your DigitalOcean API token:

```powershell
[Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "your-token-here", "User")
```

### Basic Usage

```powershell
# Import the module
Import-Module PSDigitalOcean

# Get account information
$account = Get-DigitalOceanAccount
Write-Host "Account: $($account.email)"

# List available regions
$regions = Get-DigitalOceanRegion -All
$regions | Format-Table Name, Slug, Available

# Browse available images
$images = Get-DigitalOceanImage -Type "distribution"
$images | Where-Object { $_.Name -like "*Ubuntu*" } | Format-Table Name, Slug
```

## Available Commands

### Account Management

- `Get-DigitalOceanAccount` - Retrieve account information and limits

### Image Operations

- `Get-DigitalOceanImage` - Browse and filter available images

### Region Information

- `Get-DigitalOceanRegion` - Get region availability and features

## Class Objects

The module returns strongly-typed PowerShell class objects:

- `Account` - Account information with team association
- `DigitalOceanImage` - Image metadata and availability
- `DigitalOceanRegion` - Region features and supported sizes
- `Team` - Team information for organization accounts

## Error Handling

All cmdlets include comprehensive error handling:

```powershell
try {
    $account = Get-DigitalOceanAccount
    Write-Host "Success: $($account.email)"
} catch {
    Write-Error "Failed: $($_.Exception.Message)"
}
```

## Security Considerations

- Store API tokens securely using environment variables
- Never commit tokens to source control
- Use minimal required API scopes
- Regularly rotate API tokens

## Support

- **GitHub**: https://github.com/Itamartz/PSDigitalOceanUsingSampler
- **Wiki**: https://github.com/Itamartz/PSDigitalOceanUsingSampler/wiki
- **Issues**: https://github.com/Itamartz/PSDigitalOceanUsingSampler/issues

## License

This project is licensed under the MIT License.
