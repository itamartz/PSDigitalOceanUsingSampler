# Test code coverage for Remove-DigitalOceanVolume
Import-Module Pester

$config = [PesterConfiguration]::Default
$config.Run.Path = 'tests/Unit/Public/Remove-DigitalOceanVolume.tests.ps1'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = 'output/module/PSDigitalOcean/1.7.0/PSDigitalOcean.psm1'
$config.Output.Verbosity = 'Normal'

$result = Invoke-Pester -Configuration $config

Write-Output "`nCode Coverage Results for Remove-DigitalOceanVolume:"
if ($result.CodeCoverage) {
    Write-Output ("Total Commands Analyzed: {0}" -f $result.CodeCoverage.NumberOfCommandsAnalyzed)
    Write-Output ("Commands Executed: {0}" -f $result.CodeCoverage.NumberOfCommandsExecuted)
    Write-Output ("Commands Missed: {0}" -f $result.CodeCoverage.NumberOfCommandsMissed)
    Write-Output ("Coverage Percentage: {0:F2}%" -f $result.CodeCoverage.CoveredPercent)

    if ($result.CodeCoverage.MissedCommands) {
        Write-Output "`nMissed Commands:"
        $result.CodeCoverage.MissedCommands | ForEach-Object {
            Write-Output ("  Line {0}: {1}" -f $_.Line, $_.Command)
        }
    }
} else {
    Write-Output "No code coverage data available"
}
