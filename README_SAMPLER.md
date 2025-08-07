# How to add function to this module

## Create a Class file for the response and put the file in source\Classes

## Add Function to source\Public folder - and use the Class in your Return Object

## Create test file with the name of the <functionName>.tests.ps1 in tests\Public\
## add this in the start of the tests 
```powershell
$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force

    # Store original token for restoration
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

    # Set a test token for tests
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    # Restore original token
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe -Name $DescribeName {

}
```

## Create at least 85 % Code Coverage tests

## Version Update Methods - GitVersion-Based

```bash
### For patch version bump (1.0.0 → 1.0.1)
git commit -m "fix: resolve API timeout issue"

# For minor version bump (1.1.0 → 1.2.0)  
git commit -m "feature: add support for Droplet management"

# For major version bump (1.0.0 → 2.0.0)
git commit -m "breaking change: remove deprecated functions"

# To skip version bump
git commit -m "docs: update README +semver: skip"
```

## Publishing to PowerShell Gallery

### Method 1: Manual Publishing (Recommended for First-Time)

#### Step 1: Get PowerShell Gallery API Key
1. Go to [PowerShell Gallery](https://www.powershellgallery.com/)
2. Sign in with your Microsoft account
3. Go to your profile → **API Keys**
4. Create a new API key with these permissions:
   - **Push new packages and package versions**
   - **Unlist packages**
5. Copy the API key (you'll only see it once)

#### Step 2: Set Environment Variable
```powershell
# Replace "your-api-key-here" with your actual API key
[Environment]::SetEnvironmentVariable("GalleryApiToken", "your-api-key-here", [System.EnvironmentVariableTarget]::User)
```

#### Step 3: Build and Publish
```powershell
# Build the module first
.\build.ps1 -AutoRestore -Tasks build

# Publish to PowerShell Gallery
.\build.ps1 -Tasks publish
```

### Method 2: Automated Publishing via Azure Pipelines

Your module is configured for automatic publishing when:
- You push to the `main` branch OR create a version tag
- All tests pass
- You have these variables set in Azure DevOps:

#### Required Azure DevOps Variables:
1. **GalleryApiToken** - Your PowerShell Gallery API key
2. **GitHubToken** - GitHub personal access token (for releases)

#### To Set Azure DevOps Variables:
1. Go to your Azure DevOps project
2. Pipelines → Library → Variable groups
3. Create variables:
   - `GalleryApiToken` (mark as secret)
   - `GitHubToken` (mark as secret)

#### Publishing Workflow:
```powershell
# Option A: Tag-based release
git tag v1.2.0
git push origin v1.2.0

# Option B: Direct push to main (after PR merge)
git push origin main
```

### Method 3: Direct PowerShell Commands

```powershell
# Build the module
.\build.ps1 -AutoRestore -Tasks build

# Manual publish using PowerShellGet
$modulePath = ".\output\module\PSDigitalOcean\*"
Publish-Module -Path $modulePath -NuGetApiKey "your-api-key" -Repository PSGallery
```

### Publish to PowerShell Gallery

```powershell
$GalleryApiToken = '<TOKEN>'
$modulePath = Get-ChildItem `
    ".\output\module\PSDigitalOcean\*\PSDigitalOcean.psd1" `
    | Select-Object -First 1
Publish-Module -Path $modulePath.DirectoryName `
    -NuGetApiKey $GalleryApiToken `
    -Repository PSGallery
```

### Pre-Publishing Checklist

Before publishing, ensure:

- [ ] Module version is incremented
- [ ] CHANGELOG.md is updated
- [ ] All tests pass (85%+ coverage)
- [ ] Module manifest is valid
- [ ] README.md badges are updated

```powershell
# Run full test suite
.\build.ps1 -AutoRestore -Tasks test

# Validate module manifest
Test-ModuleManifest ".\output\module\PSDigitalOcean\*\PSDigitalOcean.psd1"
```

### Post-Publishing Steps

1. **Verify on PowerShell Gallery**: Check your module appears at https://www.powershellgallery.com/packages/PSDigitalOcean
2. **Test Installation**: `Install-Module PSDigitalOcean -Force`
3. **Update README badges**: Update download/version badges
4. **Create GitHub Release**: Tag the version in GitHub

### Troubleshooting

**Common Issues:**
- **API Key Invalid**: Regenerate key on PowerShell Gallery
- **Version Already Exists**: Increment version number
- **Module Dependencies**: Ensure all dependencies are available on PSGallery
- **Manifest Errors**: Run `Test-ModuleManifest` to validate

**Check Module Status:**
```powershell
# Check if module published successfully
Find-Module PSDigitalOcean -AllVersions
```
