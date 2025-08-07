$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    if ($script:originalToken)
    {
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
    }
    else
    {
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $null, [System.EnvironmentVariableTarget]::User)
    }
}

Describe "$DescribeName Unit Tests" -Tag 'Unit' {

    Context "1 - Function Structure and Help" {

        It "1 - Should have the correct function name" {
            Get-Command Get-DigitalOceanVPC | Should -Not -BeNullOrEmpty
        }

        It "2 - Should have proper help documentation" {
            $help = Get-Help Get-DigitalOceanVPC
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
            $help.Examples | Should -Not -BeNullOrEmpty
        }

        It "3 - Should have valid examples in help" {
            $help = Get-Help Get-DigitalOceanVPC -Examples
            $help.Examples.Example.Count | Should -BeGreaterThan 0
            foreach ($example in $help.Examples.Example)
            {
                $example.Code | Should -Not -BeNullOrEmpty
                $example.Remarks | Should -Not -BeNullOrEmpty
            }
        }

        It "4 - Should have proper output type defined" {
            $command = Get-Command Get-DigitalOceanVPC
            $command.OutputType.Type.Name | Should -Contain 'DigitalOceanVPC'
        }
    }

    Context "2 - Function Execution without API calls" {

        BeforeEach {
            Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                return @{
                    vpcs = @(
                        @{
                            id         = "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"
                            name       = "test-vpc-1"
                            ip_range   = "10.116.0.0/20"
                            region     = @{
                                name = "New York 1"
                                slug = "nyc1"
                            }
                            created_at = "2023-01-01T00:00:00Z"
                        },
                        @{
                            id         = "550e8400-e29b-41d4-a716-446655440000"
                            name       = "production-vpc"
                            ip_range   = "10.117.0.0/20"
                            region     = @{
                                name = "San Francisco 1"
                                slug = "sfo1"
                            }
                            created_at = "2023-02-01T00:00:00Z"
                        }
                    )
                    meta = @{
                        total = 2
                    }
                }
            } -ModuleName $script:dscModuleName
        }

        It "5 - Should return DigitalOceanVPC class objects when VPCs exist" {
            $result = Get-DigitalOceanVPC
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].GetType().Name | Should -Be 'DigitalOceanVPC'
            $result[0].Id | Should -Be "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"
            $result[0].Name | Should -Be "test-vpc-1"
            $result[1].Name | Should -Be "production-vpc"
        }

        It "6 - Should call Invoke-DigitalOceanAPI with correct parameters" {
            Get-DigitalOceanVPC
            Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Times 1 -ModuleName $script:dscModuleName -ParameterFilter {
                $APIPath -eq "vpcs" -and
                $Parameters.per_page -eq 200
            }
        }

        It "7 - Should output each VPC as DigitalOceanVPC class objects" {
            $result = Get-DigitalOceanVPC
            $result | Should -HaveCount 2
            $result[0].GetType().Name | Should -Be 'DigitalOceanVPC'
            $result[1].GetType().Name | Should -Be 'DigitalOceanVPC'
        }
    }

    Context "3 - Error Handling" {

        It "8 - Should handle API errors gracefully" {
            Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                throw "API Error: Unauthorized"
            } -ModuleName $script:dscModuleName

            { Get-DigitalOceanVPC } | Should -Throw
            Assert-MockCalled -CommandName Invoke-DigitalOceanAPI -Times 1 -ModuleName $script:dscModuleName
        }

        It "9 - Should show warning and return empty array when no VPCs found" {
            Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                return @{
                    vpcs = $null
                }
            } -ModuleName $script:dscModuleName

            Mock -CommandName Write-Warning -MockWith {} -ModuleName $script:dscModuleName

            $result = Get-DigitalOceanVPC
            $result | Should -BeNullOrEmpty
            Assert-MockCalled -CommandName Write-Warning -Times 1 -ModuleName $script:dscModuleName -ParameterFilter {
                $Message -eq "No VPCs found in your DigitalOcean account"
            }
        }

        It "10 - Should handle empty VPC array" {
            Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                return @{
                    vpcs = @()
                }
            } -ModuleName $script:dscModuleName

            $result = Get-DigitalOceanVPC
            $result | Should -BeNullOrEmpty
        }
    }

    Context "4 - Verbose Output" {

        It "11 - Should write verbose messages when verbose is enabled" {
            Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                return @{
                    vpcs = @(
                        @{
                            id   = "test-id"
                            name = "test-vpc"
                        }
                    )
                }
            } -ModuleName $script:dscModuleName

            Mock -CommandName Write-Verbose -MockWith {} -ModuleName $script:dscModuleName

            Get-DigitalOceanVPC -Verbose

            Assert-MockCalled -CommandName Write-Verbose -ModuleName $script:dscModuleName -ParameterFilter {
                $Message -eq "Retrieving VPCs from DigitalOcean account"
            }

            Assert-MockCalled -CommandName Write-Verbose -ModuleName $script:dscModuleName -ParameterFilter {
                $Message -eq "Found 1 VPCs"
            }
        }
    }

    Context "5 - Integration with Pipeline" {

        It "12 - Should work with pipeline operations" {
            Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                return @{
                    vpcs = @(
                        @{ name = "test-vpc-1"; id = "id1" },
                        @{ name = "production-vpc"; id = "id2" },
                        @{ name = "staging-vpc"; id = "id3" }
                    )
                }
            } -ModuleName $script:dscModuleName

            $allResults = @(Get-DigitalOceanVPC)
            $allResults.Count | Should -Be 3

            $filteredResult = @($allResults | Where-Object { $_.name -eq "production-vpc" })
            $filteredResult | Should -Not -BeNullOrEmpty
            $filteredResult.Count | Should -Be 1
            $filteredResult[0].name | Should -Be "production-vpc"
        }

        It "13 - Should work with Select-Object operations" {
            Mock -CommandName Invoke-DigitalOceanAPI -MockWith {
                return @{
                    vpcs = @(
                        @{
                            name     = "test-vpc"
                            id       = "test-id"
                            ip_range = "10.116.0.0/20"
                            region   = @{ slug = "nyc1" }
                        }
                    )
                }
            } -ModuleName $script:dscModuleName

            $selectedResult = Get-DigitalOceanVPC | Select-Object Name, IpRange
            $selectedResult | Should -Not -BeNullOrEmpty
            $selectedResult.Name | Should -Be "test-vpc"
            $selectedResult.IpRange | Should -Be "10.116.0.0/20"
        }
    }
}
