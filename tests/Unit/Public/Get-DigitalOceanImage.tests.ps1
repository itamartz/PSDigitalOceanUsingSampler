$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'

    # Import the built module from output directory
    $moduleDir = 'c:\Users\Itamartz\Documents\WindowsPowerShell\Modules\PSDigitalOcean\output\module\PSDigitalOcean'
    if (Test-Path $moduleDir)
    {
        Import-Module $moduleDir -Force
    }
    else
    {
        Import-Module -Name $script:dscModuleName
    }

    if ($PSVersionTable.Platform -ne 'Win32NT')
    {
        # For Unix/Linux, read the token from a file in the home directory
        $env:DIGITALOCEAN_TOKEN
    }
    # For Windows, read the token from a file in the Temp directory
    else
    {
        $DIGITALOCEAN_TOKEN = Get-Content -Path 'C:\Temp\DIGITALOCEAN_TOKEN.txt' -ErrorAction SilentlyContinue -Raw
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $DIGITALOCEAN_TOKEN, [System.EnvironmentVariableTarget]::User)
    }
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe -Name $DescribeName {

    Context 'When calling with default parameters (Limit parameter set)' {
        It '1 - Should return images with default page and limit values' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 12345
                            name         = "test-image-1"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu-1"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        },
                        [PSCustomObject]@{
                            id           = 12346
                            name         = "test-image-2"
                            type         = "distribution"
                            distribution = "CentOS"
                            slug         = "test-centos-1"
                            public       = $true
                            regions      = @("nyc1", "lon1")
                            created_at   = "2023-01-02T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 2
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = $null
                            prev  = $null
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI {
                    return $MockResponse
                }

                $result = Get-DigitalOceanImage

                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'images' -and
                    $Parameters.page -eq 1 -and
                    $Parameters.per_page -eq 20 -and
                    $Parameters.ContainsKey('type') -eq $false
                }

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 2
                $result[0].GetType().Name | Should -Be 'DigitalOceanImage'
                $result[1].GetType().Name | Should -Be 'DigitalOceanImage'
            }
        }

        It '2 - Should return images with custom page and limit values' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 12345
                            name         = "test-image-1"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu-1"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        },
                        [PSCustomObject]@{
                            id           = 12346
                            name         = "test-image-2"
                            type         = "distribution"
                            distribution = "CentOS"
                            slug         = "test-centos-1"
                            public       = $true
                            regions      = @("nyc1", "lon1")
                            created_at   = "2023-01-02T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 2
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = $null
                            prev  = $null
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                $result = Get-DigitalOceanImage -Page 2 -Limit 50

                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'images' -and
                    $Parameters.page -eq 2 -and
                    $Parameters.per_page -eq 50 -and
                    $Parameters.ContainsKey('type') -eq $false
                }

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 2
            }
        }

        It '3 - Should filter by application type when Type parameter is specified' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 12345
                            name         = "test-image-1"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu-1"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        },
                        [PSCustomObject]@{
                            id           = 12346
                            name         = "test-image-2"
                            type         = "distribution"
                            distribution = "CentOS"
                            slug         = "test-centos-1"
                            public       = $true
                            regions      = @("nyc1", "lon1")
                            created_at   = "2023-01-02T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 2
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = $null
                            prev  = $null
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                $result = Get-DigitalOceanImage -Type 'application' -Page 1 -Limit 25

                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'images' -and
                    $Parameters.page -eq 1 -and
                    $Parameters.per_page -eq 25 -and
                    $Parameters.type -eq 'application'
                }

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 2
            }
        }

        It '4 - Should filter by distribution type when Type parameter is specified' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 12345
                            name         = "test-image-1"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu-1"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 1
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = $null
                            prev  = $null
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                $result = Get-DigitalOceanImage -Type 'distribution'

                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'images' -and
                    $Parameters.type -eq 'distribution'
                }

                $result | Should -Not -BeNullOrEmpty
            }
        }

        It '5 - Should handle empty Type parameter correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 12345
                            name         = "test-image-1"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu-1"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 1
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = $null
                            prev  = $null
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                $result = Get-DigitalOceanImage -Type ''

                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'images' -and
                    $Parameters.ContainsKey('type') -eq $false
                }

                $result | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'When calling with All parameter (All parameter set)' {
        It '6 - Should return all images from single page' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 12345
                            name         = "test-image-1"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu-1"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        },
                        [PSCustomObject]@{
                            id           = 12346
                            name         = "test-image-2"
                            type         = "distribution"
                            distribution = "CentOS"
                            slug         = "test-centos-1"
                            public       = $true
                            regions      = @("nyc1", "lon1")
                            created_at   = "2023-01-02T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 2
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = $null
                            prev  = $null
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                $result = Get-DigitalOceanImage -All

                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $APIPath -eq 'images' -and
                    $Parameters.page -eq 1 -and
                    $Parameters.per_page -eq 20
                }

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 2
                $result[0].GetType().Name | Should -Be 'DigitalOceanImage'
                $result[1].GetType().Name | Should -Be 'DigitalOceanImage'
            }
        }

        It '7 - Should return all images from multiple pages' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockFirstPageResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 11111
                            name         = "first-page-image"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "first-ubuntu"
                            public       = $true
                            regions      = @("nyc1")
                            created_at   = "2023-01-01T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 3
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = "https://api.digitalocean.com/v2/images?page=2&per_page=20"
                            prev  = $null
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=2&per_page=20"
                        }
                    }
                }

                $MockSecondPageResponse = [PSCustomObject]@{
                    images = @(
                        [PSCustomObject]@{
                            id           = 22222
                            name         = "second-page-image-1"
                            type         = "distribution"
                            distribution = "CentOS"
                            slug         = "second-centos"
                            public       = $true
                            regions      = @("sfo1")
                            created_at   = "2023-01-02T00:00:00Z"
                        },
                        [PSCustomObject]@{
                            id           = 33333
                            name         = "second-page-image-2"
                            type         = "application"
                            distribution = "Debian"
                            slug         = "second-debian"
                            public       = $false
                            regions      = @("lon1")
                            created_at   = "2023-01-03T00:00:00Z"
                        }
                    )
                    meta   = [PSCustomObject]@{
                        total = 3
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next  = $null
                            prev  = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            first = "https://api.digitalocean.com/v2/images?page=1&per_page=20"
                            last  = "https://api.digitalocean.com/v2/images?page=2&per_page=20"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI {
                    if ($Parameters.page -eq 1)
                    {
                        return $MockFirstPageResponse
                    }
                    else
                    {
                        return $MockSecondPageResponse
                    }
                }

                $result = Get-DigitalOceanImage -All

                Should -Invoke Invoke-DigitalOceanAPI -Times 2
                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 1 -and $Parameters.per_page -eq 20
                }
                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 2 -and $Parameters.per_page -eq 20
                }

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 3
                $result[0].Id | Should -Be 11111
                $result[1].Id | Should -Be 22222
                $result[2].Id | Should -Be 33333

                # Verify all results are DigitalOceanImage objects
                foreach ($image in $result)
                {
                    $image.GetType().Name | Should -Be 'DigitalOceanImage'
                }
            }
        }

        It '8 - Should handle pagination with different per_page values in next URL' {
            InModuleScope -ModuleName $script:dscModuleName {
                $mockFirstPageCustom = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 1
                            name = "test"
                        })
                    meta   = [PSCustomObject]@{
                        total = 2
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next = "https://api.digitalocean.com/v2/images?page=2&per_page=15"
                        }
                    }
                }

                $mockSecondPageCustom = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 2
                            name = "test2"
                        })
                    meta   = [PSCustomObject]@{
                        total = 2
                    }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next = $null
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI {
                    if ($Parameters.page -eq 1)
                    {
                        return $mockFirstPageCustom
                    }
                    else
                    {
                        return $mockSecondPageCustom
                    }
                }

                $result = Get-DigitalOceanImage -All

                Should -Invoke Invoke-DigitalOceanAPI -Times 2
                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 1 -and $Parameters.per_page -eq 20
                }
                Should -Invoke Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 2 -and $Parameters.per_page -eq 15
                }

                $result.Count | Should -Be 2
            }
        }

        It '9 - Should handle malformed next URL gracefully' {
            InModuleScope -ModuleName $script:dscModuleName {
                $mockMalformedResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{ id = 1; name = "test" })
                    meta   = [PSCustomObject]@{ total = 2 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next = "https://api.digitalocean.com/v2/images?invalid_format"
                        }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $mockMalformedResponse }

                $result = Get-DigitalOceanImage -All

                Should -Invoke Invoke-DigitalOceanAPI -Times 1
                $result.Count | Should -Be 1
            }
        }
    }

    Context 'When testing parameter validation' {
        It '10 - Should accept valid Type values' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 1
                            name = "test"
                        })
                    meta   = [PSCustomObject]@{ total = 1 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                { Get-DigitalOceanImage -Type 'application' } | Should -Not -Throw
                { Get-DigitalOceanImage -Type 'distribution' } | Should -Not -Throw
            }
        }

        It '11 - Should accept valid Page range values' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 1
                            name = "test"
                        })
                    meta   = [PSCustomObject]@{ total = 1 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                { Get-DigitalOceanImage -Page 1 } | Should -Not -Throw
                { Get-DigitalOceanImage -Page 500 } | Should -Not -Throw
                { Get-DigitalOceanImage -Page 1000 } | Should -Not -Throw
            }
        }

        It '12 - Should accept valid Limit range values' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 1
                            name = "test"
                        })
                    meta   = [PSCustomObject]@{ total = 1 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                { Get-DigitalOceanImage -Limit 20 } | Should -Not -Throw
                { Get-DigitalOceanImage -Limit 100 } | Should -Not -Throw
                { Get-DigitalOceanImage -Limit 200 } | Should -Not -Throw
            }
        }
    }

    Context 'When testing edge cases and error handling' {
        It '14 - Should handle null response from API' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI { return $null }

                { Get-DigitalOceanImage } | Should -Throw
            }
        }

        It '15 - Should handle missing images property in response' {
            InModuleScope -ModuleName $script:dscModuleName {
                $invalidResponse = [PSCustomObject]@{
                    meta = [PSCustomObject]@{ total = 0 }
                }

                Mock Invoke-DigitalOceanAPI { return $invalidResponse }

                { Get-DigitalOceanImage } | Should -Throw
            }
        }

        It '16 - Should handle API errors correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI { throw "API Error: Unauthorized" }

                { Get-DigitalOceanImage } | Should -Throw "API Error: Unauthorized"
            }
        }
    }

    Context 'When testing verbose output' {
        It '17 - Should write verbose messages when getting all images' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 1
                            name = "test"
                        })
                    meta   = [PSCustomObject]@{ total = 2 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }
                Mock Write-Verbose { }

                Get-DigitalOceanImage -All -Verbose

                Should -Invoke Write-Verbose -Times 1 -ParameterFilter {
                    $Message -eq "about to get all images from DigitalOcean"
                }
                Should -Invoke Write-Verbose -Times 1 -ParameterFilter {
                    $Message -eq "Page: 1, PerPage: 20"
                }
                Should -Invoke Write-Verbose -Times 1 -ParameterFilter {
                    $Message -eq "DigitalOcean total images is 2"
                }
                Should -Invoke Write-Verbose -Times 1 -ParameterFilter {
                    $Message -eq "finished getting all images"
                }
            }
        }

        It '18 - Should write verbose messages for pagination' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockFirstPageResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 1
                            name = "test"
                        })
                    meta   = [PSCustomObject]@{ total = 3 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next = "https://api.digitalocean.com/v2/images?page=2&per_page=20"
                        }
                    }
                }

                $MockSecondPageResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 2
                            name = "test2"
                        })
                    meta   = [PSCustomObject]@{ total = 3 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI {
                    if ($Parameters.page -eq 1)
                    {
                        return $MockFirstPageResponse
                    }
                    else
                    {
                        return $MockSecondPageResponse
                    }
                }
                Mock Write-Verbose { }

                Get-DigitalOceanImage -All -Verbose

                Should -Invoke Write-Verbose -Times 1 -ParameterFilter {
                    $Message -eq "Page: 2, PerPage: 20"
                }
            }
        }
    }

    Context 'When testing parameter set behavior' {
        It '19 - Should use Limit parameter set by default' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 1
                            name = "test"
                        })
                    meta   = [PSCustomObject]@{ total = 2 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                # This should use the Limit parameter set
                $result = Get-DigitalOceanImage

                Should -Invoke Invoke-DigitalOceanAPI -Times 1
                $result.Count | Should -Be 1
            }
        }

        It '20 - Should not allow mixing All with other parameters' {
            # This test validates that parameter sets work correctly
            # All parameter should be in its own parameter set
            { Get-DigitalOceanImage -All -Page 2 } | Should -Throw
            { Get-DigitalOceanImage -All -Limit 50 } | Should -Throw
            { Get-DigitalOceanImage -All -Type 'application' } | Should -Throw
        }
    }

    Context 'When testing object type assignment and class properties' {
        It '22 - Should return DigitalOceanImage objects from All parameter' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockFirstPageResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 11111
                            name = "first-page-image"
                        })
                    meta   = [PSCustomObject]@{ total = 3 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{
                            next = "https://api.digitalocean.com/v2/images?page=2&per_page=20"
                        }
                    }
                }

                $MockSecondPageResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id   = 22222
                            name = "second-page-image"
                        })
                    meta   = [PSCustomObject]@{ total = 3 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI {
                    if ($Parameters.page -eq 1)
                    {
                        return $MockFirstPageResponse
                    }
                    else
                    {
                        return $MockSecondPageResponse
                    }
                }

                $result = Get-DigitalOceanImage -All

                foreach ($image in $result)
                {
                    $image.GetType().Name | Should -Be 'DigitalOceanImage'
                    $image.Id | Should -BeOfType [int]
                    $image.Name | Should -Not -BeNullOrEmpty
                }
            }
        }

        It '23 - Should have working ToString method on returned objects' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id           = 12345
                            name         = "test-image"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        })
                    meta   = [PSCustomObject]@{ total = 1 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                $result = Get-DigitalOceanImage

                $result[0].ToString() | Should -Match "DigitalOceanImage:.*ID:.*Type:"
            }
        }

        It '24 - Should have working ToHashtable method on returned objects' {
            InModuleScope -ModuleName $script:dscModuleName {
                $MockResponse = [PSCustomObject]@{
                    images = @([PSCustomObject]@{
                            id           = 12345
                            name         = "test-image"
                            type         = "application"
                            distribution = "Ubuntu"
                            slug         = "test-ubuntu"
                            public       = $true
                            regions      = @("nyc1", "sfo1")
                            created_at   = "2023-01-01T00:00:00Z"
                        })
                    meta   = [PSCustomObject]@{ total = 1 }
                    links  = [PSCustomObject]@{
                        pages = [PSCustomObject]@{ next = $null }
                    }
                }

                Mock Invoke-DigitalOceanAPI { return $MockResponse }

                $result = Get-DigitalOceanImage

                $hashtable = $result[0].ToHashtable()
                $hashtable | Should -BeOfType [hashtable]
                $hashtable.ContainsKey('Id') | Should -Be $true
                $hashtable.ContainsKey('Name') | Should -Be $true
                $hashtable.ContainsKey('Type') | Should -Be $true
            }
        }
    }

    Context 'Missing Line Coverage Tests for Get-DigitalOceanImage' {

        It '25 - Should throw when API returns null response with All parameter (line 79)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock API to return null specifically for -All parameter set (line 79)
                Mock Invoke-DigitalOceanAPI { return $null }

                # This should trigger the throw on line 79 in the All parameter set
                { Get-DigitalOceanImage -All } | Should -Throw "*Invalid or null response from API*"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 1 -and $Parameters.per_page -eq 20
                }
            }
        }

        It '26 - Should throw when API returns response without images property with All parameter (line 79)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock API to return response without images property specifically for -All parameter set
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        meta = [PSCustomObject]@{ total = 0 }
                        # Missing images property entirely
                    }
                }

                # This should trigger the throw on line 79 in the All parameter set
                { Get-DigitalOceanImage -All } | Should -Throw "*Invalid or null response from API*"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 1 -and $Parameters.per_page -eq 20
                }
            }
        }

        It '27 - Should throw when API returns response with null images property with All parameter (line 79)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock API to return response with null images property specifically for -All parameter set
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        images = $null
                        meta = [PSCustomObject]@{ total = 0 }
                    }
                }

                # This should trigger the throw on line 79 in the All parameter set
                { Get-DigitalOceanImage -All } | Should -Throw "*Invalid or null response from API*"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 1 -and $Parameters.per_page -eq 20
                }
            }
        }

        It '28 - Should cover empty array output when AllImages count is 0 with All parameter (line 129)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock API to return valid response but with empty images array for -All parameter set
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        images = @()  # Empty but valid array
                        meta = [PSCustomObject]@{ total = 0 }
                        links = [PSCustomObject]@{
                            pages = [PSCustomObject]@{
                                # No next property - single page with no results
                            }
                        }
                    }
                }

                # This should trigger the empty array output on line 129
                $result = Get-DigitalOceanImage -All

                $result | Should -BeNullOrEmpty
                $result.Count | Should -Be 0

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 1 -and $Parameters.per_page -eq 20
                }
            }
        }

        It '29 - Should cover empty array output when AllImages count is 0 with Limit parameter (line 167)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock API to return valid response but with empty images array for Limit parameter set
                Mock Invoke-DigitalOceanAPI {
                    return [PSCustomObject]@{
                        images = @()  # Empty but valid array
                        meta = [PSCustomObject]@{ total = 0 }
                    }
                }

                # This should trigger the empty array output on line 167
                $result = Get-DigitalOceanImage -Page 1 -Limit 20

                $result | Should -BeNullOrEmpty
                $result.Count | Should -Be 0

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                    $Parameters.page -eq 1 -and $Parameters.per_page -eq 20
                }
            }
        }
    }
}
