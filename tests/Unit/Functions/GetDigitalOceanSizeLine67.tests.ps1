$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
}

InModuleScope $script:dscModuleName {
    Describe 'Get-DigitalOceanSize Line 67 Coverage' {
        Context 'API error handling line 67' {
            It '1 - Should throw when API returns null response (line 67)' {
                # Mock Invoke-DigitalOceanAPI to return null, triggering line 67
                Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                    return $null
                }

                # This should trigger the specific line 67: throw "Invalid or null response from API"
                { Get-DigitalOceanSize } | Should -Throw -ExpectedMessage "*Invalid or null response from API*"

                # Verify the mock was called
                Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Exactly 1
            }
        }
    }
}
