$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
}

InModuleScope $script:dscModuleName {
    Describe 'DigitalOceanImage Specific Coverage' {
        Context 'Default constructor coverage' {
            It '1 - Should cover all default constructor lines' {
                # This will cover the specific missed lines:
                # $this.Id = 0, $this.Name = '', etc.
                $image = [DigitalOceanImage]::new()

                # Verify all default values are set correctly
                $image.Id | Should -Be 0
                $image.Name | Should -Be ''
                $image.Type | Should -Be ''
                $image.Distribution | Should -Be ''
                $image.Slug | Should -Be ''
                $image.Public | Should -Be $false
                $image.Regions | Should -Be @()
                $image.CreatedAt | Should -Be ([datetime]::MinValue)
                $image.Status | Should -Be ''
                $image.ErrorMessage | Should -Be ''
                $image.SizeGigabytes | Should -Be 0
                $image.MinDiskSize | Should -Be 0
                $image.Description | Should -Be ''
                $image.Tags | Should -BeOfType [hashtable]
            }
        }

        Context 'Regions string conversion coverage' {
            It '2 - Should cover string conversion of regions' {
                # This targets the specific missed lines:
                # $this.Regions = @([string]$ImageObject.regions)
                # [string]$ImageObject.regions
                $imageData = @{
                    regions = "nyc1"  # Single string to trigger string conversion
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.Regions | Should -Contain "nyc1"
            }

            It '3 - Should handle regions as null to trigger string conversion' {
                # This should trigger the [string]$ImageObject.regions conversion
                $imageData = @{
                    regions = $null
                }

                $image = [DigitalOceanImage]::new($imageData)
                $image.Regions | Should -Be @()
            }
        }
    }
}
