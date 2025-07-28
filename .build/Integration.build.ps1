# Custom build task for integration tests
param(
    [Parameter()]
    [String]
    $ProjectName = (property ProjectName ''),

    [Parameter()]
    [String]
    $SourcePath = (property SourcePath ''),

    [Parameter()]
    [String]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [String]
    $BuiltModuleSubdirectory = (property BuiltModuleSubdirectory ''),

    [Parameter()]
    [String]
    $ModuleVersion = (property ModuleVersion ''),

    [Parameter()]
    [String]
    $ModuleManifestPath = (property ModuleManifestPath ''),

    [Parameter()]
    [String]
    $ModuleOutputPath = (property ModuleOutputPath ''),

    [Parameter()]
    [String]
    $PSModulePath = $env:PSModulePath
)

# Synopsis: Run Pester integration tests
task Pester_Integration_Tests {
    Write-Build DarkGray "Running integration tests..."

    # Check if integration tests should be skipped
    $skipIntegration = $false
    $digitalOceanToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

    if (-not $digitalOceanToken -or $digitalOceanToken -eq "test-token") {
        Write-Build Yellow "No valid DigitalOcean API token found - skipping integration tests"
        Write-Build Yellow "Set DIGITALOCEAN_TOKEN environment variable to run integration tests"
        $skipIntegration = $true
    }

    if ($skipIntegration) {
        Write-Build Green "Integration tests skipped - no valid API token available"
        return
    }

    # Import required modules
    Import-Module -Name Pester -Force

    # Get integration test configuration
    $integrationConfig = $BuildInfo.PesterIntegration
    if (-not $integrationConfig) {
        Write-Build Yellow "No PesterIntegration configuration found, using defaults"
        $integrationConfig = @{
            Script = @('tests/Integration')
            Tag = @('Integration')
            OutputFormat = 'NUnitXML'
        }
    }

    # Set up test paths
    $testResultsPath = Join-Path $OutputDirectory 'testResults'
    if (-not (Test-Path $testResultsPath)) {
        New-Item -Path $testResultsPath -ItemType Directory -Force
    }

    $testOutputFile = Join-Path $testResultsPath "Integration_$ProjectName.xml"

    # Configure Pester
    $pesterConfiguration = [PesterConfiguration]::Default
    $pesterConfiguration.Run.Path = $integrationConfig.Script
    $pesterConfiguration.Run.PassThru = $true

    if ($integrationConfig.Tag) {
        $pesterConfiguration.Filter.Tag = $integrationConfig.Tag
    }

    if ($integrationConfig.ExcludeTag) {
        $pesterConfiguration.Filter.ExcludeTag = $integrationConfig.ExcludeTag
    }

    # Set output configuration
    $pesterConfiguration.TestResult.Enabled = $true
    $pesterConfiguration.TestResult.OutputPath = $testOutputFile
    $pesterConfiguration.TestResult.OutputFormat = $integrationConfig.OutputFormat

    # Disable code coverage for integration tests
    $pesterConfiguration.CodeCoverage.Enabled = $false

    # Set verbosity
    $pesterConfiguration.Output.Verbosity = 'Detailed'

    Write-Build Green "Running integration tests with configuration:"
    Write-Build Gray "  Test Path: $($integrationConfig.Script -join ', ')"
    Write-Build Gray "  Output File: $testOutputFile"
    Write-Build Gray "  Tags: $($integrationConfig.Tag -join ', ')"

    # Run tests
    $testResults = Invoke-Pester -Configuration $pesterConfiguration

    # Report results
    Write-Build Green "Integration test results:"
    Write-Build Gray "  Total: $($testResults.TotalCount)"
    Write-Build Gray "  Passed: $($testResults.PassedCount)"
    Write-Build Gray "  Failed: $($testResults.FailedCount)"
    Write-Build Gray "  Skipped: $($testResults.SkippedCount)"

    if ($testResults.FailedCount -gt 0) {
        Write-Build Red "Integration tests failed!"
        throw "Integration tests failed with $($testResults.FailedCount) failures"
    }

    Write-Build Green "All integration tests passed!"
}
