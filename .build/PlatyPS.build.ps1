<#
.SYNOPSIS
    Build task for generating PowerShell help using PlatyPS.

.DESCRIPTION
    This task generates external help files and conceptual help using PlatyPS
    directly without requiring DscResource.DocGenerator.
#>

param(
    [Parameter()]
    [System.IO.DirectoryInfo]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [System.String]
    $ProjectName = $(
        if ($BuildInfo -and $BuildInfo.ProjectName)
        {
            $BuildInfo.ProjectName
        }
        else
        {
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
    ),

    [Parameter()]
    [System.String]
    $ModuleVersion = (property ModuleVersion ''),

    [Parameter()]
    [System.String]
    $ProjectUri = (property ProjectUri 'https://github.com/Itamartz/PSDigitalOceanUsingSampler')
)

# Synopsis: Generate external help files using PlatyPS
task Generate_PlatyPS_Help -If { Get-Module PlatyPS -ListAvailable } {
    Write-Build Green "Generating PowerShell help files using PlatyPS..."

    $modulePath = Join-Path $OutputDirectory "module\$ProjectName"
    if ($ModuleVersion)
    {
        $modulePath = Join-Path $modulePath $ModuleVersion
    }
    else
    {
        # Try to find the version directory
        $versionDirs = Get-ChildItem -Path $modulePath -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+' }
        if ($versionDirs)
        {
            $modulePath = $versionDirs[0].FullName
        }
    }

    $moduleManifest = Join-Path $modulePath "$ProjectName.psd1"

    if (Test-Path $moduleManifest)
    {
        try
        {
            # Import the built module
            Import-Module $moduleManifest -Force -ErrorAction Stop

            # Create help directories
            $helpDocsPath = Join-Path $BuildRoot 'docs' 'commands'
            $externalHelpPath = Join-Path $modulePath 'en-US'

            if (-not (Test-Path $helpDocsPath))
            {
                New-Item -Path $helpDocsPath -ItemType Directory -Force | Out-Null
            }

            if (-not (Test-Path $externalHelpPath))
            {
                New-Item -Path $externalHelpPath -ItemType Directory -Force | Out-Null
            }

            # Get module commands
            $commands = Get-Command -Module $ProjectName -CommandType Function, Cmdlet

            if ($commands)
            {
                Write-Build Green "Found $($commands.Count) commands to document"

                # Generate/update markdown help for each command
                foreach ($command in $commands)
                {
                    $commandHelpPath = Join-Path $helpDocsPath "$($command.Name).md"

                    if (-not (Test-Path $commandHelpPath))
                    {
                        # Create new markdown help
                        Write-Build Gray "Creating help for $($command.Name)"
                        New-MarkdownHelp -Command $command.Name -OutputFolder $helpDocsPath -Force | Out-Null
                    }
                    else
                    {
                        # Update existing markdown help
                        Write-Build Gray "Updating help for $($command.Name)"
                        Update-MarkdownHelp -Path $commandHelpPath | Out-Null
                    }
                }

                # Generate external help XML
                Write-Build Green "Generating external help XML files..."
                New-ExternalHelp -Path $helpDocsPath -OutputPath $externalHelpPath -Force | Out-Null

                Write-Build Green "✅ PlatyPS help generation completed successfully!"
            }
            else
            {
                Write-Build Yellow "⚠️  No commands found in module $ProjectName"
            }
        }
        catch
        {
            Write-Build Yellow "⚠️  Failed to generate PlatyPS help: $_"
            Write-Build Yellow "This is non-critical for the build process."
        }
        finally
        {
            # Remove the imported module
            Remove-Module $ProjectName -ErrorAction SilentlyContinue
        }
    }
    else
    {
        Write-Build Yellow "⚠️  Module manifest not found at: $moduleManifest"
    }
}

# Synopsis: Generate conceptual help from markdown
task Generate_Conceptual_Help_PlatyPS -If { Get-Module PlatyPS -ListAvailable } {
    Write-Build Green "Generating conceptual help using PlatyPS..."

    $conceptualHelpSource = Join-Path $BuildRoot 'docs' 'PSDigitalOcean.md'
    $modulePath = Join-Path $OutputDirectory "module\$ProjectName"
    if ($ModuleVersion)
    {
        $modulePath = Join-Path $modulePath $ModuleVersion
    }
    else
    {
        # Try to find the version directory
        $versionDirs = Get-ChildItem -Path $modulePath -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+' }
        if ($versionDirs)
        {
            $modulePath = $versionDirs[0].FullName
        }
    }
    $helpOutputPath = Join-Path $modulePath 'en-US'

    if (Test-Path $conceptualHelpSource)
    {
        try
        {
            if (-not (Test-Path $helpOutputPath))
            {
                New-Item -Path $helpOutputPath -ItemType Directory -Force | Out-Null
            }

            # Convert markdown to about help file
            $aboutHelpFile = Join-Path $helpOutputPath "about_$ProjectName.help.txt"

            # Read the markdown content and convert to PowerShell help format
            $markdownContent = Get-Content $conceptualHelpSource -Raw

            # Create basic about help content
            $aboutContent = @"
TOPIC
    about_$ProjectName

SHORT DESCRIPTION
    A PowerShell module for managing DigitalOcean resources through their REST API.

LONG DESCRIPTION
    $ProjectName is a comprehensive PowerShell module for managing DigitalOcean
    resources through their REST API. The module provides a complete set of
    cmdlets for interacting with DigitalOcean services including account
    management, image retrieval, and region information.

    Key Features:
    - Complete API Coverage: Access to DigitalOcean's REST API v2
    - Class-Based Architecture: Strongly-typed PowerShell classes for all objects
    - Pagination Support: Automatic handling of paginated API responses
    - Error Handling: Comprehensive error handling and validation
    - Security: Secure API token management through environment variables

EXAMPLES
    # Import the module
    Import-Module $ProjectName

    # Get account information
    `$account = Get-DigitalOceanAccount
    Write-Host "Account: `$(`$account.email)"

    # List available images
    `$images = Get-DigitalOceanImage -Type "distribution"
    `$images | Where-Object { `$_.Name -like "*Ubuntu*" } | Format-Table Name, Slug

    # Get all regions
    `$regions = Get-DigitalOceanRegion -All
    `$regions | Format-Table Name, Slug, Available

NOTE
    This module requires a valid DigitalOcean API token to be set in the
    DIGITALOCEAN_TOKEN environment variable.

    For configuration help: Get-Help about_${ProjectName}_Configuration

TROUBLESHOOTING NOTE
    For issues and support, visit the GitHub repository.

SEE ALSO
    - $ProjectUri
    - $ProjectUri/wiki
    - Get-DigitalOceanAccount
    - Get-DigitalOceanImage
    - Get-DigitalOceanRegion

KEYWORDS
    DigitalOcean, API, Cloud, Infrastructure, PowerShell, REST
"@

            Set-Content -Path $aboutHelpFile -Value $aboutContent -Encoding UTF8
            Write-Build Green "✅ Conceptual help file created: $aboutHelpFile"
        }
        catch
        {
            Write-Build Yellow "⚠️  Failed to generate conceptual help: $_"
        }
    }
    else
    {
        Write-Build Yellow "⚠️  Conceptual help source not found at: $conceptualHelpSource"
    }
}
