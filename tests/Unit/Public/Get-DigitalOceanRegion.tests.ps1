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
    Context 'When using parameter set "Limit"' {
        It '1 - Should call Invoke-DigitalOceanAPI with correct APIPath and parameters for default values' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'New York 1'
                                slug      = 'nyc1'
                                features  = @('virtio', 'private_networking', 'backups')
                                available = $true
                                sizes     = @('s-1vcpu-1gb', 's-1vcpu-2gb')
                            }
                        )
                        meta    = @{ total = 1 }
                        links   = @{ pages = @{} }
                    }
                }

                Get-DigitalOceanRegion

                Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq 'regions' -and
                    $Parameters.page -eq 1 -and
                    $Parameters.per_page -eq 20
                }
            }
        }

        It '2 - Should call Invoke-DigitalOceanAPI with custom Page and Limit parameters' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @()
                        meta    = @{ total = 0 }
                        links   = @{ pages = @{} }
                    }
                }

                Get-DigitalOceanRegion -Page 3 -Limit 50

                Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq 'regions' -and
                    $Parameters.page -eq 3 -and
                    $Parameters.per_page -eq 50
                }
            }
        }

        It '3 - Should return DigitalOceanRegion objects with correct properties' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'London 1'
                                slug      = 'lon1'
                                features  = @('virtio', 'private_networking')
                                available = $true
                                sizes     = @('s-1vcpu-1gb', 's-2vcpu-2gb')
                            },
                            @{
                                name      = 'Frankfurt 1'
                                slug      = 'fra1'
                                features  = @('virtio')
                                available = $false
                                sizes     = @('s-1vcpu-1gb')
                            }
                        )
                        meta    = @{ total = 2 }
                        links   = @{ pages = @{} }
                    }
                }

                $result = Get-DigitalOceanRegion -Page 1 -Limit 25

                $result | Should -HaveCount 2
                $result[0].GetType().Name | Should -Be 'DigitalOceanRegion'
                $result[0].Name | Should -Be 'London 1'
                $result[0].Slug | Should -Be 'lon1'
                $result[0].Features | Should -Contain 'virtio'
                $result[0].Available | Should -Be $true
                $result[0].Sizes | Should -Contain 's-1vcpu-1gb'

                $result[1].GetType().Name | Should -Be 'DigitalOceanRegion'
                $result[1].Name | Should -Be 'Frankfurt 1'
                $result[1].Available | Should -Be $false
            }
        }

        It '4 - Should return empty array when no regions data received' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return $null
                }

                Mock Write-Warning

                $result = Get-DigitalOceanRegion

                $result | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
                    $Message -like "*No regions data received*"
                }
            }
        }

        It '5 - Should return empty array when regions property is missing' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        meta  = @{ total = 0 }
                        links = @{ pages = @{} }
                    }
                }

                Mock Write-Warning

                $result = Get-DigitalOceanRegion

                $result | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly
            }
        }

        It '6 - Should write verbose messages for single page retrieval' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'Test Region'
                                slug      = 'test1'
                                features  = @()
                                available = $true
                                sizes     = @()
                            }
                        )
                        meta    = @{ total = 1 }
                        links   = @{ pages = @{} }
                    }
                }

                Mock Write-Verbose

                Get-DigitalOceanRegion -Page 2 -Limit 30 -Verbose

                Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                    $Message -like "*Retrieving regions - Page: 2, Limit: 30*"
                }
                Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                    $Message -like "*Retrieved 1 regions for page 2*"
                }
            }
        }
    }

    Context 'When using parameter set "All"' {
        It '7 - Should retrieve all regions across multiple pages' {
            InModuleScope -ModuleName $script:dscModuleName {
                $script:callCount = 0
                Mock Invoke-DigitalOceanAPI -MockWith {
                    $script:callCount++
                    if ($script:callCount -eq 1)
                    {
                        return @{
                            regions = @(
                                @{
                                    name      = 'Region 1'
                                    slug      = 'reg1'
                                    features  = @()
                                    available = $true
                                    sizes     = @()
                                }
                            )
                            meta    = @{ total = 3 }
                            links   = @{
                                pages = @{
                                    next = 'https://api.digitalocean.com/v2/regions?page=2&per_page=1'
                                }
                            }
                        }
                    }
                    elseif ($script:callCount -eq 2)
                    {
                        return @{
                            regions = @(
                                @{
                                    name      = 'Region 2'
                                    slug      = 'reg2'
                                    features  = @()
                                    available = $true
                                    sizes     = @()
                                }
                            )
                            meta    = @{ total = 3 }
                            links   = @{
                                pages = @{
                                    next = 'https://api.digitalocean.com/v2/regions?page=3&per_page=1'
                                }
                            }
                        }
                    }
                    else
                    {
                        return @{
                            regions = @(
                                @{
                                    name      = 'Region 3'
                                    slug      = 'reg3'
                                    features  = @()
                                    available = $true
                                    sizes     = @()
                                }
                            )
                            meta    = @{ total = 3 }
                            links   = @{
                                pages = @{}
                            }
                        }
                    }
                }

                $result = Get-DigitalOceanRegion -All

                $result | Should -HaveCount 3
                $result[0].Name | Should -Be 'Region 1'
                $result[1].Name | Should -Be 'Region 2'
                $result[2].Name | Should -Be 'Region 3'
                Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Times 3 -Exactly
            }
        }

        It '8 - Should handle pagination URL parsing correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                $script:receivedParams = @()
                Mock Invoke-DigitalOceanAPI -MockWith {
                    $script:receivedParams += $Parameters
                    if ($Parameters.page -eq 1)
                    {
                        return @{
                            regions = @(
                                @{
                                    name      = 'First Region'
                                    slug      = 'first'
                                    features  = @()
                                    available = $true
                                    sizes     = @()
                                }
                            )
                            meta    = @{ total = 2 }
                            links   = @{
                                pages = @{
                                    next = 'https://api.digitalocean.com/v2/regions?page=2&per_page=25'
                                }
                            }
                        }
                    }
                    else
                    {
                        return @{
                            regions = @(
                                @{
                                    name      = 'Second Region'
                                    slug      = 'second'
                                    features  = @()
                                    available = $true
                                    sizes     = @()
                                }
                            )
                            meta    = @{ total = 2 }
                            links   = @{
                                pages = @{}
                            }
                        }
                    }
                }

                $result = Get-DigitalOceanRegion -All

                $script:receivedParams[0].page | Should -Be 1
                $script:receivedParams[0].per_page | Should -Be 20
                $script:receivedParams[1].page | Should -Be '2'
                $script:receivedParams[1].per_page | Should -Be '25'
                $result | Should -HaveCount 2
            }
        }

        It '9 - Should stop pagination when malformed next URL is encountered' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'Only Region'
                                slug      = 'only'
                                features  = @()
                                available = $true
                                sizes     = @()
                            }
                        )
                        meta    = @{ total = 10 }
                        links   = @{
                            pages = @{
                                next = 'malformed-url-without-query-params'
                            }
                        }
                    }
                }

                $result = Get-DigitalOceanRegion -All

                $result | Should -HaveCount 1
                $result[0].Name | Should -Be 'Only Region'
                Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Times 1 -Exactly
            }
        }

        It '10 - Should handle null response during pagination gracefully' {
            InModuleScope -ModuleName $script:dscModuleName {
                $script:callCount = 0
                Mock Invoke-DigitalOceanAPI -MockWith {
                    $script:callCount++
                    if ($script:callCount -eq 1)
                    {
                        return @{
                            regions = @(
                                @{
                                    name      = 'First Region'
                                    slug      = 'first'
                                    features  = @()
                                    available = $true
                                    sizes     = @()
                                }
                            )
                            meta    = @{ total = 2 }
                            links   = @{
                                pages = @{
                                    next = 'https://api.digitalocean.com/v2/regions?page=2&per_page=20'
                                }
                            }
                        }
                    }
                    else
                    {
                        return $null
                    }
                }

                $result = Get-DigitalOceanRegion -All

                $result | Should -HaveCount 1
                $result[0].Name | Should -Be 'First Region'
                Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Times 2 -Exactly
            }
        }

        It '11 - Should write verbose messages for multi-page retrieval' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'Test Region'
                                slug      = 'test'
                                features  = @()
                                available = $true
                                sizes     = @()
                            }
                        )
                        meta    = @{ total = 1 }
                        links   = @{ pages = @{} }
                    }
                }

                Mock Write-Verbose

                Get-DigitalOceanRegion -All -Verbose

                Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                    $Message -like "*Retrieving all regions from DigitalOcean API*"
                }
                Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                    $Message -like "*Starting with Page: 1, PerPage: 20*"
                }
                Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                    $Message -like "*DigitalOcean reports total of 1 regions available*"
                }
                Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                    $Message -like "*Successfully retrieved 1 regions*"
                }
            }
        }

        It '12 - Should return empty array when All parameter used but no data received' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return $null
                }

                Mock Write-Warning

                $result = Get-DigitalOceanRegion -All

                $result | Should -BeNullOrEmpty
                Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
                    $Message -like "*No regions data received from DigitalOcean API*"
                }
            }
        }
    }

    Context 'When testing DigitalOceanRegion class methods' {
        It '13 - Should create DigitalOceanRegion object with ToString method' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'San Francisco 2'
                                slug      = 'sfo2'
                                features  = @('virtio', 'private_networking', 'backups', 'ipv6')
                                available = $true
                                sizes     = @('s-1vcpu-1gb', 's-1vcpu-2gb', 's-2vcpu-2gb')
                            }
                        )
                        meta    = @{ total = 1 }
                        links   = @{ pages = @{} }
                    }
                }

                $result = Get-DigitalOceanRegion

                $result[0].ToString() | Should -Be 'San Francisco 2 (sfo2) - Available: True'
            }
        }

        It '14 - Should create DigitalOceanRegion object with ToHashtable method' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'Toronto 1'
                                slug      = 'tor1'
                                features  = @('virtio', 'private_networking')
                                available = $false
                                sizes     = @('s-1vcpu-1gb')
                            }
                        )
                        meta    = @{ total = 1 }
                        links   = @{ pages = @{} }
                    }
                }

                $result = Get-DigitalOceanRegion

                $hashtable = $result[0].ToHashtable()
                $hashtable.Name | Should -Be 'Toronto 1'
                $hashtable.Slug | Should -Be 'tor1'
                $hashtable.Features | Should -Contain 'virtio'
                $hashtable.Available | Should -Be $false
                $hashtable.Sizes | Should -Contain 's-1vcpu-1gb'
            }
        }
    }

    Context 'When testing parameter validation' {
        It '15 - Should validate Page parameter range' {
            { Get-DigitalOceanRegion -Page 0 } | Should -Throw
            { Get-DigitalOceanRegion -Page 1001 } | Should -Throw
        }

        It '16 - Should validate Limit parameter range' {
            { Get-DigitalOceanRegion -Limit 19 } | Should -Throw
            { Get-DigitalOceanRegion -Limit 201 } | Should -Throw
        }

        It '17 - Should not allow Page/Limit with All parameter' {
            { Get-DigitalOceanRegion -All -Page 1 } | Should -Throw
            { Get-DigitalOceanRegion -All -Limit 20 } | Should -Throw
        }
    }

    Context 'When testing edge cases and error handling' {
        It '18 - Should handle empty regions array gracefully' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @()
                        meta    = @{ total = 0 }
                        links   = @{ pages = @{} }
                    }
                }

                $result = Get-DigitalOceanRegion

                $result | Should -BeNullOrEmpty
            }
        }

        It '19 - Should handle regions with null or missing properties' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        regions = @(
                            @{
                                name      = 'Partial Region'
                                slug      = 'partial'
                                features  = $null
                                available = $true
                                sizes     = $null
                            }
                        )
                        meta    = @{ total = 1 }
                        links   = @{ pages = @{} }
                    }
                }

                $result = Get-DigitalOceanRegion

                $result | Should -HaveCount 1
                $result[0].Name | Should -Be 'Partial Region'
                $result[0].Features | Should -BeNullOrEmpty
                $result[0].Sizes | Should -BeNullOrEmpty
            }
        }

        It '20 - Should handle API errors during pagination' {
            InModuleScope -ModuleName $script:dscModuleName {
                $script:callCount = 0
                Mock Invoke-DigitalOceanAPI -MockWith {
                    $script:callCount++
                    if ($script:callCount -eq 1)
                    {
                        return @{
                            regions = @(
                                @{
                                    name      = 'First Region'
                                    slug      = 'first'
                                    features  = @()
                                    available = $true
                                    sizes     = @()
                                }
                            )
                            meta    = @{ total = 2 }
                            links   = @{
                                pages = @{
                                    next = 'https://api.digitalocean.com/v2/regions?page=2&per_page=20'
                                }
                            }
                        }
                    }
                    else
                    {
                        throw "API Error"
                    }
                }

                # Should throw when API error occurs during pagination
                { Get-DigitalOceanRegion -All } | Should -Throw "API Error"
            }
        }
    }
}
