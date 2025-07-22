# Quick Start

Get up and running with PSDigitalOcean in minutes!

## Prerequisites

- ✅ PSDigitalOcean module installed ([Installation Guide](Installation-Guide))
- ✅ DigitalOcean API token configured ([Configuration](Configuration))

## Basic Usage

### 1. Import the Module

```powershell
Import-Module PSDigitalOcean
```

### 2. Test Your Connection

```powershell
# Get your account information
$account = Get-DigitalOceanAccount
Write-Host "Welcome, $($account.email)!" -ForegroundColor Green
```

### 3. Explore Available Regions

```powershell
# Get all regions
$regions = Get-DigitalOceanRegion -All

# Show available regions
$regions | ForEach-Object {
    Write-Host "$($_.Name) ($($_.Slug)) - Available: $($_.Available)"
}
```

### 4. Browse Images

```powershell
# Get Ubuntu distributions
$ubuntu = Get-DigitalOceanImage -Type "distribution" -All |
    Where-Object { $_.Name -like "*Ubuntu*" }

# Display Ubuntu options
$ubuntu | Select-Object Name, Slug, Distribution | Format-Table
```

## Common Tasks

### Check Account Limits

```powershell
$account = Get-DigitalOceanAccount
Write-Host "Droplet Limit: $($account.droplet_limit)"
Write-Host "Volume Limit: $($account.volume_limit)"
Write-Host "Floating IP Limit: $($account.floating_ip_limit)"
```

### Find Images in Specific Region

```powershell
# Get images available in NYC1
$nycImages = Get-DigitalOceanImage -All |
    Where-Object { $_.Regions -contains "nyc1" }

Write-Host "Found $($nycImages.Count) images in NYC1 region"
```

### Get Region Features

```powershell
# Find regions with specific features
$backupRegions = Get-DigitalOceanRegion -All |
    Where-Object { $_.Features -contains "backups" }

Write-Host "Regions with backup support:"
$backupRegions | ForEach-Object { Write-Host "  - $($_.Name)" }
```

## Pagination Examples

### Working with Large Datasets

```powershell
# Get images page by page
$page = 1
$allImages = @()

do {
    Write-Host "Fetching page $page..." -ForegroundColor Yellow
    $pageImages = Get-DigitalOceanImage -Page $page -Limit 50
    $allImages += $pageImages
    $page++
} while ($pageImages.Count -eq 50)

Write-Host "Total images retrieved: $($allImages.Count)" -ForegroundColor Green
```

### Use -All for Convenience

```powershell
# Let the module handle pagination automatically
$allImages = Get-DigitalOceanImage -All
Write-Host "Retrieved $($allImages.Count) images automatically"
```

## Object Methods

### Using ToString() Method

```powershell
$regions = Get-DigitalOceanRegion -All
foreach ($region in $regions) {
    # Each object has a custom ToString() method
    Write-Host $region.ToString()
}
```

### Converting to Hashtables

```powershell
$account = Get-DigitalOceanAccount
$accountHash = $account.ToHashtable()

# Display as formatted table
$accountHash | Format-Table -AutoSize
```

## Error Handling

### Basic Error Handling

```powershell
try {
    $account = Get-DigitalOceanAccount
    Write-Host "✅ Success: Connected to DigitalOcean" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Check your API token configuration" -ForegroundColor Yellow
}
```

### Verbose Output for Debugging

```powershell
# Use -Verbose to see detailed operation information
Get-DigitalOceanRegion -All -Verbose
```

## Next Steps

### Learn More

- 📖 [Function Reference](Get-DigitalOceanAccount) - Detailed function documentation
- 🔧 [Configuration](Configuration) - Advanced configuration options
- 🎯 [Common Use Cases](Common-Use-Cases) - Real-world examples
- 🐛 [Troubleshooting](Common-Issues) - Common issues and solutions

### Advanced Usage

- Combine functions to build automation scripts
- Use with other PowerShell modules for infrastructure management
- Integrate with CI/CD pipelines for deployment automation

### Get Help

- 💬 [GitHub Issues](https://github.com/Itamartz/PSDigitalOceanUsingSampler/issues)
- 📚 [DigitalOcean API Docs](https://docs.digitalocean.com/reference/api/)
- 🏠 [Wiki Home](Home) - Complete documentation index
