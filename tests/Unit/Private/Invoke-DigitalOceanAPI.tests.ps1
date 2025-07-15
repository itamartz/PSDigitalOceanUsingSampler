$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force

    # Store original token for restoration
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    # Restore original token
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe -Name $DescribeName {
    Context 'Invoke-DigitalOceanAPI Parameter Validation' {

        It '1 - Should throw when APIPath is not provided' {
            InModuleScope -ModuleName $script:dscModuleName {
                { Invoke-DigitalOceanAPI -APIPath $null } | Should -Throw
            }
        }

        It '2 - Should accept valid APIPath parameter' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Set a valid token for this test
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)

                # Mock Invoke-RestMethod to avoid actual API calls
                Mock Invoke-RestMethod { return @{ test = "response" } }

                { Invoke-DigitalOceanAPI -APIPath 'account' } | Should -Not -Throw

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '3 - Should use default APIVersion when not specified' {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)

                Mock Invoke-RestMethod { return @{ test = "response" } }

                Invoke-DigitalOceanAPI -APIPath 'account'

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "https://api.digitalocean.com/v2/account"
                } -Times 1
            }
        }

        It '4 - Should accept custom APIVersion' {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)

                Mock Invoke-RestMethod { return @{ test = "response" } }

                Invoke-DigitalOceanAPI -APIPath 'account' -APIVersion 'v1'

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "https://api.digitalocean.com/v1/account"
                } -Times 1
            }
        }

        It '5 - Should use default GET method when not specified' {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)

                Mock Invoke-RestMethod { return @{ test = "response" } }

                Invoke-DigitalOceanAPI -APIPath 'account'

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Method -eq "GET"
                } -Times 1
            }
        }

        It '6 - Should accept different HTTP methods' {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)

                Mock Invoke-RestMethod { return @{ test = "response" } }

                'POST', 'PUT', 'DELETE', 'PATCH' | ForEach-Object {
                    Invoke-DigitalOceanAPI -APIPath 'droplets' -Method $_
                    Assert-MockCalled Invoke-RestMethod -ParameterFilter { $Method -eq $_ } -Times 1
                }
            }
        }
    }

    Context 'Authentication Token Handling' {

        It '7 - Should throw when DIGITALOCEAN_TOKEN is not set' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Clear the environment variable
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $null, [System.EnvironmentVariableTarget]::User)

                { Invoke-DigitalOceanAPI -APIPath 'account' } | Should -Throw "*DigitalOcean API token is not set*"
            }
        }

        It '8 - Should throw when DIGITALOCEAN_TOKEN is empty string' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Set empty string token
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "", [System.EnvironmentVariableTarget]::User)

                { Invoke-DigitalOceanAPI -APIPath 'account' } | Should -Throw "*DigitalOcean API token is not set*"
            }
        }

        It '9 - Should include Bearer token in Authorization header' {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "my-test-token", [System.EnvironmentVariableTarget]::User)

                Mock Invoke-RestMethod { return @{ test = "response" } }

                Invoke-DigitalOceanAPI -APIPath 'account'

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Headers["Authorization"] -eq "Bearer my-test-token" -and
                    $Headers["Content-Type"] -eq "application/json"
                } -Times 1
            }
        }
    }

    Context 'URL Construction' {

        BeforeEach {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
                Mock Invoke-RestMethod { return @{ test = "response" } }
            }
        }

        It '10 - Should construct URL without query parameters when Parameters is null' {
            InModuleScope -ModuleName $script:dscModuleName {
                Invoke-DigitalOceanAPI -APIPath 'droplets' -APIVersion 'v2'

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "https://api.digitalocean.com/v2/droplets"
                } -Times 1
            }
        }

        It '11 - Should construct URL without query parameters when Parameters is empty hashtable' {
            InModuleScope -ModuleName $script:dscModuleName {
                Invoke-DigitalOceanAPI -APIPath 'droplets' -Parameters @{}

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "https://api.digitalocean.com/v2/droplets"
                } -Times 1
            }
        }

        It '12 - Should construct URL with single query parameter' {
            InModuleScope -ModuleName $script:dscModuleName {
                $params = @{ page = 1 }
                Invoke-DigitalOceanAPI -APIPath 'droplets' -Parameters $params

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "https://api.digitalocean.com/v2/droplets?page=1"
                } -Times 1
            }
        }

        It '13 - Should construct URL with multiple query parameters' {
            InModuleScope -ModuleName $script:dscModuleName {
                $params = @{ page = 2; per_page = 20; tag_name = "test" }
                Invoke-DigitalOceanAPI -APIPath 'droplets' -Parameters $params

                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -like "https://api.digitalocean.com/v2/droplets?*" -and
                    $Uri -like "*page=2*" -and
                    $Uri -like "*per_page=20*" -and
                    $Uri -like "*tag_name=test*"
                } -Times 1
            }
        }

        # It '14 - Should URL encode parameter values with special characters' {
        #     InModuleScope -ModuleName $script:dscModuleName {
        #         [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)

        #         Mock Invoke-RestMethod { return @{ result = "mocked" } }

        #         $params = @{
        #             name = "test droplet with spaces"
        #             tag  = "env:production"
        #         }

        #         $null = Invoke-DigitalOceanAPI -APIPath 'droplets' -Parameters $params

        #         Assert-MockCalled Invoke-RestMethod -Times 1 -ModuleName $script:dscModuleName -ParameterFilter {
        #             $Uri -like "*tag=env%3Aproduction*" -and
        #             $Uri -like "*name=test%20droplet%20with%20spaces*"
        #         }
        #     }
        # }
    }

    Context 'API Response Handling' {

        BeforeEach {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
            }
        }

        It '15 - Should return response from Invoke-RestMethod' {
            InModuleScope -ModuleName $script:dscModuleName {
                $expectedResponse = @{
                    account = @{
                        email  = "test@example.com"
                        status = "active"
                    }
                }
                Mock Invoke-RestMethod { return $expectedResponse }

                $result = Invoke-DigitalOceanAPI -APIPath 'account'

                $result | Should -Be $expectedResponse
                $result.account.email | Should -Be "test@example.com"
            }
        }

        It '16 - Should return empty response when API returns null' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-RestMethod { return $null }

                $result = Invoke-DigitalOceanAPI -APIPath 'account'

                $result | Should -BeNullOrEmpty
            }
        }
    }

    Context 'Verbose Output' {

        It '17 - Should write verbose output with URI' {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
                Mock Invoke-RestMethod { return @{ test = "response" } }
                Mock Write-Verbose { }

                Invoke-DigitalOceanAPI -APIPath 'account' -Verbose

                Assert-MockCalled Write-Verbose -ParameterFilter {
                    $Message -like "*about to run https://api.digitalocean.com/v2/account*"
                } -Times 1
            }
        }
    }

    Context 'Integration Scenarios' {

        BeforeEach {
            InModuleScope -ModuleName $script:dscModuleName {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
            }
        }

        It '18 - Should handle complex parameter combinations' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-RestMethod { return @{ droplets = @() } }

                $params = @{
                    page     = 1
                    per_page = 50
                    tag_name = "production"
                    name     = "web-server"
                }

                $result = Invoke-DigitalOceanAPI -APIPath 'droplets' -APIVersion 'v2' -Method 'GET' -Parameters $params

                $result | Should -Not -BeNullOrEmpty
                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '19 - Should work with different API endpoints' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-RestMethod { return @{ images = @() } }

                'account', 'droplets', 'images', 'volumes', 'snapshots' | ForEach-Object {
                    Invoke-DigitalOceanAPI -APIPath $_
                    Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                        $Uri -eq "https://api.digitalocean.com/v2/$_"
                    } -Times 1
                }
            }
        }
    }
}
