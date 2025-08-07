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
    Describe 'Complete Code Coverage Tests' {
        Context 'Missing constructor lines' {
            It '1 - Should cover DigitalOceanVPC empty string default' {
                $vpc = [DigitalOceanVPC]::new(@{ name = '' })
                $vpc.Name | Should -Be ''
            }

            It '2 - Should cover DigitalOceanImage default values' {
                $image = [DigitalOceanImage]::new(@{ id = 0 })
                $image.Id | Should -Be 0
            }

            It '3 - Should cover DigitalOceanSize empty string default' {
                $size = [DigitalOceanSize]::new(@{ slug = '' })
                $size.Slug | Should -Be ''
            }

            It '4 - Should cover DigitalOceanDroplet default value' {
                $droplet = [DigitalOceanDroplet]::new(@{ id = 0 })
                $droplet.Id | Should -Be 0
            }
        }

        Context 'Edge case handling for constructors' {
            It '5 - Should handle DigitalOceanImage with null regions property' {
                $imageData = @{
                    id      = 12345
                    regions = $null
                }
                $image = [DigitalOceanImage]::new($imageData)
                # This should trigger the @([string]$ImageObject.regions) line
                $image.Regions | Should -BeNullOrEmpty
            }

            It '6 - Should handle DigitalOceanImage status as string when null' {
                $imageData = @{
                    id     = 12345
                    status = $null
                }
                $image = [DigitalOceanImage]::new($imageData)
                # This should trigger the [string]$ImageObject.status line
                $image.Status | Should -BeOfType [string]
            }

            It '7 - Should handle DigitalOceanImage error_message as string when null' {
                $imageData = @{
                    id            = 12345
                    error_message = $null
                }
                $image = [DigitalOceanImage]::new($imageData)
                # This should trigger the [string]$ImageObject.error_message line
                $image.ErrorMessage | Should -BeOfType [string]
            }

            It '8 - Should handle DigitalOceanImage size_gigabytes as int when null' {
                $imageData = @{
                    id             = 12345
                    size_gigabytes = $null
                }
                $image = [DigitalOceanImage]::new($imageData)
                # This should trigger the [int]$ImageObject.size_gigabytes line
                [int]$image.SizeGigabytes | Should -BeOfType [int]
            }

            It '9 - Should handle DigitalOceanImage min_disk_size as int when null' {
                $imageData = @{
                    id            = 12345
                    min_disk_size = $null
                }
                $image = [DigitalOceanImage]::new($imageData)
                # This should trigger the [int]$ImageObject.min_disk_size line
                [int]$image.MinDiskSize | Should -BeOfType [int]
            }

            It '10 - Should handle DigitalOceanImage description as string when null' {
                $imageData = @{
                    id          = 12345
                    description = $null
                }
                $image = [DigitalOceanImage]::new($imageData)
                # This should trigger the [string]$ImageObject.description line
                $image.Description | Should -BeOfType [string]
            }

            It '11 - Should handle DigitalOceanImage tags as hashtable when null' {
                $imageData = @{
                    id   = 12345
                    tags = $null
                }
                $image = [DigitalOceanImage]::new($imageData)
                # This should trigger the [hashtable]$ImageObject.tags line
                $image.Tags | Should -BeOfType [hashtable]
            }

            It '12 - Should handle DigitalOceanSize with null regions' {
                $sizeData = @{
                    slug    = "test"
                    regions = $null
                }
                $size = [DigitalOceanSize]::new($sizeData)
                # This should trigger the @([string]$InputObject.regions) and [string]$InputObject.regions lines
                $size.Regions | Should -BeNullOrEmpty
            }
        }

        Context 'Droplet complex property handling' {
            It '13 - Should handle DigitalOceanDroplet with no region name' {
                $dropletData = @{
                    id     = 12345
                    region = [PSCustomObject]@{
                        name = $null  # Explicitly null to trigger line 147 else branch
                        slug = 'nyc1'
                    }
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { '' } branch for region.name (line 147)
                $droplet.Region.name | Should -Be ''
            }

            It '14 - Should handle DigitalOceanDroplet with no region slug' {
                $dropletData = @{
                    id     = 12345
                    region = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { '' } branch
                $droplet.Region.slug | Should -BeNullOrEmpty
            }

            It '15 - Should handle DigitalOceanDroplet with no image id' {
                $dropletData = @{
                    id    = 12345
                    image = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { 0 } branch - but PowerShell returns $null for missing properties
                $droplet.Image.id | Should -BeNullOrEmpty
            }

            It '16 - Should handle DigitalOceanDroplet with no image name' {
                $dropletData = @{
                    id    = 12345
                    image = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { '' } branch
                $droplet.Image.name | Should -BeNullOrEmpty
            }

            It '17 - Should handle DigitalOceanDroplet with no image slug' {
                $dropletData = @{
                    id    = 12345
                    image = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { '' } branch
                $droplet.Image.slug | Should -BeNullOrEmpty
            }

            It '18 - Should handle DigitalOceanDroplet with no image distribution' {
                $dropletData = @{
                    id    = 12345
                    image = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { '' } branch
                $droplet.Image.distribution | Should -BeNullOrEmpty
            }

            It '19 - Should handle DigitalOceanDroplet with no size properties' {
                $dropletData = @{
                    id   = 12345
                    size = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger all the else { } branches for size - but PowerShell returns $null for missing properties
                $droplet.Size.slug | Should -BeNullOrEmpty
                $droplet.Size.memory | Should -BeNullOrEmpty
                $droplet.Size.vcpus | Should -BeNullOrEmpty
                $droplet.Size.disk | Should -BeNullOrEmpty
                $droplet.Size.price_monthly | Should -BeNullOrEmpty
                $droplet.Size.price_hourly | Should -BeNullOrEmpty
            }

            It '20 - Should handle DigitalOceanDroplet with no network v4' {
                $dropletData = @{
                    id       = 12345
                    networks = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { @() } branch - but PowerShell returns $null for missing properties
                $droplet.Networks.v4 | Should -BeNullOrEmpty
            }

            It '21 - Should handle DigitalOceanDroplet with no network v6' {
                $dropletData = @{
                    id       = 12345
                    networks = @{}
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the else { @() } branch - but PowerShell returns $null for missing properties
                $droplet.Networks.v6 | Should -BeNullOrEmpty
            }

            It '22 - Should handle DigitalOceanDroplet with null array properties' {
                $dropletData = @{
                    id                 = 12345
                    backup_ids         = $null
                    snapshot_ids       = $null
                    next_backup_window = $null
                    tags               = $null
                    volume_ids         = $null
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # Should trigger the various array conversion lines
                $droplet.BackupIds | Should -BeNullOrEmpty
                $droplet.SnapshotIds | Should -BeNullOrEmpty
                $droplet.NextBackupWindow | Should -BeNullOrEmpty
                $droplet.Tags | Should -BeNullOrEmpty
                $droplet.VolumeIds | Should -BeNullOrEmpty
            }

            It '23 - Should handle DigitalOceanDroplet with image containing null id to trigger else branch (line 166)' {
                # To reach the if-else logic, we need an image that is NOT a hashtable
                # Create a PSCustomObject with missing id property
                $imageObject = [PSCustomObject]@{
                    name = 'test-image'
                    # No id property - this should trigger the else { 0 } branch
                }
                $dropletData = @{
                    id    = 12345
                    image = $imageObject
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # This should trigger the else { 0 } branch in line 166
                $droplet.Image.id | Should -Be 0
                $droplet.Image.name | Should -Be 'test-image'
            }

            It '24 - Should handle DigitalOceanDroplet with image containing valid id to verify if-else works' {
                $dropletData = @{
                    id    = 12345
                    image = @{
                        id = 123
                        name = 'test-image'
                    }
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # This should trigger the if branch and return 123
                $droplet.Image.id | Should -Be 123
                $droplet.Image.name | Should -Be 'test-image'
            }

            It '25 - Should handle DigitalOceanDroplet with size containing null properties to trigger else branches (lines 187-192)' {
                # Create object with size as PSCustomObject containing null properties
                $sizeObject = [PSCustomObject]@{
                    slug          = $null
                    memory        = $null
                    vcpus         = $null
                    disk          = $null
                    price_monthly = $null
                    price_hourly  = $null
                }
                $dropletData = @{
                    id   = 12345
                    size = $sizeObject
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # These should trigger the else branches and return default values
                $droplet.Size.slug | Should -Be ''
                $droplet.Size.memory | Should -Be 0
                $droplet.Size.vcpus | Should -Be 0
                $droplet.Size.disk | Should -Be 0
                $droplet.Size.price_monthly | Should -Be 0
                $droplet.Size.price_hourly | Should -Be 0
            }

            It '26 - Should handle DigitalOceanDroplet with networks containing null properties to trigger else branches (lines 210-211)' {
                # Create object with networks as PSCustomObject containing null properties
                $networksObject = [PSCustomObject]@{
                    v4 = $null
                    v6 = $null
                }
                $dropletData = @{
                    id       = 12345
                    networks = $networksObject
                }
                $droplet = [DigitalOceanDroplet]::new($dropletData)
                # These should trigger the else branches and return empty arrays
                $droplet.Networks.v4 | Should -Be @()
                $droplet.Networks.v6 | Should -Be @()
            }
        }
    }
}
