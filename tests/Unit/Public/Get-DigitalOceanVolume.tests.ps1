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
    Context "When retrieving volumes by ID" {
        BeforeEach {
            Mock Invoke-DigitalOceanAPI -ModuleName PSDigitalOcean -MockWith {
                return @{
                    volume = @{
                        id               = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                        name             = "test-volume"
                        description      = "Test volume description"
                        size_gigabytes   = 100
                        region           = @{
                            name = "New York 1"
                            slug = "nyc1"
                        }
                        filesystem_type  = "ext4"
                        filesystem_label = "test-fs"
                        droplet_ids      = @(12345, 67890)
                        created_at       = "2016-03-02T17:00:58Z"
                        status           = "available"
                        tags             = @("production", "database")
                    }
                }
            }
        }

        It "1 - Should retrieve volume by ID successfully" {
            InModuleScope -ModuleName $script:dscModuleName {
                $result = Get-DigitalOceanVolume -VolumeId "506f78a4-e098-11e5-ad9f-000f53306ae1"

                $result | Should -Not -BeNullOrEmpty
                $result.Id | Should -Be "506f78a4-e098-11e5-ad9f-000f53306ae1"
                $result.Name | Should -Be "test-volume"
                $result.SizeGigabytes | Should -Be 100

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq "volumes/506f78a4-e098-11e5-ad9f-000f53306ae1" -and $Method -eq 'GET'
                }
            }
        }

        It "2 - Should handle URL encoding for volume ID" {
            InModuleScope -ModuleName $script:dscModuleName {
                $volumeId = "volume-with-special@chars"
                Get-DigitalOceanVolume -VolumeId $volumeId

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -eq "volumes/volume-with-special%40chars" -and $Method -eq 'GET'
                }
            }
        }

        It "3 - Should handle missing volume response" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{}
                }

                $result = Get-DigitalOceanVolume -VolumeId "non-existent-id"
                $result | Should -BeNullOrEmpty
            }
        }
    }

    Context "When retrieving volumes by name" {
        BeforeEach {
            Mock Invoke-DigitalOceanAPI -ModuleName PSDigitalOcean -MockWith {
                return @{
                    volumes = @(
                        @{
                            id               = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                            name             = "test-volume"
                            description      = "Test volume description"
                            size_gigabytes   = 100
                            region           = @{
                                name = "New York 1"
                                slug = "nyc1"
                            }
                            filesystem_type  = "ext4"
                            filesystem_label = "test-fs"
                            droplet_ids      = @(12345)
                            created_at       = "2016-03-02T17:00:58Z"
                            status           = "available"
                            tags             = @("production")
                        }
                    )
                    links   = @{
                        pages = @{
                            next = $null
                        }
                    }
                    meta    = @{
                        total = 1
                    }
                }
            }
        }

        It "4 - Should retrieve volumes by name successfully" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        volumes = @(
                            @{
                                id               = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                                name             = "test-volume"
                                description      = "Test volume description"
                                size_gigabytes   = 100
                                region           = @{
                                    name = "New York 1"
                                    slug = "nyc1"
                                }
                                filesystem_type  = "ext4"
                                filesystem_label = "test-fs"
                                droplet_ids      = @(12345)
                                created_at       = "2016-03-02T17:00:58Z"
                                status           = "available"
                                tags             = @("production")
                            }
                        )
                        links   = @{
                            pages = @{
                                next = $null
                            }
                        }
                        meta    = @{
                            total = 1
                        }
                    }
                }

                $result = Get-DigitalOceanVolume -VolumeName "test-volume"

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 1
                $result[0].Name | Should -Be "test-volume"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "volumes\?" -and $APIPath -match "name=test-volume" -and $Method -eq 'GET'
                }
            }
        }

        It "5 - Should retrieve volumes by name with region filter" {
            InModuleScope -ModuleName $script:dscModuleName {
                $result = Get-DigitalOceanVolume -VolumeName "test-volume" -Region "nyc1"

                $result | Should -Not -BeNullOrEmpty

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "volumes\?" -and $APIPath -match "name=test-volume" -and $APIPath -match "region=nyc1" -and $Method -eq 'GET'
                }
            }
        }

        It "6 - Should handle URL encoding for volume name" {
            InModuleScope -ModuleName $script:dscModuleName {
                $volumeName = "test volume with spaces"
                Get-DigitalOceanVolume -VolumeName $volumeName

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "name=test%20volume%20with%20spaces" -and $Method -eq 'GET'
                }
            }
        }

        It "7 - Should retrieve all volumes by name when All switch is used" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        volumes = @(
                            @{
                                id              = "vol1"
                                name            = "test-volume"
                                description     = "First volume"
                                size_gigabytes  = 50
                                region          = @{ name = "New York 1"; slug = "nyc1" }
                                filesystem_type = "ext4"
                                droplet_ids     = @()
                                created_at      = "2016-03-02T17:00:58Z"
                                status          = "available"
                                tags            = @()
                            },
                            @{
                                id              = "vol2"
                                name            = "test-volume"
                                description     = "Second volume"
                                size_gigabytes  = 75
                                region          = @{ name = "Frankfurt 1"; slug = "fra1" }
                                filesystem_type = "ext4"
                                droplet_ids     = @()
                                created_at      = "2016-03-02T18:00:58Z"
                                status          = "available"
                                tags            = @()
                            }
                        )
                        links   = @{
                            pages = @{
                                next = $null
                            }
                        }
                        meta    = @{
                            total = 2
                        }
                    }
                }

                $result = Get-DigitalOceanVolume -VolumeName "test-volume" -All

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 2
                $result[0].Name | Should -Be "test-volume"
                $result[1].Name | Should -Be "test-volume"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "volumes\?" -and $APIPath -match "name=test-volume" -and $APIPath -notmatch "page=" -and $Method -eq 'GET'
                }
            }
        }
    }

    Context "When listing volumes with pagination" {
        BeforeEach {
            Mock Invoke-DigitalOceanAPI -ModuleName PSDigitalOcean -MockWith {
                return @{
                    volumes = @(
                        @{
                            id               = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                            name             = "volume-1"
                            description      = "First test volume"
                            size_gigabytes   = 50
                            region           = @{
                                name = "New York 1"
                                slug = "nyc1"
                            }
                            filesystem_type  = "ext4"
                            filesystem_label = "vol1-fs"
                            droplet_ids      = @()
                            created_at       = "2016-03-02T17:00:58Z"
                            status           = "available"
                            tags             = @("test")
                        },
                        @{
                            id               = "606f78a4-e098-11e5-ad9f-000f53306ae2"
                            name             = "volume-2"
                            description      = "Second test volume"
                            size_gigabytes   = 100
                            region           = @{
                                name = "Frankfurt 1"
                                slug = "fra1"
                            }
                            filesystem_type  = "ext4"
                            filesystem_label = "vol2-fs"
                            droplet_ids      = @(12345)
                            created_at       = "2016-03-02T18:00:58Z"
                            status           = "in-use"
                            tags             = @("production", "database")
                        }
                    )
                    links   = @{
                        pages = @{
                            next = $null
                        }
                    }
                    meta    = @{
                        total = 2
                    }
                }
            }
        }

        It "8 - Should list volumes with default pagination" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        volumes = @(
                            @{
                                id               = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                                name             = "volume-1"
                                description      = "First test volume"
                                size_gigabytes   = 50
                                region           = @{
                                    name = "New York 1"
                                    slug = "nyc1"
                                }
                                filesystem_type  = "ext4"
                                filesystem_label = "vol1-fs"
                                droplet_ids      = @()
                                created_at       = "2016-03-02T17:00:58Z"
                                status           = "available"
                                tags             = @("test")
                            },
                            @{
                                id               = "606f78a4-e098-11e5-ad9f-000f53306ae2"
                                name             = "volume-2"
                                description      = "Second test volume"
                                size_gigabytes   = 100
                                region           = @{
                                    name = "Frankfurt 1"
                                    slug = "fra1"
                                }
                                filesystem_type  = "ext4"
                                filesystem_label = "vol2-fs"
                                droplet_ids      = @(12345)
                                created_at       = "2016-03-02T18:00:58Z"
                                status           = "in-use"
                                tags             = @("production", "database")
                            }
                        )
                        links   = @{
                            pages = @{
                                next = $null
                            }
                        }
                        meta    = @{
                            total = 2
                        }
                    }
                }

                $result = Get-DigitalOceanVolume

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 2
                $result[0].Name | Should -Be "volume-1"
                $result[1].Name | Should -Be "volume-2"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "volumes" -and $Method -eq 'GET'
                }
            }
        }

        It "9 - Should list volumes with custom page and limit" {
            InModuleScope -ModuleName $script:dscModuleName {
                $result = Get-DigitalOceanVolume -Page 2 -Limit 25

                $result | Should -Not -BeNullOrEmpty

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "volumes\?" -and $APIPath -match "page=2" -and $APIPath -match "per_page=25" -and $Method -eq 'GET'
                }
            }
        }

        It "10 - Should list volumes filtered by region" {
            InModuleScope -ModuleName $script:dscModuleName {
                $result = Get-DigitalOceanVolume -Region "nyc1"

                $result | Should -Not -BeNullOrEmpty

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "volumes\?" -and $APIPath -match "region=nyc1" -and $Method -eq 'GET'
                }
            }
        }

        It "11 - Should handle URL encoding for region parameter" {
            InModuleScope -ModuleName $script:dscModuleName {
                $region = "region-with-special@chars"
                Get-DigitalOceanVolume -Region $region

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly -ParameterFilter {
                    $APIPath -match "region=region-with-special%40chars" -and $Method -eq 'GET'
                }
            }
        }
    }

    Context "When handling API errors and edge cases" {
        It "12 - Should handle null response from API" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return $null
                }

                $WarningPreference = 'SilentlyContinue'
                $result = Get-DigitalOceanVolume -VolumeId "test-id"
                $result | Should -BeNullOrEmpty

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly
            }
        }

        It "13 - Should handle exception during API call" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    throw "API connection failed"
                }

                { Get-DigitalOceanVolume -VolumeId "test-id" } | Should -Throw "API connection failed"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly
            }
        }

        It "14 - Should handle malformed volume data in response" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        volumes = @(
                            @{
                                id              = "valid-volume"
                                name            = "valid-volume"
                                description     = "Valid volume"
                                size_gigabytes  = 100
                                region          = @{ name = "New York 1"; slug = "nyc1" }
                                filesystem_type = "ext4"
                                droplet_ids     = @()
                                created_at      = "2016-03-02T17:00:58Z"
                                status          = "available"
                                tags            = @()
                            },
                            @{
                                # Malformed volume data (invalid data type that causes exception)
                                id             = "malformed-volume"
                                size_gigabytes = "invalid-size"  # This should cause an error
                                created_at     = "invalid-date"       # This should cause an error
                            }
                        )
                        links   = @{
                            pages = @{
                                next = $null
                            }
                        }
                        meta    = @{
                            total = 2
                        }
                    }
                }

                # Mock Write-Warning to capture that it gets called for malformed data
                Mock Write-Warning

                $result = Get-DigitalOceanVolume

                # Should return only the valid volume, skip the malformed one
                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 1
                $result[0].Id | Should -Be "valid-volume"

                # Verify that a warning was written for the malformed data
                Assert-MockCalled Write-Warning -Times 1 -Exactly

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly
            }
        }

        It "15 - Should handle empty volumes response" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        volumes = @()
                        links   = @{
                            pages = @{
                                next = $null
                            }
                        }
                        meta    = @{
                            total = 0
                        }
                    }
                }

                $result = Get-DigitalOceanVolume

                $result | Should -BeNullOrEmpty

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly
            }
        }

        It "16 - Should handle volumes response without volumes property" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        links = @{
                            pages = @{
                                next = $null
                            }
                        }
                        meta  = @{
                            total = 0
                        }
                    }
                }

                $result = Get-DigitalOceanVolume

                $result | Should -BeNullOrEmpty

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly
            }
        }
    }

    Context "When handling pagination with All parameter" -Skip {
        It "17 - Should fetch all pages when All parameter is used and multiple pages exist" {
            InModuleScope -ModuleName $script:dscModuleName {
                # Use parameter filtering to distinguish between first and second call
                Mock Invoke-DigitalOceanAPI -MockWith {
                    param($APIPath)
                    if ($APIPath -notmatch "page=")
                    {
                        # First call (no page parameter)
                        return @{
                            volumes = @(
                                @{
                                    id              = "volume-page1-1"
                                    name            = "volume-1"
                                    description     = "First volume"
                                    size_gigabytes  = 100
                                    region          = @{ name = "New York 1"; slug = "nyc1" }
                                    filesystem_type = "ext4"
                                    droplet_ids     = @()
                                    created_at      = "2016-03-02T17:00:58Z"
                                    status          = "available"
                                    tags            = @()
                                },
                                @{
                                    id              = "volume-page1-2"
                                    name            = "volume-2"
                                    description     = "Second volume"
                                    size_gigabytes  = 100
                                    region          = @{ name = "New York 1"; slug = "nyc1" }
                                    filesystem_type = "ext4"
                                    droplet_ids     = @()
                                    created_at      = "2016-03-02T18:00:58Z"
                                    status          = "available"
                                    tags            = @()
                                }
                            )
                            links   = @{
                                pages = @{
                                    next = "https://api.digitalocean.com/v2/volumes?page=2"
                                }
                            }
                            meta    = @{
                                total = 3
                            }
                        }
                    }
                    else
                    {
                        # Second call (with page parameter)
                        return @{
                            volumes = @(
                                @{
                                    id              = "volume-page2-1"
                                    name            = "volume-3"
                                    description     = "Third volume"
                                    size_gigabytes  = 100
                                    region          = @{ name = "New York 1"; slug = "nyc1" }
                                    filesystem_type = "ext4"
                                    droplet_ids     = @()
                                    created_at      = "2016-03-02T19:00:58Z"
                                    status          = "available"
                                    tags            = @()
                                }
                            )
                            links   = @{
                                pages = @{
                                    next = $null
                                }
                            }
                            meta    = @{
                                total = 3
                            }
                        }
                    }
                }

                $result = Get-DigitalOceanVolume -All

                $result | Should -Not -BeNullOrEmpty
                $result.Count | Should -Be 3
                $result[0].Name | Should -Be "volume-1"
                $result[1].Name | Should -Be "volume-2"
                $result[2].Name | Should -Be "volume-3"

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 2 -Exactly
            }
        }

        It "18 - Should handle empty result when no volumes found on first page" {
            InModuleScope -ModuleName $script:dscModuleName {
                Mock Invoke-DigitalOceanAPI -MockWith {
                    return @{
                        volumes = @()
                        links   = @{
                            pages = @{
                                next = $null
                            }
                        }
                        meta    = @{
                            total = 0
                        }
                    }
                }

                $result = Get-DigitalOceanVolume -All

                $result | Should -BeNullOrEmpty

                Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -Exactly
            }
        }
    }
}
