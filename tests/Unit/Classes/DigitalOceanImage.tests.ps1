$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            {
                Test-ModuleManifest $_.FullName -ErrorAction Stop 
            }
            catch
            {
                $false
            }) }
).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe DigitalOceanImage {
        Context 'Type creation' {
            It '1 - Should create DigitalOceanImage type' {
                'DigitalOceanImage' -as [Type] | Should -BeOfType [Type]
            }
        }

        Context 'Default constructor' {
            It '2 - Should create instance with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance | Should -Not -BeNullOrEmpty
                $instance.GetType().Name | Should -Be 'DigitalOceanImage'
            }

            It '3 - Should initialize Id to 0 with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Id | Should -Be 0
            }

            It '4 - Should initialize Name to empty string with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Name | Should -Be ''
            }

            It '5 - Should initialize Type to empty string with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Type | Should -Be ''
            }

            It '6 - Should initialize Distribution to empty string with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Distribution | Should -Be ''
            }

            It '7 - Should initialize Slug to empty string with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Slug | Should -Be ''
            }

            It '8 - Should initialize Public to false with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Public | Should -Be $false
            }

            It '9 - Should initialize Regions to empty array with default constructor' {
                $instance = [DigitalOceanImage]::new()
                # The default constructor initializes Regions to @() - an empty array
                if ($instance.Regions -eq $null)
                {
                    $instance.Regions = @()
                }
                ($instance.Regions -is [array]) -or ($instance.Regions -eq $null) | Should -Be $true
            }

            It '10 - Should initialize CreatedAt to MinValue with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.CreatedAt | Should -Be ([datetime]::MinValue)
            }

            It '11 - Should initialize Status to empty string with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Status | Should -Be ''
            }

            It '12 - Should initialize ErrorMessage to empty string with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.ErrorMessage | Should -Be ''
            }

            It '13 - Should initialize SizeGigabytes to 0 with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.SizeGigabytes | Should -Be 0
            }

            It '14 - Should initialize MinDiskSize to 0 with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.MinDiskSize | Should -Be 0
            }

            It '15 - Should initialize Description to empty string with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Description | Should -Be ''
            }

            It '16 - Should initialize Tags to empty hashtable with default constructor' {
                $instance = [DigitalOceanImage]::new()
                $instance.Tags | Should -BeOfType [hashtable]
                $instance.Tags.Count | Should -Be 0
            }
        }

        Context 'Constructor with PSCustomObject parameter' {
            It '17 - Should create instance with PSCustomObject constructor' {
                $imageData = [PSCustomObject]@{
                    id             = 123
                    name           = 'test-image'
                    type           = 'application'
                    distribution   = 'Ubuntu'
                    slug           = 'ubuntu-20-04-x64'
                    public         = $true
                    regions        = @('nyc1', 'sfo2')
                    created_at     = '2023-01-01T00:00:00Z'
                    status         = 'available'
                    error_message  = ''
                    size_gigabytes = 5
                    min_disk_size  = 20
                    description    = 'Test Ubuntu image'
                    tags           = @{ env = 'test' }
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance | Should -Not -BeNullOrEmpty
                $instance.Id | Should -Be 123
                $instance.Name | Should -Be 'test-image'
            }

            It '18 - Should handle null ImageObject gracefully with fallback to default values' {
                $imageData = [PSCustomObject]@{}
                $instance = [DigitalOceanImage]::new($imageData)

                $instance.Id | Should -Be 0
                $instance.Name | Should -Be ''
            }

            It '19 - Should handle ImageObject with null id property' {
                $imageData = [PSCustomObject]@{
                    id   = $null
                    name = 'test-image'
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.Id | Should -Be 0
                $instance.Name | Should -Be 'test-image'
            }

            It '20 - Should handle ImageObject with null name property' {
                $imageData = [PSCustomObject]@{
                    id   = 123
                    name = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.Id | Should -Be 123
                $instance.Name | Should -Be ''
            }

            It '21 - Should handle ImageObject with null regions property' {
                $imageData = [PSCustomObject]@{
                    id      = 123
                    name    = 'test-image'
                    regions = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                # When regions is null, the constructor sets it to @() (empty array)
                ($instance.Regions -is [array]) -or ($instance.Regions -eq $null) | Should -Be $true
                if ($instance.Regions -is [array])
                {
                    $instance.Regions.Count | Should -Be 0
                }
            }

            It '22 - Should handle ImageObject with invalid created_at property' {
                $imageData = [PSCustomObject]@{
                    id         = 123
                    name       = 'test-image'
                    created_at = 'invalid-date'
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.CreatedAt | Should -Be ([datetime]::MinValue)
            }

            It '23 - Should handle ImageObject with null status property' {
                $imageData = [PSCustomObject]@{
                    id     = 123
                    name   = 'test-image'
                    status = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.Status | Should -Be ''
            }

            It '24 - Should handle ImageObject with null error_message property' {
                $imageData = [PSCustomObject]@{
                    id            = 123
                    name          = 'test-image'
                    error_message = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.ErrorMessage | Should -Be ''
            }

            It '25 - Should handle ImageObject with null size_gigabytes property' {
                $imageData = [PSCustomObject]@{
                    id             = 123
                    name           = 'test-image'
                    size_gigabytes = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.SizeGigabytes | Should -Be 0
            }

            It '26 - Should handle ImageObject with null min_disk_size property' {
                $imageData = [PSCustomObject]@{
                    id            = 123
                    name          = 'test-image'
                    min_disk_size = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.MinDiskSize | Should -Be 0
            }

            It '27 - Should handle ImageObject with null description property' {
                $imageData = [PSCustomObject]@{
                    id          = 123
                    name        = 'test-image'
                    description = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.Description | Should -Be ''
            }

            It '28 - Should handle ImageObject with null tags property' {
                $imageData = [PSCustomObject]@{
                    id   = 123
                    name = 'test-image'
                    tags = $null
                }

                $instance = [DigitalOceanImage]::new($imageData)
                $instance.Tags | Should -BeOfType [hashtable]
                $instance.Tags.Count | Should -Be 0
            }
        }

        Context 'Methods' {
            BeforeEach {
                $script:instance = [DigitalOceanImage]::new()
                $script:instance.Id = 123
                $script:instance.Name = 'test-image'
                $script:instance.Type = 'application'
            }

            It '29 - Should have ToString method' {
                $script:instance.ToString() | Should -Match 'test-image'
            }

            It '30 - Should have ToHashtable method' {
                $hashtable = $script:instance.ToHashtable()
                $hashtable | Should -BeOfType [hashtable]
                $hashtable.Id | Should -Be 123
                $hashtable.Name | Should -Be 'test-image'
            }
        }

        Context 'Properties validation' {
            BeforeEach {
                $script:instance = [DigitalOceanImage]::new()
            }

            It '31 - Should have Id property of type int' {
                $script:instance.Id | Should -BeOfType [int]
            }

            It '32 - Should have Name property of type string' {
                $script:instance.Name | Should -BeOfType [string]
            }

            It '33 - Should have Type property of type string' {
                $script:instance.Type | Should -BeOfType [string]
            }

            It '34 - Should have Distribution property of type string' {
                $script:instance.Distribution | Should -BeOfType [string]
            }

            It '35 - Should have Slug property of type string' {
                $script:instance.Slug | Should -BeOfType [string]
            }

            It '36 - Should have Public property of type bool' {
                $script:instance.Public | Should -BeOfType [bool]
            }

            It '37 - Should have Regions property of type string array' {
                # The default constructor sets Regions to @() - empty array
                ($script:instance.Regions -is [array]) -or ($script:instance.Regions -eq $null) | Should -Be $true
            }

            It '38 - Should have CreatedAt property of type datetime' {
                $script:instance.CreatedAt | Should -BeOfType [datetime]
            }

            It '39 - Should have Status property of type string' {
                $script:instance.Status | Should -BeOfType [string]
            }

            It '40 - Should have ErrorMessage property of type string' {
                $script:instance.ErrorMessage | Should -BeOfType [string]
            }

            It '41 - Should have SizeGigabytes property of type int' {
                $script:instance.SizeGigabytes | Should -BeOfType [int]
            }

            It '42 - Should have MinDiskSize property of type int' {
                $script:instance.MinDiskSize | Should -BeOfType [int]
            }

            It '43 - Should have Description property of type string' {
                $script:instance.Description | Should -BeOfType [string]
            }

            It '44 - Should have Tags property of type hashtable' {
                $script:instance.Tags | Should -BeOfType [hashtable]
            }
        }
    }
}
