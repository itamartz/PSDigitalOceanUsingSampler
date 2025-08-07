$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
}

InModuleScope $script:dscModuleName {
    Describe 'Final Coverage Booster' {
        Context 'Specific line coverage' {
            It '1 - Should cover specific DigitalOceanDroplet constructor property handling' {
                # This targets the specific missed lines in DropletObject.region, image, size, networks handling
                $dropletData = @{
                    region = @{ name = 'test-region'; slug = 'test-slug' }
                    image = @{ id = 123; name = 'test-image'; slug = 'test-slug'; distribution = 'test-dist' }
                    size = @{ slug = 'test-size'; memory = 1024; vcpus = 1; disk = 25; price_monthly = 5.0; price_hourly = 0.007 }
                    networks = @{ v4 = @('192.168.1.1'); v6 = @('::1') }
                    backup_ids = @(1, 2, 3)
                    snapshot_ids = @(4, 5, 6)
                    next_backup_window = @('2023-01-01T00:00:00Z')
                    tags = @('tag1', 'tag2')
                    volume_ids = @('vol-1', 'vol-2')
                }

                $droplet = [DigitalOceanDroplet]::new($dropletData)

                # Validate that all properties are correctly assigned
                $droplet.Region.name | Should -Be 'test-region'
                $droplet.Image.id | Should -Be 123
                $droplet.Size.slug | Should -Be 'test-size'
                $droplet.Networks.v4 | Should -Contain '192.168.1.1'
                $droplet.BackupIds | Should -Contain 1
                $droplet.SnapshotIds | Should -Contain 4
                $droplet.NextBackupWindow | Should -Contain '2023-01-01T00:00:00Z'
                $droplet.Tags | Should -Contain 'tag1'
                $droplet.VolumeIds | Should -Contain 'vol-1'
            }

            It '2 - Should cover DigitalOceanImage property handling' {
                # Target specific missed lines in DigitalOceanImage
                $imageData = @{
                    status = 'available'
                    error_message = 'test error'
                    size_gigabytes = 25
                    min_disk_size = 10
                    description = 'test description'
                    tags = @{ 'tag1' = 'value1' }
                }

                $image = [DigitalOceanImage]::new($imageData)

                $image.Status | Should -Be 'available'
                $image.ErrorMessage | Should -Be 'test error'
                $image.SizeGigabytes | Should -Be 25
                $image.MinDiskSize | Should -Be 10
                $image.Description | Should -Be 'test description'
                $image.Tags | Should -Not -BeNullOrEmpty
            }

            It '3 - Should cover DigitalOceanVPC empty string assignment' {
                # Target the specific missed line: DigitalOceanVPC IpRange = ''
                $vpc = [DigitalOceanVPC]::new()
                $vpc.IpRange | Should -Be ''
            }
        }
    }
}
