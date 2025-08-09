#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Publishes PSDigitalOcean module to PowerShell Gallery
.DESCRIPTION
    This script simplifies publishing the PSDigitalOcean module to PowerShell Gallery
    by handling common issues and providing clear error messages.
.PARAMETER ApiKey
    PowerShell Gallery API Key. Get from https://www.powershellgallery.com/account/apikeys
.PARAMETER WhatIf
    Shows what would happen without actually publishing
.PARAMETER Force
    Forces publication even if version already exists
.EXAMPLE
    .\Publish-PSDigitalOcean.ps1 -ApiKey "your-api-key-here"
.EXAMPLE
    .\Publish-PSDigitalOcean.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ApiKey,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Define base paths
$BaseModulePath = "C:\Users\Itamartz\Documents\WindowsPowerShell\Modules\PSDigitalOcean\output\module\PSDigitalOcean"

# Find the latest version directory
Write-Host "🔍 Finding latest module version..." -ForegroundColor Yellow
$versionDirs = Get-ChildItem -Path $BaseModulePath -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' }
if (-not $versionDirs) {
    Write-Error "No version directories found in $BaseModulePath"
    Write-Host "💡 Run .\build.ps1 -AutoRestore -Tasks build first" -ForegroundColor Magenta
    exit 1
}

$latestVersion = ($versionDirs | Sort-Object { [Version]$_.Name } -Descending)[0]
$ModulePath = $latestVersion.FullName
$ManifestPath = Join-Path $ModulePath "PSDigitalOcean.psd1"

Write-Host "🚀 PSDigitalOcean Publisher - Dynamic Version Finder" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Step 1: Validate module path exists and show detected version
Write-Host "📁 Checking module path..." -ForegroundColor Yellow
Write-Host "🔍 Detected version: $($latestVersion.Name)" -ForegroundColor Cyan
Write-Host "📂 Module path: $ModulePath" -ForegroundColor Cyan

if (-not (Test-Path $ModulePath)) {
    Write-Error "Module path not found: $ModulePath"
    Write-Host "💡 Run .\build.ps1 -AutoRestore -Tasks build first" -ForegroundColor Magenta
    exit 1
}
Write-Host "✅ Module path found" -ForegroundColor Green

# Step 2: Validate manifest
Write-Host "📋 Validating module manifest..." -ForegroundColor Yellow
try {
    $manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
    Write-Host "✅ Manifest valid - Version: $($manifest.Version)" -ForegroundColor Green
} catch {
    Write-Error "Manifest validation failed: $($_.Exception.Message)"
    exit 1
}

# Step 3: Check current versions in gallery
Write-Host "🔍 Checking PowerShell Gallery versions..." -ForegroundColor Yellow
try {
    $existingVersions = Find-Module -Name PSDigitalOcean -Repository PSGallery -AllVersions -ErrorAction SilentlyContinue
    if ($existingVersions) {
        $latestVersion = ($existingVersions | Sort-Object Version -Descending)[0].Version
        Write-Host "📦 Latest version in gallery: $latestVersion" -ForegroundColor Cyan

        if ($latestVersion -ge $manifest.Version -and -not $Force) {
            Write-Warning "Version $($manifest.Version) is not greater than existing version $latestVersion"
            Write-Host "💡 Use -Force to override or increment the version" -ForegroundColor Magenta
            exit 1
        }
    } else {
        Write-Host "📦 No existing versions found in gallery" -ForegroundColor Cyan
    }
} catch {
    Write-Warning "Could not check existing versions: $($_.Exception.Message)"
}

# Step 4: Get API key if not provided
if (-not $ApiKey -and -not $WhatIfPreference) {
    Write-Host "🔑 API Key required for publishing" -ForegroundColor Yellow
    Write-Host "Get your API key from: https://www.powershellgallery.com/account/apikeys" -ForegroundColor Cyan

    # Try to get API key securely
    try {
        $secureApiKey = Read-Host -Prompt "Enter your PowerShell Gallery API Key" -AsSecureString
        $ApiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureApiKey))
    } catch {
        Write-Error "Failed to get API key: $($_.Exception.Message)"
        exit 1
    }
}

# Step 5: Prepare publish parameters
$publishParams = @{
    Path = $ModulePath
    Repository = 'PSGallery'
    Verbose = $true
}

# Check which publish command is available and use appropriate parameter name
$publishCommand = 'Publish-Module'
if (Get-Command 'Publish-PSResource' -ErrorAction SilentlyContinue) {
    $publishCommand = 'Publish-PSResource'
    if ($ApiKey) { $publishParams.ApiKey = $ApiKey }
} else {
    # For older PowerShell versions, use NuGetApiKey parameter
    if ($ApiKey) { $publishParams.NuGetApiKey = $ApiKey }
}

if ($WhatIfPreference) {
    $publishParams.WhatIf = $true
}

# Step 6: Publish
Write-Host "📤 Publishing to PowerShell Gallery using $publishCommand..." -ForegroundColor Yellow
Write-Host "Module: PSDigitalOcean v$($manifest.Version)" -ForegroundColor Cyan
Write-Host "Path: $ModulePath" -ForegroundColor Cyan

try {
    if ($WhatIfPreference) {
        Write-Host "🔍 Running in WhatIf mode..." -ForegroundColor Magenta
    }

    & $publishCommand @publishParams

    if (-not $WhatIfPreference) {
        Write-Host ""
        Write-Host "🎉 SUCCESS! PSDigitalOcean v$($manifest.Version) published!" -ForegroundColor Green
        Write-Host "=================================" -ForegroundColor Green
        Write-Host "📦 Installation command:" -ForegroundColor Cyan
        Write-Host "Install-Module -Name PSDigitalOcean -RequiredVersion $($manifest.Version)" -ForegroundColor White
        Write-Host ""
        Write-Host "🔍 Verify publication:" -ForegroundColor Cyan
        Write-Host "Find-Module -Name PSDigitalOcean -Repository PSGallery" -ForegroundColor White
        Write-Host ""
        Write-Host "⏰ Note: It may take a few minutes for the new version to appear in search results." -ForegroundColor Yellow
    } else {
        Write-Host "✅ WhatIf completed successfully" -ForegroundColor Green
    }

} catch {
    Write-Host ""
    Write-Error "❌ Publication failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "🔧 Common solutions:" -ForegroundColor Yellow
    Write-Host "- Verify your API key is correct and has push permissions" -ForegroundColor Cyan
    Write-Host "- Check if the version already exists (use -Force to override)" -ForegroundColor Cyan
    Write-Host "- Ensure you have internet connectivity to PowerShell Gallery" -ForegroundColor Cyan
    Write-Host "- Try running: Get-PSRepository PSGallery" -ForegroundColor Cyan
    exit 1
}
