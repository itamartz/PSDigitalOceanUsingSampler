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
    Describe DigitalOceanSize {
        Context '1 - Should create empty DigitalOceanSize object' {
            It '1 - Should create object with default constructor' {
                $size = [DigitalOceanSize]::new()
                $size | Should -BeOfType [DigitalOceanSize]
                $size.Slug | Should -BeNullOrEmpty
                $size.Memory | Should -Be 0
                $size.Vcpus | Should -Be 0
                $size.Disk | Should -Be 0
                $size.Transfer | Should -Be 0
                $size.PriceMonthly | Should -Be 0
                $size.PriceHourly | Should -Be 0
                $size.Available | Should -Be $false
            }
        }

        Context '2 - Should create DigitalOceanSize object from PSCustomObject' {
            BeforeAll {
                $sizeData = [PSCustomObject]@{
                    slug = 's-1vcpu-1gb'
                    memory = 1024
                    vcpus = 1
                    disk = 25
                    transfer = 1
                    price_monthly = 5.0
                    price_hourly = 0.00744
                    regions = @('nyc1', 'nyc2', 'nyc3')
                    available = $true
                    description = 'Basic'
                }
            }

            It '1 - Should create object with correct properties' {
                $size = [DigitalOceanSize]::new($sizeData)
                $size | Should -BeOfType [DigitalOceanSize]
                $size.Slug | Should -Be 's-1vcpu-1gb'
                $size.Memory | Should -Be 1024
                $size.Vcpus | Should -Be 1
                $size.Disk | Should -Be 25
                $size.Transfer | Should -Be 1
                $size.PriceMonthly | Should -Be 5.0
                $size.PriceHourly | Should -Be 0.00744
                $size.Regions | Should -Be @('nyc1', 'nyc2', 'nyc3')
                $size.Available | Should -Be $true
                $size.Description | Should -Be 'Basic'
            }

            It '2 - Should return slug when converted to string' {
                $size = [DigitalOceanSize]::new($sizeData)
                $size.ToString() | Should -Be 's-1vcpu-1gb'
            }
        }

        Context '3 - Should handle null or missing properties gracefully' {
            BeforeAll {
                $incompleteSizeData = [PSCustomObject]@{
                    slug = 's-test'
                    memory = 512
                    vcpus = 1
                }
            }

            It '1 - Should handle missing properties' {
                $size = [DigitalOceanSize]::new($incompleteSizeData)
                $size | Should -BeOfType [DigitalOceanSize]
                $size.Slug | Should -Be 's-test'
                $size.Memory | Should -Be 512
                $size.Vcpus | Should -Be 1
                $size.Disk | Should -Be 0
                $size.Transfer | Should -Be 0
                $size.PriceMonthly | Should -Be 0
                $size.PriceHourly | Should -Be 0
                $size.Available | Should -Be $false
            }
        }

        Context '4 - Should validate data types' {
            BeforeAll {
                $sizeData = [PSCustomObject]@{
                    slug = 's-2vcpu-4gb'
                    memory = 4096
                    vcpus = 2
                    disk = 80
                    transfer = 4
                    price_monthly = 20.0
                    price_hourly = 0.02976
                    regions = @('fra1', 'lon1', 'tor1')
                    available = $true
                    description = 'Standard'
                }
            }

            It '1 - Should have correct property types' {
                $size = [DigitalOceanSize]::new($sizeData)
                $size.Slug | Should -BeOfType [string]
                $size.Memory | Should -BeOfType [int]
                $size.Vcpus | Should -BeOfType [int]
                $size.Disk | Should -BeOfType [int]
                $size.Transfer | Should -BeOfType [int]
                $size.PriceMonthly | Should -BeOfType [decimal]
                $size.PriceHourly | Should -BeOfType [decimal]
                $size.Regions | Should -BeOfType [string[]]
                $size.Available | Should -BeOfType [bool]
                $size.Description | Should -BeOfType [string]
            }
        }
    }
}
