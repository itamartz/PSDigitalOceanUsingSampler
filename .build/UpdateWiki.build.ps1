<#
.SYNOPSIS
    Build task for updating GitHub Wiki documentation.

.DESCRIPTION
    This task is part of the Sampler build framework and updates the GitHub Wiki
    with the latest documentation from the local wiki directory.
#>

param(
    [Parameter()]
    [System.IO.DirectoryInfo]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [System.String]
    $WikiUrl = (property WikiUrl 'https://github.com/Itamartz/PSDigitalOceanUsingSampler.wiki.git'),

    [Parameter()]
    [System.String]
    $ProjectName = $(
        # Get the project name from build configuration first, or fallback to manifest detection
        if ($BuildInfo -and $BuildInfo.ProjectName) {
            $BuildInfo.ProjectName
        } else {
            # Get the project name from the build root directory
            (Get-ChildItem -Path $BuildRoot -Filter '*.psd1' | Where-Object {
                ($_.Directory.Name -match 'Source|Src' -or $_.Directory.Name -eq $_.BaseName) -and
                $(try
                    {
                        Test-ModuleManifest -Path $_.FullName -ErrorAction Stop; $true
                    }
                    catch
                    {
                        $false
                    })
            } | Select-Object -First 1).BaseName
        }
    )
)

# Synopsis: Updates the GitHub Wiki with latest documentation
task UpdateWiki -If { $env:GITHUB_TOKEN -and (Test-Path (Join-Path $BuildRoot 'wiki')) } {
    Write-Build Green "Updating GitHub Wiki documentation..."

    $wikiPath = Join-Path $BuildRoot 'wiki'
    $scriptPath = Join-Path $BuildRoot 'scripts' 'Update-GitHubWiki.ps1'

    if (Test-Path $scriptPath)
    {
        try
        {
            & $scriptPath -WikiUrl $WikiUrl -LocalWikiPath $wikiPath -CommitMessage "Auto-update wiki for $ProjectName v$(if($ModuleVersion){$ModuleVersion}else{'latest'})"
            Write-Build Green "✅ GitHub Wiki updated successfully!"
        }
        catch
        {
            Write-Build Yellow "⚠️  Failed to update GitHub Wiki: $_"
            Write-Build Yellow "This is non-critical for the build process."
        }
    }
    else
    {
        Write-Build Yellow "⚠️  Wiki update script not found at: $scriptPath"
    }
}
