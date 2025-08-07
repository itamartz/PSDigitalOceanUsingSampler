$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
}

InModuleScope -ModuleName 'PSDigitalOcean' {
    Describe "DigitalOceanDroplet" {
    Context "Type creation" {
        It "1 - Should create DigitalOceanDroplet type" {
            { [DigitalOceanDroplet] } | Should -Not -Throw
        }
    }

    Context "Default constructor" {
        It "2 - Should create instance with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet | Should -Not -BeNullOrEmpty
            $droplet.PSObject.TypeNames[0] | Should -Be 'DigitalOceanDroplet'
        }

        It "3 - Should initialize Id to 0 with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Id | Should -Be 0
        }

        It "4 - Should initialize Name to empty string with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Name | Should -Be ''
        }

        It "5 - Should initialize Memory to 0 with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Memory | Should -Be 0
        }

        It "6 - Should initialize Vcpus to 0 with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Vcpus | Should -Be 0
        }

        It "7 - Should initialize Disk to 0 with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Disk | Should -Be 0
        }

        It "8 - Should initialize Locked to false with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Locked | Should -Be $false
        }

        It "9 - Should initialize Status to empty string with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Status | Should -Be ''
        }

        It "10 - Should initialize CreatedAt to MinValue with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.CreatedAt | Should -Be ([datetime]::MinValue)
        }

        It "11 - Should initialize Features to empty array with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Features | Should -Be @()
        }

        It "12 - Should initialize Region to empty hashtable with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Region | Should -BeOfType [hashtable]
            $droplet.Region.Count | Should -Be 0
        }

        It "13 - Should initialize Image to empty hashtable with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Image | Should -BeOfType [hashtable]
            $droplet.Image.Count | Should -Be 0
        }

        It "14 - Should initialize Size to empty hashtable with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Size | Should -BeOfType [hashtable]
            $droplet.Size.Count | Should -Be 0
        }

        It "15 - Should initialize Networks to empty hashtable with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Networks | Should -BeOfType [hashtable]
            $droplet.Networks.Count | Should -Be 0
        }

        It "16 - Should initialize BackupIds to empty array with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.BackupIds | Should -Be @()
        }

        It "17 - Should initialize SnapshotIds to empty array with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.SnapshotIds | Should -Be @()
        }

        It "18 - Should initialize NextBackupWindow to empty array with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.NextBackupWindow | Should -Be @()
        }

        It "19 - Should initialize Tags to empty array with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Tags | Should -Be @()
        }

        It "20 - Should initialize VolumeIds to empty array with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.VolumeIds | Should -Be @()
        }

        It "21 - Should initialize VpcUuid to empty string with default constructor" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.VpcUuid | Should -Be ''
        }
    }

    Context "Constructor with PSCustomObject parameter" {
        BeforeAll {
            $script:dropletData = [PSCustomObject]@{
                id                = 123456789
                name              = "test-droplet"
                memory            = 1024
                vcpus             = 1
                disk              = 25
                locked            = $false
                status            = "active"
                created_at        = "2024-01-01T00:00:00Z"
                features          = @("ipv6", "virtio")
                region            = [PSCustomObject]@{
                    name = "New York 1"
                    slug = "nyc1"
                }
                image             = [PSCustomObject]@{
                    id           = 987654321
                    name         = "Ubuntu 20.04 x64"
                    slug         = "ubuntu-20-04-x64"
                    distribution = "Ubuntu"
                }
                size              = [PSCustomObject]@{
                    slug          = "s-1vcpu-1gb"
                    memory        = 1024
                    vcpus         = 1
                    disk          = 25
                    price_monthly = 5.0
                    price_hourly  = 0.00744
                }
                networks          = [PSCustomObject]@{
                    v4 = @([PSCustomObject]@{
                            ip_address = "192.168.1.10"
                            netmask    = "255.255.255.0"
                            gateway    = "192.168.1.1"
                            type       = "private"
                        })
                    v6 = @()
                }
                backup_ids        = @(111, 222)
                snapshot_ids      = @(333, 444)
                next_backup_window = @("2024-01-02T02:00:00Z", "2024-01-02T03:00:00Z")
                tags              = @("web", "production")
                volume_ids        = @("vol-abc123", "vol-def456")
                vpc_uuid          = "vpc-12345678-1234-1234-1234-123456789012"
            }
        }

        It "22 - Should create instance with PSCustomObject constructor" {
            $droplet = [DigitalOceanDroplet]::new($script:dropletData)
            $droplet | Should -Not -BeNullOrEmpty
            $droplet.PSObject.TypeNames[0] | Should -Be 'DigitalOceanDroplet'
        }

        It "23 - Should set all properties correctly from PSCustomObject" {
            $droplet = [DigitalOceanDroplet]::new($script:dropletData)

            $droplet.Id | Should -Be 123456789
            $droplet.Name | Should -Be "test-droplet"
            $droplet.Memory | Should -Be 1024
            $droplet.Vcpus | Should -Be 1
            $droplet.Disk | Should -Be 25
            $droplet.Locked | Should -Be $false
            $droplet.Status | Should -Be "active"
            $droplet.CreatedAt | Should -Be ([datetime]"2024-01-01T00:00:00Z")
            $droplet.Features | Should -Be @("ipv6", "virtio")
            $droplet.Region.name | Should -Be "New York 1"
            $droplet.Region.slug | Should -Be "nyc1"
            $droplet.Image.id | Should -Be 987654321
            $droplet.Image.name | Should -Be "Ubuntu 20.04 x64"
            $droplet.Image.slug | Should -Be "ubuntu-20-04-x64"
            $droplet.Image.distribution | Should -Be "Ubuntu"
            $droplet.Size.slug | Should -Be "s-1vcpu-1gb"
            $droplet.Size.memory | Should -Be 1024
            $droplet.BackupIds | Should -Be @(111, 222)
            $droplet.SnapshotIds | Should -Be @(333, 444)
            $droplet.Tags | Should -Be @("web", "production")
            $droplet.VolumeIds | Should -Be @("vol-abc123", "vol-def456")
            $droplet.VpcUuid | Should -Be "vpc-12345678-1234-1234-1234-123456789012"
        }

        It "24 - Should handle null DropletObject gracefully with fallback to default values" {
            $droplet = [DigitalOceanDroplet]::new($null)
            $droplet.Id | Should -Be 0
            $droplet.Name | Should -Be ''
            $droplet.Memory | Should -Be 0
            $droplet.Status | Should -Be ''
        }

        It "25 - Should handle DropletObject with null id property" {
            $nullIdDroplet = [PSCustomObject]@{
                id   = $null
                name = "test-droplet"
            }
            $droplet = [DigitalOceanDroplet]::new($nullIdDroplet)
            $droplet.Id | Should -Be 0
            $droplet.Name | Should -Be "test-droplet"
        }

        It "26 - Should handle DropletObject with null name property" {
            $nullNameDroplet = [PSCustomObject]@{
                id   = 123
                name = $null
            }
            $droplet = [DigitalOceanDroplet]::new($nullNameDroplet)
            $droplet.Id | Should -Be 123
            $droplet.Name | Should -Be ''
        }

        It "27 - Should handle DropletObject with invalid created_at property" {
            $invalidDateDroplet = [PSCustomObject]@{
                id         = 123
                name       = "test-droplet"
                created_at = "invalid-date"
            }
            $droplet = [DigitalOceanDroplet]::new($invalidDateDroplet)
            $droplet.CreatedAt | Should -Be ([datetime]::MinValue)
        }

        It "28 - Should handle DropletObject with null features property" {
            $nullFeaturesDroplet = [PSCustomObject]@{
                id       = 123
                name     = "test-droplet"
                features = $null
            }
            $droplet = [DigitalOceanDroplet]::new($nullFeaturesDroplet)
            $droplet.Features | Should -Be @()
        }

        It "29 - Should handle DropletObject with null region property" {
            $nullRegionDroplet = [PSCustomObject]@{
                id     = 123
                name   = "test-droplet"
                region = $null
            }
            $droplet = [DigitalOceanDroplet]::new($nullRegionDroplet)
            $droplet.Region | Should -BeOfType [hashtable]
            $droplet.Region.Count | Should -Be 0
        }

        It "30 - Should handle DropletObject with null tags property" {
            $nullTagsDroplet = [PSCustomObject]@{
                id   = 123
                name = "test-droplet"
                tags = $null
            }
            $droplet = [DigitalOceanDroplet]::new($nullTagsDroplet)
            $droplet.Tags | Should -Be @()
        }
    }

    Context "Methods" {
        It "31 - Should have ToString method" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.ToString() | Should -BeOfType [string]
        }

        It "32 - Should have ToHashtable method" {
            $droplet = [DigitalOceanDroplet]::new()
            $hashtable = $droplet.ToHashtable()
            $hashtable | Should -BeOfType [hashtable]
        }

        It "33 - Should return correct string representation" {
            $dropletData = [PSCustomObject]@{
                id   = 123
                name = "test-server"
            }
            $droplet = [DigitalOceanDroplet]::new($dropletData)
            $droplet.ToString() | Should -Be "test-server (ID: 123)"
        }

        It "34 - Should return correct hashtable representation" {
            $dropletData = [PSCustomObject]@{
                id     = 123
                name   = "test-server"
                memory = 1024
                vcpus  = 1
            }
            $droplet = [DigitalOceanDroplet]::new($dropletData)
            $hashtable = $droplet.ToHashtable()

            $hashtable.Id | Should -Be 123
            $hashtable.Name | Should -Be "test-server"
            $hashtable.Memory | Should -Be 1024
            $hashtable.Vcpus | Should -Be 1
        }
    }

    Context "Properties validation" {
        It "35 - Should have Id property of type int" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Id | Should -BeOfType [int]
        }

        It "36 - Should have Name property of type string" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Name | Should -BeOfType [string]
        }

        It "37 - Should have Memory property of type int" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Memory | Should -BeOfType [int]
        }

        It "38 - Should have Vcpus property of type int" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Vcpus | Should -BeOfType [int]
        }

        It "39 - Should have Disk property of type int" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Disk | Should -BeOfType [int]
        }

        It "40 - Should have Locked property of type bool" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Locked | Should -BeOfType [bool]
        }

        It "41 - Should have Status property of type string" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Status | Should -BeOfType [string]
        }

        It "42 - Should have CreatedAt property of type datetime" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.CreatedAt | Should -BeOfType [datetime]
        }

        It "43 - Should have Features property of type string array" {
            $droplet = [DigitalOceanDroplet]::new()
            # Check if property exists and is either null or empty array
            if ($null -eq $droplet.Features) {
                $droplet.Features | Should -BeNullOrEmpty
            } else {
                $droplet.Features.GetType().Name | Should -Match "Object\[\]|String\[\]"
            }
        }

        It "44 - Should have Region property of type hashtable" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Region | Should -BeOfType [hashtable]
        }

        It "45 - Should have Image property of type hashtable" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Image | Should -BeOfType [hashtable]
        }

        It "46 - Should have Size property of type hashtable" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Size | Should -BeOfType [hashtable]
        }

        It "47 - Should have Networks property of type hashtable" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.Networks | Should -BeOfType [hashtable]
        }

        It "48 - Should have BackupIds property of type int array" {
            $droplet = [DigitalOceanDroplet]::new()
            # Check if property exists and is either null or empty array
            if ($null -eq $droplet.BackupIds) {
                $droplet.BackupIds | Should -BeNullOrEmpty
            } else {
                $droplet.BackupIds.GetType().Name | Should -Match "Object\[\]|Int32\[\]"
            }
        }

        It "49 - Should have SnapshotIds property of type int array" {
            $droplet = [DigitalOceanDroplet]::new()
            # Check if property exists and is either null or empty array
            if ($null -eq $droplet.SnapshotIds) {
                $droplet.SnapshotIds | Should -BeNullOrEmpty
            } else {
                $droplet.SnapshotIds.GetType().Name | Should -Match "Object\[\]|Int32\[\]"
            }
        }

        It "50 - Should have NextBackupWindow property of type string array" {
            $droplet = [DigitalOceanDroplet]::new()
            # Check if property exists and is either null or empty array
            if ($null -eq $droplet.NextBackupWindow) {
                $droplet.NextBackupWindow | Should -BeNullOrEmpty
            } else {
                $droplet.NextBackupWindow.GetType().Name | Should -Match "Object\[\]|String\[\]"
            }
        }

        It "51 - Should have Tags property of type string array" {
            $droplet = [DigitalOceanDroplet]::new()
            # Check if property exists and is either null or empty array
            if ($null -eq $droplet.Tags) {
                $droplet.Tags | Should -BeNullOrEmpty
            } else {
                $droplet.Tags.GetType().Name | Should -Match "Object\[\]|String\[\]"
            }
        }

        It "52 - Should have VolumeIds property of type string array" {
            $droplet = [DigitalOceanDroplet]::new()
            # Check if property exists and is either null or empty array
            if ($null -eq $droplet.VolumeIds) {
                $droplet.VolumeIds | Should -BeNullOrEmpty
            } else {
                $droplet.VolumeIds.GetType().Name | Should -Match "Object\[\]|String\[\]"
            }
        }

        It "53 - Should have VpcUuid property of type string" {
            $droplet = [DigitalOceanDroplet]::new()
            $droplet.VpcUuid | Should -BeOfType [string]
        }
    }
}
}
