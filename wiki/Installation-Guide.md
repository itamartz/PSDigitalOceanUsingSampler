# Installation Guide

## System Requirements

- PowerShell 5.1 or PowerShell 7+
- Windows, macOS, or Linux
- Internet connection for API calls
- DigitalOcean API token

## Installation Methods

### Method 1: PowerShell Gallery (Recommended)

```powershell
# Install for current user
Install-Module -Name PSDigitalOcean -Scope CurrentUser

# Install system-wide (requires admin privileges)
Install-Module -Name PSDigitalOcean -Scope AllUsers
```

### Method 2: From GitHub Release

```powershell
# Download latest release
$url = "https://github.com/Itamartz/PSDigitalOceanUsingSampler/releases/latest"
Invoke-WebRequest -Uri $url -OutFile "PSDigitalOcean.zip"

# Extract and install
Expand-Archive -Path "PSDigitalOcean.zip" -DestinationPath "$env:PSModulePath"
```

### Method 3: Development Installation

```powershell
# Clone repository
git clone https://github.com/Itamartz/PSDigitalOceanUsingSampler.git
cd PSDigitalOceanUsingSampler

# Build module
.\build.ps1 -AutoRestore -Tasks build

# Import module
Import-Module .\output\module\PSDigitalOcean\*\PSDigitalOcean.psd1
```

## Verification

```powershell
# Check module installation
Get-Module -ListAvailable PSDigitalOcean

# Import module
Import-Module PSDigitalOcean

# List available commands
Get-Command -Module PSDigitalOcean
```

## Next Steps

- [Configuration](Configuration) - Set up your API token
- [Quick Start](Quick-Start) - Basic usage examples
