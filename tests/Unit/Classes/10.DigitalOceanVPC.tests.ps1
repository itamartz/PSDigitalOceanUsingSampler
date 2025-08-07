$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
}

InModuleScope -ModuleName 'PSDigitalOcean' {
    Describe "DigitalOceanVPC" {
        Context "Type creation" {
            It "1 - Should create DigitalOceanVPC type" {
                { [DigitalOceanVPC] } | Should -Not -Throw
            }
        }

        Context "Default constructor" {
            It "2 - Should create instance with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc | Should -Not -BeNullOrEmpty
                $vpc.PSObject.TypeNames[0] | Should -Be 'DigitalOceanVPC'
            }

            It "3 - Should initialize Id to empty string with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Id | Should -Be ''
            }

            It "4 - Should initialize Name to empty string with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Name | Should -Be ''
            }

            It "5 - Should initialize IpRange to empty string with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.IpRange | Should -Be ''
            }

            It "6 - Should initialize Region to empty hashtable with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Region | Should -BeOfType [hashtable]
                $vpc.Region.Count | Should -Be 0
            }

            It "7 - Should initialize Description to empty string with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Description | Should -Be ''
            }

            It "8 - Should initialize Default to false with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Default | Should -Be $false
            }

            It "9 - Should initialize CreatedAt to MinValue with default constructor" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.CreatedAt | Should -Be ([datetime]::MinValue)
            }
        }

        Context "Constructor with PSCustomObject parameter" {
            BeforeAll {
                $script:vpcData = [PSCustomObject]@{
                    id = "5a4981aa-9653-4bd1-bef5-d6bff52042e4"
                    name = "production-vpc"
                    ip_range = "10.108.0.0/20"
                    description = "Production environment VPC"
                    default = $false
                    created_at = "2024-01-01T00:00:00Z"
                    region = [PSCustomObject]@{
                        name = "New York 1"
                        slug = "nyc1"
                        sizes = @("s-1vcpu-1gb", "s-2vcpu-2gb")
                        features = @("virtio", "private_networking")
                        available = $true
                    }
                }
            }

            It "10 - Should create instance with PSCustomObject constructor" {
                $vpc = [DigitalOceanVPC]::new($script:vpcData)
                $vpc | Should -Not -BeNullOrEmpty
                $vpc.PSObject.TypeNames[0] | Should -Be 'DigitalOceanVPC'
            }

            It "11 - Should set all properties correctly from PSCustomObject" {
                $vpc = [DigitalOceanVPC]::new($script:vpcData)

                $vpc.Id | Should -Be "5a4981aa-9653-4bd1-bef5-d6bff52042e4"
                $vpc.Name | Should -Be "production-vpc"
                $vpc.IpRange | Should -Be "10.108.0.0/20"
                $vpc.Description | Should -Be "Production environment VPC"
                $vpc.Default | Should -Be $false
                $vpc.CreatedAt | Should -Be ([datetime]"2024-01-01T00:00:00Z")
                $vpc.Region.name | Should -Be "New York 1"
                $vpc.Region.slug | Should -Be "nyc1"
                $vpc.Region.available | Should -Be $true
            }

            It "12 - Should handle null VPCObject gracefully with fallback to default values" {
                $vpc = [DigitalOceanVPC]::new($null)
                $vpc.Id | Should -Be ''
                $vpc.Name | Should -Be ''
                $vpc.IpRange | Should -Be ''
                $vpc.Description | Should -Be ''
                $vpc.Default | Should -Be $false
            }

            It "13 - Should handle VPCObject with null id property" {
                $nullIdVpc = [PSCustomObject]@{
                    id = $null
                    name = "test-vpc"
                }
                $vpc = [DigitalOceanVPC]::new($nullIdVpc)
                $vpc.Id | Should -Be ''
                $vpc.Name | Should -Be "test-vpc"
            }

            It "14 - Should handle VPCObject with null name property" {
                $nullNameVpc = [PSCustomObject]@{
                    id = "test-id"
                    name = $null
                }
                $vpc = [DigitalOceanVPC]::new($nullNameVpc)
                $vpc.Id | Should -Be "test-id"
                $vpc.Name | Should -Be ''
            }

            It "15 - Should handle VPCObject with invalid created_at property" {
                $invalidDateVpc = [PSCustomObject]@{
                    id = "test-id"
                    name = "test-vpc"
                    created_at = "invalid-date"
                }
                $vpc = [DigitalOceanVPC]::new($invalidDateVpc)
                $vpc.CreatedAt | Should -Be ([datetime]::MinValue)
            }

            It "16 - Should handle VPCObject with null region property" {
                $nullRegionVpc = [PSCustomObject]@{
                    id = "test-id"
                    name = "test-vpc"
                    region = $null
                }
                $vpc = [DigitalOceanVPC]::new($nullRegionVpc)
                $vpc.Region | Should -BeOfType [hashtable]
                $vpc.Region.Count | Should -Be 0
            }
        }

        Context "Methods" {
            It "17 - Should have ToString method" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.ToString() | Should -BeOfType [string]
            }

            It "18 - Should have ToHashtable method" {
                $vpc = [DigitalOceanVPC]::new()
                $hashtable = $vpc.ToHashtable()
                $hashtable | Should -BeOfType [hashtable]
            }

            It "19 - Should return correct string representation" {
                $vpcData = [PSCustomObject]@{
                    name = "production-vpc"
                    ip_range = "10.108.0.0/20"
                }
                $vpc = [DigitalOceanVPC]::new($vpcData)
                $vpc.ToString() | Should -Be "production-vpc (10.108.0.0/20)"
            }

            It "20 - Should return correct hashtable representation" {
                $vpcData = [PSCustomObject]@{
                    id = "test-id"
                    name = "test-vpc"
                    ip_range = "10.0.0.0/16"
                    default = $true
                }
                $vpc = [DigitalOceanVPC]::new($vpcData)
                $hashtable = $vpc.ToHashtable()

                $hashtable.Id | Should -Be "test-id"
                $hashtable.Name | Should -Be "test-vpc"
                $hashtable.IpRange | Should -Be "10.0.0.0/16"
                $hashtable.Default | Should -Be $true
            }
        }

        Context "Properties validation" {
            It "21 - Should have Id property of type string" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Id | Should -BeOfType [string]
            }

            It "22 - Should have Name property of type string" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Name | Should -BeOfType [string]
            }

            It "23 - Should have IpRange property of type string" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.IpRange | Should -BeOfType [string]
            }

            It "24 - Should have Region property of type hashtable" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Region | Should -BeOfType [hashtable]
            }

            It "25 - Should have Description property of type string" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Description | Should -BeOfType [string]
            }

            It "26 - Should have Default property of type bool" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.Default | Should -BeOfType [bool]
            }

            It "27 - Should have CreatedAt property of type datetime" {
                $vpc = [DigitalOceanVPC]::new()
                $vpc.CreatedAt | Should -BeOfType [datetime]
            }
        }
    }
}
