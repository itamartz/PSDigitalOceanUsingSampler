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
    Describe 'DigitalOceanDroplet ToHashtable Coverage' {
        Context 'ToHashtable method' {
            It '1 - Should return correct hashtable representation' {
                # Create a droplet object with all properties
                $dropletData = @{
                    id = 12345
                    name = "test-droplet"
                    memory = 1024
                    vcpus = 1
                    disk = 25
                    locked = $false
                    status = "active"
                    created_at = "2023-01-01T00:00:00Z"
                    features = @("virtio")
                    region = @{
                        name = "New York 1"
                        slug = "nyc1"
                    }
                    image = @{
                        id = 6918990
                        name = "20.04 (LTS) x64"
                        slug = "ubuntu-20-04-x64"
                        distribution = "Ubuntu"
                    }
                    size = @{
                        slug = "s-1vcpu-1gb"
                        memory = 1024
                        vcpus = 1
                        disk = 25
                        price_monthly = 5.0
                        price_hourly = 0.007
                    }
                    networks = @{
                        v4 = @()
                        v6 = @()
                    }
                    backup_ids = @()
                    snapshot_ids = @()
                    next_backup_window = @()
                    tags = @()
                    volume_ids = @()
                    vpc_uuid = "vpc-12345"
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)
                $hashtable = $droplet.ToHashtable()

                $hashtable | Should -BeOfType [hashtable]
                $hashtable.Id | Should -Be 12345
                $hashtable.Name | Should -Be "test-droplet"
                $hashtable.Memory | Should -Be 1024
                $hashtable.Vcpus | Should -Be 1
                $hashtable.Disk | Should -Be 25
                $hashtable.Locked | Should -Be $false
                $hashtable.Status | Should -Be "active"
                $hashtable.CreatedAt | Should -BeOfType [datetime]
                $hashtable.Features | Should -Be @("virtio")
                $hashtable.Region | Should -BeOfType [hashtable]
                $hashtable.Image | Should -BeOfType [hashtable]
                $hashtable.Size | Should -BeOfType [hashtable]
                $hashtable.Networks | Should -BeOfType [hashtable]
                $hashtable.BackupIds | Should -Be @()
                $hashtable.SnapshotIds | Should -Be @()
                $hashtable.NextBackupWindow | Should -Be @()
                $hashtable.Tags | Should -Be @()
                $hashtable.VolumeIds | Should -Be @()
                $hashtable.VpcUuid | Should -Be "vpc-12345"
            }
        }
    }
}
