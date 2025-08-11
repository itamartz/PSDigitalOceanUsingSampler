BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

Describe 'Remove-DigitalOceanDroplet' {
    Context 'Deletion Scenarios' {
        It '1 - Should delete droplet by ID using correct API path' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { 'test-token' }
                Mock Invoke-DigitalOceanAPI { } -ParameterFilter {
                    $APIPath -eq 'droplets/test-id' -and $Method -eq 'DELETE' -and -not $Parameters
                }

                $result = Remove-DigitalOceanDroplet -DropletId 'test-id' -Force -Confirm:$false

                $result | Should -Be $true
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'droplets/test-id' -and $Method -eq 'DELETE'
                }
            }
        }

        It '2 - Should delete droplets by tag with encoded tag parameter' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { 'test-token' }
                Mock Invoke-DigitalOceanAPI { } -ParameterFilter {
                    $APIPath -eq 'droplets' -and $Method -eq 'DELETE' -and $Parameters.tag_name -eq 'web%20cluster'
                }

                $result = Remove-DigitalOceanDroplet -Tag 'web cluster' -Force -Confirm:$false

                $result | Should -Be $true
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'droplets' -and $Method -eq 'DELETE' -and $Parameters.tag_name -eq 'web%20cluster'
                }
            }
        }
    }

    Context 'Error Scenarios' {
        It '3 - Should throw error when API token is missing' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { throw "DigitalOcean API token is not set. Please set the DIGITALOCEAN_TOKEN environment variable." }

                { Remove-DigitalOceanDroplet -DropletId 'test-id' -Force -Confirm:$false } | Should -Throw "*DigitalOcean API token is not set*"
            }
        }

        It '4 - Should handle API failure and return false' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { 'test-token' }
                Mock Invoke-DigitalOceanAPI { throw "API Error: Server unavailable" }

                $result = Remove-DigitalOceanDroplet -DropletId 'test-id' -Force -Confirm:$false -ErrorAction SilentlyContinue

                $result | Should -Be $false
            }
        }

        It '5 - Should return false when user cancels with WhatIf' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { 'test-token' }
                Mock Invoke-DigitalOceanAPI { }

                $result = Remove-DigitalOceanDroplet -DropletId 'test-id' -WhatIf

                $result | Should -Be $false
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 0
            }
        }

        It '6 - Should handle 404 not found error gracefully' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { 'test-token' }
                Mock Invoke-DigitalOceanAPI { throw "404 Not Found" }

                $result = Remove-DigitalOceanDroplet -DropletId 'non-existent-id' -Force -Confirm:$false -WarningAction SilentlyContinue

                $result | Should -Be $false
            }
        }
    }
}

AfterAll {
    if ($script:originalToken)
    {
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
    }
    else
    {
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $null, [System.EnvironmentVariableTarget]::User)
    }
}
