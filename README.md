# PSDigitalOcean

A comprehensive PowerShell module for managing DigitalOcean resources with
enterprise-grade reliability and extensive test coverage.

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PSDigitalOcean.svg)](https://www.powershellgallery.com/packages/PSDigitalOcean)
[![Code Coverage](https://img.shields.io/badge/coverage-96.73%25-brightgreen.svg)](https://codecov.io/gh/itamartz/PSDigitalOceanUsingSampler)

## 🚀 Key Features

✅ **Complete PowerShell Module** with proper structure and modern  
development practices  
✅ **96.73% Test Coverage** with 180 comprehensive passing tests  
   using Pester v5  
✅ **Class-based Architecture** with strongly-typed PowerShell classes for  
   Account, Team, Image, Region, and Root objects  
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
# Set your DigitalOcean API token as an environment variable
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

### Get DigitalOcean Regions

```powershell
# Get regions with pagination
Get-DigitalOceanRegion -Page 1 -Limit 20

# Get all regions at once
Get-DigitalOceanRegion -All
```

### Working with Class Objects

The module returns strongly-typed PowerShell class objects:

```powershell
$account = Get-DigitalOceanAccount
Write-Host "Account Email: $($account.email)"
Write-Host "Droplet Limit: $($account.droplet_limit)"
Write-Host "Team Name: $($account.team.name)"

$regions = Get-DigitalOceanRegion -All
foreach ($region in $regions) {
    Write-Host "Region: $($region.ToString())"
    Write-Host "Features: $($region.Features -join ', ')"
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
- **Root**: Container class for account responses

### API Integration

- **Invoke-DigitalOceanAPI**: Core API client with full HTTP method support
- **Get-DigitalOceanAPIAuthorizationBearerToken**: Secure token management
- **Comprehensive Error Handling**: Graceful handling of API failures and edge cases

## 🧪 Testing & Quality

### Test Coverage

- **180 Tests** across all functionality
- **96.73% Code Coverage** exceeding industry standards
- **Unit Tests** for all public and private functions
- **Integration Tests** for complete workflows
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
│   └── QA/               # Quality assurance tests
├── output/               # Build artifacts
└── build.ps1             # Build script
```

## 📋 Available Functions

### Public Functions

- `Get-DigitalOceanAccount` - Retrieve account information with pagination support
- `Get-DigitalOceanImage` - Retrieve DigitalOcean images with filtering and  
  pagination support
- `Get-DigitalOceanRegion` - Retrieve DigitalOcean regions with pagination support

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
- [Issue Tracker](https://github.com/Itamartz/PSDigitalOceanUsingSampler/issues)

## 📈 Roadmap

- [ ] Additional DigitalOcean resource support (Droplets, Volumes, etc.)
- [ ] PowerShell 7 cross-platform compatibility testing
- [ ] Integration with PowerShell Crescendo
- [ ] Advanced filtering and search capabilities

---

### Built with ❤️ using PowerShell and the Sampler framework
