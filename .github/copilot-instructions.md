# PSDigitalOcean Module Development Guide

## Architecture Overview

This is a PowerShell module for DigitalOcean API integration built with the **Sampler framework**. The module follows enterprise-grade practices with class-based architecture, comprehensive testing, and modern CI/CD patterns.

when you create a ps1 file make sure to check the psscript analyzer rules and the pester tests before committing.

### Key Components

- **Classes** (`source/Classes/`): PowerShell classes for strongly-typed objects (Account, Image, Team, etc.)
- **Public Functions** (`source/Public/`): Exported cmdlets like `Get-DigitalOceanAccount`, `Get-DigitalOceanImage`
- **Private Functions** (`source/Private/`): Internal helpers like `Invoke-DigitalOceanAPI`, `Get-DigitalOceanAPIAuthorizationBearerToken`
- **API Client**: Uses `Invoke-RestMethod` with Bearer token authentication via `DIGITALOCEAN_TOKEN` environment variable

## Development Workflows

### Build System (Sampler Framework)

```powershell
# Install dependencies and build
.\build.ps1 -AutoRestore -Tasks build

# Run all tests
.\build.ps1 -Tasks test

# Build + test in one command
.\build.ps1 -AutoRestore
```

**Important**: The source PSM1 file is intentionally empty - it gets built by ModuleBuilder during the build process.

### Testing Standards

- **Target**: 90%+ code coverage with numbered test names (`1 - Should...`, `2 - Should...`)
- **Structure**: Use `InModuleScope` for private function testing, extensive mocking with `Mock` and `Assert-MockCalled`
- **Setup Pattern**: All tests use this standardized BeforeAll block:

```powershell
$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]
BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}
```

## Project-Specific Patterns

### Class Naming Convention

Classes use numbered prefixes for build order: `1.class1.ps1`, `2.class2.ps1`, `5.DigitalOceanImage.ps1`.
This ensures proper dependency resolution during module compilation.

### API Integration Pattern

- All API calls go through `Invoke-DigitalOceanAPI` private function
- URL encoding handled with `[uri]::EscapeDataString()` for parameters
- Bearer token authentication with error handling for missing tokens
- Functions return strongly-typed class objects, not raw PSObjects

### Help Documentation Requirements

- Synopsis, Description (40+ chars), Examples required for all public functions
- Parameter descriptions must be 25+ characters
- QA tests enforce these standards automatically

### PowerShell 5.1 Compatibility

- Avoid null-coalescing operators (`??`) - use traditional null checks
- Use `Write-Output` for proper array handling in return statements
- Test coverage includes PowerShell 5.1 compatibility validation

## Key Files to Reference

- `build.yaml`: ModuleBuilder configuration with encoding and copy paths
- `RequiredModules.psd1`: Build dependencies (Pester, PSScriptAnalyzer, Sampler, etc.)
- `tests/QA/module.tests.ps1`: Quality gates for help documentation and PSScriptAnalyzer compliance

## Github Instructions

- **Issue Tracking**: Use GitHub Issues for bug reports and feature requests
- **Commit Messages**: Follow conventional commit standards for clarity, ensure README file update with code coverage and test counts
