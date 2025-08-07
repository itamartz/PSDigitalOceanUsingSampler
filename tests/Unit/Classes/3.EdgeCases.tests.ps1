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
    Describe 'Error Handling and Edge Cases Coverage' {
        Context 'DigitalOceanImage edge cases' {
            It '1 - Should handle null regions correctly' {
                $imageData = @{
                    id = 12345
                    regions = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.Regions | Should -BeNullOrEmpty
            }

            It '2 - Should handle invalid created_at' {
                $imageData = @{
                    id = 12345
                    created_at = "invalid-date"
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.CreatedAt | Should -Be ([datetime]::MinValue)
            }

            It '3 - Should handle null status' {
                $imageData = @{
                    id = 12345
                    status = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.Status | Should -Be ([string]$null)
            }

            It '4 - Should handle null error_message' {
                $imageData = @{
                    id = 12345
                    error_message = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.ErrorMessage | Should -Be ([string]$null)
            }

            It '5 - Should handle null size_gigabytes' {
                $imageData = @{
                    id = 12345
                    size_gigabytes = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.SizeGigabytes | Should -Be ([int]$null)
            }

            It '6 - Should handle null min_disk_size' {
                $imageData = @{
                    id = 12345
                    min_disk_size = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.MinDiskSize | Should -Be ([int]$null)
            }

            It '7 - Should handle null description' {
                $imageData = @{
                    id = 12345
                    description = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.Description | Should -Be ([string]$null)
            }

            It '8 - Should handle null tags' {
                $imageData = @{
                    id = 12345
                    tags = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.Tags | Should -BeOfType [hashtable]
            }
        }

        Context 'DigitalOceanSize edge cases' {
            It '9 - Should handle null regions' {
                $sizeData = @{
                    slug = "test-size"
                    regions = $null
                }

                $size = [DigitalOceanSize]::new($sizeData)
                $size.Regions | Should -BeNullOrEmpty
            }
        }

        Context 'DigitalOceanDroplet edge cases' {
            It '10 - Should handle null locked property' {
                $dropletData = @{
                    id = 12345
                    locked = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Locked | Should -Be ([bool]$null)
            }

            It '11 - Should handle invalid created_at' {
                $dropletData = @{
                    id = 12345
                    created_at = "invalid-date"
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.CreatedAt | Should -Be ([datetime]::MinValue)
            }

            It '12 - Should handle null features' {
                $dropletData = @{
                    id = 12345
                    features = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Features | Should -Be @([string[]]$null)
            }

            It '13 - Should handle null region properties' {
                $dropletData = @{
                    id = 12345
                    region = @{
                        name = $null
                        slug = $null
                    }
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Region.name | Should -BeNullOrEmpty
                $droplet.Region.slug | Should -BeNullOrEmpty
            }

            It '14 - Should handle null image properties' {
                $dropletData = @{
                    id = 12345
                    image = @{
                        id = $null
                        name = $null
                        slug = $null
                        distribution = $null
                    }
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Image.id | Should -BeNullOrEmpty
                $droplet.Image.name | Should -BeNullOrEmpty
                $droplet.Image.slug | Should -BeNullOrEmpty
                $droplet.Image.distribution | Should -BeNullOrEmpty
            }

            It '15 - Should handle null size properties' {
                $dropletData = @{
                    id = 12345
                    size = @{
                        slug = $null
                        memory = $null
                        vcpus = $null
                        disk = $null
                        price_monthly = $null
                        price_hourly = $null
                    }
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Size.slug | Should -BeNullOrEmpty
                $droplet.Size.memory | Should -BeNullOrEmpty
                $droplet.Size.vcpus | Should -BeNullOrEmpty
                $droplet.Size.disk | Should -BeNullOrEmpty
                $droplet.Size.price_monthly | Should -BeNullOrEmpty
                $droplet.Size.price_hourly | Should -BeNullOrEmpty
            }

            It '16 - Should handle networks as hashtable' {
                $dropletData = @{
                    id = 12345
                    networks = @{
                        v4 = @("test")
                        v6 = @("test6")
                    }
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Networks | Should -BeOfType [hashtable]
            }

            It '17 - Should handle null network properties' {
                $dropletData = @{
                    id = 12345
                    networks = @{
                        v4 = $null
                        v6 = $null
                    }
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Networks.v4 | Should -Be @()
                $droplet.Networks.v6 | Should -Be @()
            }

            It '18 - Should handle null backup_ids' {
                $dropletData = @{
                    id = 12345
                    backup_ids = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.BackupIds | Should -Be @([int[]]$null)
            }

            It '19 - Should handle null snapshot_ids' {
                $dropletData = @{
                    id = 12345
                    snapshot_ids = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.SnapshotIds | Should -Be @([int[]]$null)
            }

            It '20 - Should handle null next_backup_window' {
                $dropletData = @{
                    id = 12345
                    next_backup_window = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.NextBackupWindow | Should -Be @([string[]]$null)
            }

            It '21 - Should handle null tags' {
                $dropletData = @{
                    id = 12345
                    tags = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.Tags | Should -Be @([string[]]$null)
            }

            It '22 - Should handle null volume_ids' {
                $dropletData = @{
                    id = 12345
                    volume_ids = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.VolumeIds | Should -Be @([string[]]$null)
            }

            It '23 - Should handle null vpc_uuid' {
                $dropletData = @{
                    id = 12345
                    vpc_uuid = $null
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $droplet.VpcUuid | Should -Be ([string]$null)
            }
        }

        Context 'DigitalOceanVPC edge case' {
            It '24 - Should handle null VPC name gracefully' {
                $vpcData = @{
                    name = $null
                }

                $vpc = [DigitalOceanVPC]::new($vpcData)
                $vpc.Name | Should -Be ''
            }
        }
    }
}
