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

InModuleScope 'PSDigitalOcean' {
    Describe 'DigitalOceanVolume' {
        Context 'Type creation' {
            It '1 - Should create DigitalOceanVolume type' {
                { [DigitalOceanVolume] } | Should -Not -Throw
            }
        }

        Context 'Default constructor' {
            It '2 - Should create instance with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume | Should -Not -BeNullOrEmpty
                $volume.GetType().Name | Should -Be 'DigitalOceanVolume'
            }

            It '3 - Should initialize Id to empty string with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Id | Should -Be ""
            }

            It '4 - Should initialize Name to empty string with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Name | Should -Be ""
            }

            It '5 - Should initialize SizeGigabytes to 0 with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.SizeGigabytes | Should -Be 0
            }

            It '6 - Should initialize Region to empty string with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Region | Should -Be ""
            }

            It '7 - Should initialize Status to empty string with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Status | Should -Be ""
            }

            It '8 - Should initialize Description to empty string with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Description | Should -Be ""
            }

            It '9 - Should initialize FilesystemType to empty string with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.FilesystemType | Should -Be ""
            }

            It '10 - Should initialize FilesystemLabel to empty string with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.FilesystemLabel | Should -Be ""
            }

            It '11 - Should initialize DropletIds to empty array with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.DropletIds | Should -Be @()
            }

            It '12 - Should initialize Tags to empty array with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Tags | Should -Be @()
            }

            It '13 - Should initialize CreatedAt to MinValue with default constructor' {
                $volume = [DigitalOceanVolume]::new()
                $volume.CreatedAt | Should -Be ([datetime]::MinValue)
            }
        }

        Context 'Constructor with PSCustomObject parameter' {
            It '14 - Should create instance with PSCustomObject constructor' {
                $volumeData = [PSCustomObject]@{
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

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume | Should -Not -BeNullOrEmpty
                $volume.GetType().Name | Should -Be 'DigitalOceanVolume'
            }

            It '15 - Should set all properties correctly from PSCustomObject' {
                $volumeData = [PSCustomObject]@{
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

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume.Id | Should -Be "506f78a4-e098-11e5-ad9f-000f53306ae1"
                $volume.Name | Should -Be "test-volume"
                $volume.Description | Should -Be "Test volume description"
                $volume.SizeGigabytes | Should -Be 100
                $volume.Region | Should -Be "nyc1"
                $volume.FilesystemType | Should -Be "ext4"
                $volume.FilesystemLabel | Should -Be "test-fs"
                $volume.Status | Should -Be "available"
                $volume.DropletIds | Should -Be @("12345", "67890")
                $volume.Tags | Should -HaveCount 2
            }

            It '16 - Should handle null VolumeObject gracefully' {
                $volume = [DigitalOceanVolume]::new($null)
                $volume | Should -Not -BeNullOrEmpty
                $volume.Id | Should -Be ""
                $volume.Name | Should -Be ""
                $volume.SizeGigabytes | Should -Be 0
            }

            It '17 - Should handle VolumeObject with null id property' {
                $volumeData = [PSCustomObject]@{
                    id             = $null
                    name           = "test-volume"
                    size_gigabytes = 100
                }

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume.Id | Should -Be ""
            }

            It '18 - Should handle VolumeObject with null name property' {
                $volumeData = [PSCustomObject]@{
                    id             = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                    name           = $null
                    size_gigabytes = 100
                }

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume.Name | Should -Be ""
            }

            It '19 - Should handle VolumeObject with invalid created_at property' {
                $volumeData = [PSCustomObject]@{
                    id         = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                    name       = "test-volume"
                    created_at = "invalid-date"
                }

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume.CreatedAt | Should -Be ([datetime]::MinValue)
            }

            It '20 - Should handle VolumeObject with null region property' {
                $volumeData = [PSCustomObject]@{
                    id     = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                    name   = "test-volume"
                    region = $null
                }

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume.Region | Should -Be ""
            }

            It '21 - Should handle VolumeObject with region having null slug property' {
                $volumeData = [PSCustomObject]@{
                    id     = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                    name   = "test-volume"
                    region = @{
                        name = "New York 1"
                        slug = $null
                    }
                }

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume.Region | Should -Be ""
            }
        }

        Context 'Methods' {
            It '22 - Should have ToString method' {
                $volume = [DigitalOceanVolume]::new()
                $volume.ToString() | Should -Not -BeNullOrEmpty
            }

            It '23 - Should have ToHashtable method' {
                $volume = [DigitalOceanVolume]::new()
                $volume.ToHashtable() | Should -Not -BeNullOrEmpty
            }

            It '24 - Should return correct string representation' {
                $volumeData = [PSCustomObject]@{
                    id             = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                    name           = "test-volume"
                    size_gigabytes = 100
                    region         = @{ slug = "nyc1" }
                }

                $volume = [DigitalOceanVolume]::new($volumeData)
                $volume.ToString() | Should -Be "test-volume (506f78a4-e098-11e5-ad9f-000f53306ae1) - 100GB in nyc1"
            }

            It '25 - Should return correct hashtable representation' {
                $volumeData = [PSCustomObject]@{
                    id               = "506f78a4-e098-11e5-ad9f-000f53306ae1"
                    name             = "test-volume"
                    description      = "Test volume"
                    size_gigabytes   = 100
                    region           = @{ slug = "nyc1" }
                    filesystem_type  = "ext4"
                    filesystem_label = "test-fs"
                    status           = "available"
                    droplet_ids      = @(12345)
                    tags             = @("production")
                    created_at       = "2016-03-02T17:00:58Z"
                }

                $volume = [DigitalOceanVolume]::new($volumeData)
                $hashtable = $volume.ToHashtable()

                $hashtable.Id | Should -Be "506f78a4-e098-11e5-ad9f-000f53306ae1"
                $hashtable.Name | Should -Be "test-volume"
                $hashtable.SizeGigabytes | Should -Be 100
                $hashtable.Region | Should -Be "nyc1"
                $hashtable.Status | Should -Be "available"
            }
        }

        Context 'Properties validation' {
            It '26 - Should have Id property of type string' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Id | Should -BeOfType [string]
            }

            It '27 - Should have Name property of type string' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Name | Should -BeOfType [string]
            }

            It '28 - Should have SizeGigabytes property of type int' {
                $volume = [DigitalOceanVolume]::new()
                $volume.SizeGigabytes | Should -BeOfType [int]
            }

            It '29 - Should have Region property of type string' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Region | Should -BeOfType [string]
            }

            It '30 - Should have Status property of type string' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Status | Should -BeOfType [string]
            }

            It '31 - Should have Description property of type string' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Description | Should -BeOfType [string]
            }

            It '32 - Should have FilesystemType property of type string' {
                $volume = [DigitalOceanVolume]::new()
                $volume.FilesystemType | Should -BeOfType [string]
            }

            It '33 - Should have FilesystemLabel property of type string' {
                $volume = [DigitalOceanVolume]::new()
                $volume.FilesystemLabel | Should -BeOfType [string]
            }

            It '34 - Should have DropletIds property of type array' {
                $volume = [DigitalOceanVolume]::new()
                $volume.DropletIds.GetType().IsArray | Should -Be $true
            }

            It '35 - Should have Tags property of type array' {
                $volume = [DigitalOceanVolume]::new()
                $volume.Tags.GetType().IsArray | Should -Be $true
            }

            It '36 - Should have CreatedAt property of type datetime' {
                $volume = [DigitalOceanVolume]::new()
                $volume.CreatedAt | Should -BeOfType [datetime]
            }
        }
    }
}
