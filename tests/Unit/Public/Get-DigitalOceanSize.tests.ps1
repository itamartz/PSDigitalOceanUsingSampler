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

Describe $DescribeName {
    Context "When using parameter set 'Limit'" {
        BeforeAll {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        sizes = @(
                            [PSCustomObject]@{
                                slug          = 's-1vcpu-1gb'
                                memory        = 1024
                                vcpus         = 1
                                disk          = 25
                                transfer      = 1
                                price_monthly = 5.0
                                price_hourly  = 0.00744
                                regions       = @('nyc1', 'nyc2', 'nyc3')
                                available     = $true
                                description   = 'Basic'
                            },
                            [PSCustomObject]@{
                                slug          = 's-2vcpu-2gb'
                                memory        = 2048
                                vcpus         = 2
                                disk          = 50
                                transfer      = 2
                                price_monthly = 12.0
                                price_hourly  = 0.01786
                                regions       = @('nyc1', 'nyc2', 'nyc3')
                                available     = $true
                                description   = 'Regular'
                            }
                        )
                        meta  = [PSCustomObject]@{
                            total = 2
                        }
                    }
                }
            }
        }

        It "1 - Should call Invoke-DigitalOceanAPI with correct APIPath and default parameters" {
            InModuleScope $script:dscModuleName {
                $result = Get-DigitalOceanSize
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq 'sizes' -and
                    $Parameters.page -eq 1 -and
                    $Parameters.per_page -eq 20
                }
            }
        }

        It "2 - Should call Invoke-DigitalOceanAPI with custom Page and Limit parameters" {
            InModuleScope $script:dscModuleName {
                $result = Get-DigitalOceanSize -Page 2 -Limit 50
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq 'sizes' -and
                    $Parameters.page -eq 2 -and
                    $Parameters.per_page -eq 50
                }
            }
        }

        It "3 - Should return DigitalOceanSize objects with correct properties" {
            InModuleScope $script:dscModuleName {
                $result = Get-DigitalOceanSize
                $result | Should -HaveCount 2
                $result[0].PSObject.TypeNames[0] | Should -Be 'DigitalOceanSize'
                $result[0].Slug | Should -Be 's-1vcpu-1gb'
                $result[0].Memory | Should -Be 1024
                $result[0].Vcpus | Should -Be 1
                $result[1].PSObject.TypeNames[0] | Should -Be 'DigitalOceanSize'
                $result[1].Slug | Should -Be 's-2vcpu-2gb'
                $result[1].Memory | Should -Be 2048
                $result[1].Vcpus | Should -Be 2
            }
        }

        It "4 - Should return empty array when no sizes data received" {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        sizes = @()
                        meta  = [PSCustomObject]@{
                            total = 0
                        }
                    }
                }
                $result = Get-DigitalOceanSize
                $result | Should -HaveCount 0
            }
        }

        It "5 - Should throw when sizes property is missing" {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        meta = [PSCustomObject]@{
                            total = 0
                        }
                    }
                }
                { Get-DigitalOceanSize } | Should -Throw "*Invalid or null response from API*"
            }
        }
    }

    Context "When using parameter set 'All'" {
        BeforeAll {
            InModuleScope $script:dscModuleName {
                $script:callCount = 0
                Mock Invoke-DigitalOceanAPI {
                    $script:callCount++
                    if ($script:callCount -eq 1)
                    {
                        return [PSCustomObject]@{
                            sizes = @(
                                [PSCustomObject]@{
                                    slug          = 's-1vcpu-1gb'
                                    memory        = 1024
                                    vcpus         = 1
                                    disk          = 25
                                    transfer      = 1
                                    price_monthly = 5.0
                                    price_hourly  = 0.00744
                                    regions       = @('nyc1', 'nyc2', 'nyc3')
                                    available     = $true
                                    description   = 'Basic'
                                }
                            )
                            meta  = [PSCustomObject]@{
                                total = 2
                            }
                            links = [PSCustomObject]@{
                                pages = [PSCustomObject]@{
                                    next = 'https://api.digitalocean.com/v2/sizes?page=2&per_page=20'
                                }
                            }
                        }
                    }
                    else
                    {
                        return [PSCustomObject]@{
                            sizes = @(
                                [PSCustomObject]@{
                                    slug          = 's-2vcpu-2gb'
                                    memory        = 2048
                                    vcpus         = 2
                                    disk          = 50
                                    transfer      = 2
                                    price_monthly = 12.0
                                    price_hourly  = 0.01786
                                    regions       = @('nyc1', 'nyc2', 'nyc3')
                                    available     = $true
                                    description   = 'Regular'
                                }
                            )
                            meta  = [PSCustomObject]@{
                                total = 2
                            }
                            links = [PSCustomObject]@{
                                pages = [PSCustomObject]@{}
                            }
                        }
                    }
                }
            }
        }

        It "6 - Should retrieve all sizes across multiple pages" {
            InModuleScope $script:dscModuleName {
                $script:callCount = 0
                $result = Get-DigitalOceanSize -All
                $result | Should -HaveCount 2
                $result[0].Slug | Should -Be 's-1vcpu-1gb'
                $result[1].Slug | Should -Be 's-2vcpu-2gb'
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 2 -Exactly
            }
        }

        It "7 - Should handle pagination URL parsing correctly" {
            InModuleScope $script:dscModuleName {
                $script:callCount = 0
                $result = Get-DigitalOceanSize -All
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq 'sizes' -and
                    $Parameters.page -eq 1 -and
                    $Parameters.per_page -eq 20
                }
                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq 'sizes' -and
                    $Parameters.page -eq 2 -and
                    $Parameters.per_page -eq 20
                }
            }
        }

        It "8 - Should return empty array when All parameter used but no data received" {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        sizes = @()
                        meta  = [PSCustomObject]@{
                            total = 0
                        }
                        links = [PSCustomObject]@{
                            pages = [PSCustomObject]@{}
                        }
                    }
                }
                $result = Get-DigitalOceanSize -All
                $result | Should -HaveCount 0
            }
        }
    }

    Context "When testing DigitalOceanSize class methods" {
        BeforeAll {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        sizes = @(
                            [PSCustomObject]@{
                                slug          = 's-1vcpu-1gb'
                                memory        = 1024
                                vcpus         = 1
                                disk          = 25
                                transfer      = 1
                                price_monthly = 5.0
                                price_hourly  = 0.00744
                                regions       = @('nyc1', 'nyc2', 'nyc3')
                                available     = $true
                                description   = 'Basic'
                            }
                        )
                        meta  = [PSCustomObject]@{
                            total = 1
                        }
                    }
                }
            }
        }

        It "9 - Should create DigitalOceanSize object with ToString method" {
            InModuleScope $script:dscModuleName {
                $result = Get-DigitalOceanSize
                $result[0].ToString() | Should -Be 's-1vcpu-1gb'
            }
        }
    }

    Context "When testing parameter validation" {
        It "10 - Should validate Page parameter range" {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        sizes = @()
                        meta  = [PSCustomObject]@{ total = 0 }
                    }
                }
                { Get-DigitalOceanSize -Page 0 } | Should -Throw
                { Get-DigitalOceanSize -Page 1001 } | Should -Throw
                { Get-DigitalOceanSize -Page 1 } | Should -Not -Throw
                { Get-DigitalOceanSize -Page 1000 } | Should -Not -Throw
            }
        }

        It "11 - Should validate Limit parameter range" {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        sizes = @()
                        meta  = [PSCustomObject]@{ total = 0 }
                    }
                }
                { Get-DigitalOceanSize -Limit 19 } | Should -Throw
                { Get-DigitalOceanSize -Limit 201 } | Should -Throw
                { Get-DigitalOceanSize -Limit 20 } | Should -Not -Throw
                { Get-DigitalOceanSize -Limit 200 } | Should -Not -Throw
            }
        }

        It "12 - Should not allow Page/Limit with All parameter" {
            { Get-DigitalOceanSize -All -Page 1 } | Should -Throw
            { Get-DigitalOceanSize -All -Limit 20 } | Should -Throw
        }
    }

    Context "When testing edge cases and error handling" {
        It "13 - Should handle API errors during operations" {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    throw "API Error: Rate limit exceeded"
                }
                { Get-DigitalOceanSize } | Should -Throw "*API Error: Rate limit exceeded*"
            }
        }

        It "14 - Should handle sizes with null or missing properties" {
            InModuleScope $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        sizes = @(
                            [PSCustomObject]@{
                                slug   = 's-incomplete'
                                memory = $null
                                vcpus  = 1
                                # Missing other properties
                            }
                        )
                        meta  = [PSCustomObject]@{
                            total = 1
                        }
                    }
                }
                $result = Get-DigitalOceanSize
                $result | Should -HaveCount 1
                $result[0].Slug | Should -Be 's-incomplete'
                $result[0].Memory | Should -Be 0  # Should handle null gracefully
            }
        }
    }
}
