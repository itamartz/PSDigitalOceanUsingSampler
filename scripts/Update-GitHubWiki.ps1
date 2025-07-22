<#
.SYNOPSIS
    Updates GitHub Wiki pages from local wiki directory.

.DESCRIPTION
    This script helps maintain GitHub Wiki pages by copying content from the
    local wiki directory to the GitHub Wiki repository. It can clone the wiki
    repository, update pages, and push changes.

.PARAMETER WikiUrl
    The GitHub Wiki repository URL (usually ends with .wiki.git)

.PARAMETER LocalWikiPath
    Path to the local wiki directory containing markdown files

.PARAMETER CommitMessage
    Commit message for wiki updates

.EXAMPLE
    .\Update-GitHubWiki.ps1 -WikiUrl "https://github.com/Itamartz/PSDigitalOceanUsingSampler.wiki.git"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$WikiUrl = "https://github.com/Itamartz/PSDigitalOceanUsingSampler.wiki.git",
    
    [string]$LocalWikiPath = ".\wiki",
    
    [string]$CommitMessage = "Update wiki documentation - $(Get-Date -Format 'yyyy-MM-dd')"
)

$ErrorActionPreference = 'Stop'

try {
    Write-Host "🔄 Updating GitHub Wiki..." -ForegroundColor Green
    
    # Create temp directory for wiki repository
    $tempWikiPath = Join-Path $env:TEMP "PSDigitalOcean-wiki-$(Get-Random)"
    Write-Host "📁 Using temporary directory: $tempWikiPath" -ForegroundColor Yellow
    
    # Clone wiki repository
    Write-Host "📥 Cloning wiki repository..." -ForegroundColor Cyan
    git clone $WikiUrl $tempWikiPath
    
    if (-not (Test-Path $tempWikiPath)) {
        throw "Failed to clone wiki repository"
    }
    
    # Copy wiki files from local directory
    Write-Host "📋 Copying wiki files..." -ForegroundColor Cyan
    $wikiFiles = Get-ChildItem -Path $LocalWikiPath -Filter "*.md" -File
    
    foreach ($file in $wikiFiles) {
        $destPath = Join-Path $tempWikiPath $file.Name
        Copy-Item -Path $file.FullName -Destination $destPath -Force
        Write-Host "  ✅ Copied: $($file.Name)" -ForegroundColor Green
    }
    
    # Change to wiki directory and commit changes
    Push-Location $tempWikiPath
    
    try {
        # Add all changes
        git add .
        
        # Check if there are changes to commit
        $status = git status --porcelain
        
        if ($status) {
            Write-Host "💾 Committing changes..." -ForegroundColor Cyan
            git commit -m $CommitMessage
            
            Write-Host "🚀 Pushing to GitHub Wiki..." -ForegroundColor Cyan
            git push origin master
            
            Write-Host "✅ Wiki updated successfully!" -ForegroundColor Green
        } else {
            Write-Host "ℹ️  No changes to commit." -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
    }
    
    # Cleanup
    Write-Host "🧹 Cleaning up temporary files..." -ForegroundColor Yellow
    Remove-Item -Path $tempWikiPath -Recurse -Force
    
    Write-Host "🎉 GitHub Wiki update completed!" -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to update GitHub Wiki: $_"
    
    # Cleanup on error
    if (Test-Path $tempWikiPath) {
        Remove-Item -Path $tempWikiPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    throw
}
