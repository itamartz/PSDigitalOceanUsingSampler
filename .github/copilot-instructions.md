# PSDigitalOcean Module Development Guide

## Architecture Overview

This is a PowerShell module for DigitalOcean API integration built with the **Sampler framework**. The module follows enterprise-grade practices with class-based architecture, comprehensive testing, and modern CI/CD patterns.

when you create a ps1 file make sure to check the file using PSScriptAnalyzer rules and the Pester tests before committing.

When we create a new function make sure to add the function to the `source/Public/` folder and update the `source/PSDigitalOcean.psd1` file with the new function name and description, and update the `wiki/Home.md` file with the new function name and description, and create a new wiki page for the new function in the `wiki` folder.

Before we commit the Wiki we need to check that date is correct in the `wiki/Home.md` file.

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
- When function have more than 4 parameters, use splatting in example for better readability
- Use `-WhatIf` and `-Confirm` parameters for destructive actions

## Key Files to Reference

- `build.yaml`: ModuleBuilder configuration with encoding and copy paths
- `RequiredModules.psd1`: Build dependencies (Pester, PSScriptAnalyzer, Sampler, etc.)
- `tests/QA/module.tests.ps1`: Quality gates for help documentation and PSScriptAnalyzer compliance

## Github Instructions

- **Issue Tracking**: Use GitHub Issues for bug reports and feature requests
- **Commit Messages**: Follow conventional commit standards for clarity, ensure README file update with code coverage and test counts

## PSSScriptAnalyzer and Pester

New function instructions:

- create a new git branch for the new function with version update
- create a new ps1 file in the `source/Public/` folder with the function name
- use `Pester` for unit testing with at least 90% code coverage, add tests one by one and build the module between tests until you reach the coverage
- Use `PSScriptAnalyzer` to enforce coding standards
- Use `PSScriptAnalyzer` 'should not have the open brace on the same line as the statement.'
- Use `PSScriptAnalyzer` 'should not use the `Write-Host` cmdlet.'
- Use `PSScriptAnalyzer` 'Line has trailing whitespace.'

## Integration Testing Requirements

**CRITICAL**: Functions that are NOT GET functions (Create, Update, Delete operations) MUST be tested with real API calls:

- **Unit Tests**: Use mocking for code coverage and parameter validation
- **Integration Tests**: Test non-GET functions with real DigitalOcean API calls using actual tokens, create a test file in `tests/Integration/` folder.
- **Real API Validation**: Before committing any New-, Set-, Remove-, or other mutating functions, test with actual API endpoints
- **Test Environment**: Use test/development DigitalOcean account for integration testing to avoid affecting production resources
- **Error Validation**: Verify that real API error responses are handled correctly, not just mocked error scenarios
- **WhatIf vs Real**: Ensure WhatIf validation matches actual API requirements - test both scenarios

This prevents publishing functions that pass all unit tests but fail with real API calls due to parameter formatting, validation differences, or API requirement mismatches.

# Configuration Guide for PSDigitalOcean Module

After we run .\build.ps1 (-AutoRestore) and it pass we doing the following:

- run code coverage tests and update the `README.md` file with the new code coverage and test counts
- find where we have a date in markdown files and update it to the current date
- create a new wiki page for the new function in the `wiki` folder.
- update the version number in the `source/PSDigitalOcean.psd1` file.
- update the `CHANGELOG.md` file with the new version number and changes.
- update the `wiki/Configuration.md` file with the new version number.
- create a new tag in the format `v1.0.0` (or whatever the new version is) and push it to the remote repository.
- update the wiki in github using the script in `scripts\Update-GitHubWiki.ps1`.
