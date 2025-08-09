# PSDigitalOcean

A compre## 🆕 Latest Updates (v1.7.0)

🚀 **New Remove-DigitalOceanVolume Function**

- ✨ **New Function**: Remove-DigitalOceanVolume with dual deletion methods  
  (by ID or name+region)
- 🛡️ **Enhanced Security**: High-impact confirmation with ShouldProcess  
  support
- 🔍 **Comprehensive Testing**: 35 dedicated unit tests plus real API  
  integration testing
- 📊 **Improved Coverage**: Increased to 96.03% test coverage with 599  
  total tests
- ✅ **Production Ready**: Fully validated with real DigitalOcean API calls
- 🎯 **Robust Error Handling**: Detailed API error parsing and  
  user-friendly messageswerShell module for managing DigitalOcean resources with
enterprise-grade reliability and extensive test coverage.

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PSDigitalOcean.svg)](https://www.powershellgallery.com/packages/PSDigitalOcean)
[![Code Coverage](https://img.shields.io/badge/coverage-96.03%25-brightgreen.svg)](https://codecov.io/gh/itamartz/PSDigitalOceanUsingSampler)

## 🚀 Key Features

✅ **Complete PowerShell Module** with proper structure and modern  
development practices  
✅ **96.03% Test Coverage** with 599 comprehensive tests  
   (590 passed, 9 skipped) using Pester v5  
✅ **Class-based Architecture** with strongly-typed PowerShell classes for  
   Account, Team, Image, Region, Size, SSH Key, VPC, Volume, and  
   Droplet objects  
✅ **Comprehensive Error Handling** and defensive programming patterns  
   throughout  
✅ **CI/CD Pipeline** with Azure Pipelines configuration for automated  
   testing and deployment  
✅ **Professional Documentation** with detailed help files, examples, and  
   inline documentation  
✅ **Modern Build System** using Sampler framework with  
ModuleBuilder integration  
✅ **Enterprise Ready** with full parameter validation, pagination support, and  
   robust API integration

## 🆕 Latest Updates (v1.6.1)

🔧 **Bug Fix and Error Handling Enhancement**

- 🐛 **Fixed**: New-DigitalOceanVolume API integration issues resolved
- � **Enhanced Error Handling**: Improved API error reporting with detailed response parsing  
- � **Documentation**: Updated New-DigitalOceanDroplet parameter documentation
- 🧪 **Integration Testing**: Added critical integration testing requirements for non-GET functions
- 📊 **Test Coverage**: Maintained excellent 95.89% coverage with 549 tests
- ✅ **Quality Assured**: Real API validation ensures production reliability

## 📦 Installation

### From PowerShell Gallery (Recommended)

```powershell
Install-Module -Name PSDigitalOcean -Scope CurrentUser
```

### From Source

```powershell
git clone https://github.com/your-username/PSDigitalOcean.git
cd PSDigitalOcean
.\build.ps1 -Tasks build
```

## 🔧 Configuration

Before using the module, you need to set your DigitalOcean API token:

```powershell
# Method 1: Use the provided function (Recommended)
Add-DigitalOceanAPIToken -Token "your-api-token-here"

# Method 2: Set manually as environment variable
[Environment]::SetEnvironmentVariable(
    "DIGITALOCEAN_TOKEN",
    "your-api-token-here",
    [System.EnvironmentVariableTarget]::User
)
```

Get your API token from the [DigitalOcean Control Panel](https://cloud.digitalocean.com/account/api/tokens).

## 📚 Usage Examples

### Get Account Information

```powershell
# Get account with pagination
Get-DigitalOceanAccount -Page 1 -Limit 20

# Get all accounts at once
Get-DigitalOceanAccount -All
```

### Get DigitalOcean Images

```powershell
# Get images with pagination
Get-DigitalOceanImage -Page 1 -Limit 20

# Get all images at once
Get-DigitalOceanImage -All

# Filter by image type
Get-DigitalOceanImage -Type "application"
Get-DigitalOceanImage -Type "distribution"
```

### Get DigitalOcean Sizes

```powershell
# Get sizes with pagination
Get-DigitalOceanSize -Page 1 -Limit 20

# Get all sizes at once
Get-DigitalOceanSize -All
```

### Get SSH Keys

```powershell
# Get all SSH keys
Get-DigitalOceanSSHKey

# Get a specific SSH key by name
Get-DigitalOceanSSHKey -SSHKeyName "my-laptop-key"
```

### Get Volumes

```powershell
# Get volume by ID
Get-DigitalOceanVolume -VolumeId "506f78a4-e098-11e5-ad9f-000f53306ae1"

# Get volumes by name
Get-DigitalOceanVolume -VolumeName "my-volume"

# Get volumes in a specific region
Get-DigitalOceanVolume -Region "nyc1"

# List all volumes with pagination
Get-DigitalOceanVolume -Page 1 -Limit 20

# Get all volumes at once
Get-DigitalOceanVolume -All
```

### Get VPCs (Virtual Private Clouds)

```powershell
# Get all VPCs
Get-DigitalOceanVPC

# Filter VPCs by name
Get-DigitalOceanVPC | Where-Object { $_.Name -like "*production*" }

# Get specific VPC properties
Get-DigitalOceanVPC | Select-Object Name, IpRange, Region
```

### Create DigitalOcean Droplets

```powershell
# Create a basic droplet
New-DigitalOceanDroplet -DropletName "web-server" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64"

# Create a droplet with additional features
New-DigitalOceanDroplet -DropletName "production-server" -Size "s-2vcpu-2gb" -Image "ubuntu-20-04-x64" -Backups $true -Monitoring $true -Tags @("production", "web")

# Create a droplet with SSH key and user data
$sshKey = Get-DigitalOceanSSHKey | Where-Object { $_.name -eq "my-key" }
$userData = @"
#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
"@

New-DigitalOceanDroplet -DropletName "nginx-server" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -SSHKey $sshKey -UserData $userData

# Preview droplet creation with -WhatIf
New-DigitalOceanDroplet -DropletName "test-server" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -WhatIf
```

### Working with Class Objects

The module returns strongly-typed PowerShell class objects:

```powershell
$account = Get-DigitalOceanAccount
Write-Host "Account Email: $($account.email)"
Write-Host "Droplet Limit: $($account.droplet_limit)"
Write-Host "Team Name: $($account.team.name)"

$sizes = Get-DigitalOceanSize -All
foreach ($size in $sizes) {
    Write-Host "Size: $($size.ToString())"
    Write-Host "Memory: $($size.Memory) MB, vCPUs: $($size.Vcpus)"
    Write-Host "Available Regions: $($size.Regions -join ', ')"
}
```

## 🏗️ Architecture

### PowerShell Classes

- **Team**: Represents DigitalOcean team information with UUID and name
- **Account**: Complete account object with limits, verification status, and  
  team association
- **DigitalOceanImage**: Represents DigitalOcean images with comprehensive  
  metadata and properties
- **DigitalOceanRegion**: Represents DigitalOcean regions with features,  
  availability, and supported sizes
- **DigitalOceanSize**: Represents DigitalOcean Droplet sizes with pricing,  
  specifications, and regional availability
- **DigitalOceanVPC**: Represents DigitalOcean Virtual Private Clouds with  
  network configuration and regional information
- **DigitalOceanDroplet**: Represents DigitalOcean Droplets with comprehensive  
  server configuration and status information
- **Root**: Container class for account responses

### API Integration

- **Invoke-DigitalOceanAPI**: Core API client with full HTTP method support
- **Get-DigitalOceanAPIAuthorizationBearerToken**: Secure token management
- **Comprehensive Error Handling**: Graceful handling of API failures and edge cases

## 🧪 Testing & Quality

### Test Coverage

- **471 Tests** across all functionality
- **98.95% Code Coverage** exceeding industry standards
- **Unit Tests** for all public and private functions
- **Integration Tests** for real DigitalOcean API interaction scenarios
- **Class Coverage Tests** ensuring all PowerShell classes work correctly

### Quality Assurance

- **PSScriptAnalyzer** compliance for code quality
- **Pester v5** testing framework
- **Automated CI/CD** pipeline with Azure DevOps
- **Code Coverage Reports** with detailed analysis

## 🛠️ Development

### Prerequisites

- PowerShell 5.1 or PowerShell 7+
- Pester v5.7.1+
- Sampler build framework

### Building the Module

```powershell
# Install dependencies and build
.\build.ps1 -AutoRestore -Tasks build

# Run all tests
.\build.ps1 -AutoRestore -Tasks test

# Build and test in one command
.\build.ps1 -AutoRestore
```

### Project Structure

```bash
PSDigitalOcean/
├── source/
│   ├── Classes/           # PowerShell class definitions
│   ├── Private/           # Internal functions
│   ├── Public/            # Exported functions
│   └── en-US/            # Help documentation
├── tests/
│   ├── Unit/             # Unit tests for all functions
│   ├── Integration/      # Integration tests for real API scenarios
│   └── QA/               # Quality assurance tests
├── output/               # Build artifacts
└── build.ps1             # Build script
```

## 📋 Available Functions

### Public Functions

- `Add-DigitalOceanAPIToken` - Securely store DigitalOcean API token with  
  cross-platform support
- `Get-DigitalOceanAccount` - Retrieve account information with pagination support
- `Get-DigitalOceanImage` - Retrieve DigitalOcean images with filtering and  
  pagination support
- `Get-DigitalOceanRegion` - Retrieve DigitalOcean regions with pagination support
- `Get-DigitalOceanSize` - Retrieve DigitalOcean Droplet sizes with pagination support
- `Get-DigitalOceanSSHKey` - Retrieve SSH keys from DigitalOcean account with  
  filtering support
- `Get-DigitalOceanVolume` - Retrieve DigitalOcean volumes with support for  
  ID, name, and region-based filtering
- `Get-DigitalOceanVPC` - Retrieve Virtual Private Cloud (VPC) information from  
  DigitalOcean account
- `New-DigitalOceanDroplet` - Create new DigitalOcean Droplets with comprehensive  
  configuration options including SSH keys, backups, monitoring, and user data
- `New-DigitalOceanVolume` - Create new DigitalOcean volumes with filesystem  
  configuration and snapshot support
- `Remove-DigitalOceanVolume` - Remove DigitalOcean volumes by ID or name+region  
  with comprehensive error handling and ShouldProcess support

### Private Functions

- `Get-DigitalOceanAPIAuthorizationBearerToken` - Token management
- `Invoke-DigitalOceanAPI` - Core API communication

## 🤝 Contributing

We welcome contributions!  
Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
1. Create a feature branch
1. Make your changes with tests
1. Ensure all tests pass: `.\build.ps1 -Tasks test`
1. Submit a pull request

## 📄 License

This project is licensed under the MIT License – see the  
[LICENSE](LICENSE) file for details.

## 🔗 Links

- [DigitalOcean API Documentation](https://docs.digitalocean.com/reference/api/)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/PSDigitalOcean)
- [GitHub Wiki](https://github.com/Itamartz/PSDigitalOceanUsingSampler/wiki)
- [Issue Tracker](https://github.com/Itamartz/PSDigitalOceanUsingSampler/issues)

## 📈 Roadmap

- [x] **Droplet Management** - Create DigitalOcean Droplets with comprehensive options
- [ ] Additional DigitalOcean resource support (Volumes, Load Balancers, etc.)
- [ ] Advanced Droplet management (Get, Update, Delete, Snapshots)
- [ ] PowerShell 7 cross-platform compatibility testing
- [ ] Advanced filtering and search capabilities

---

### Built with ❤️ using PowerShell and the Sampler framework
