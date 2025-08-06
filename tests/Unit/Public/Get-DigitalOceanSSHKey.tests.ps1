$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'

    # Import the built module from output directory
    $builtModulePath = ".\output\module\PSDigitalOcean"
    Import-Module -Name $builtModulePath -Force

    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    # Restore original token
    if ($script:originalToken)
    {
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
    }
    else
    {
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $null, [System.EnvironmentVariableTarget]::User)
    }
}

Describe $DescribeName {

    Context "Parameter Validation" {

        It "1 - Should have SSHKeyName parameter with correct type" {
            $commandInfo = Get-Command Get-DigitalOceanSSHKey
            $sshKeyParam = $commandInfo.Parameters['SSHKeyName']
            $sshKeyParam | Should -Not -BeNullOrEmpty
            $sshKeyParam.ParameterType | Should -Be ([String])
        }

        It "2 - Should have correct output type attribute" {
            $commandInfo = Get-Command Get-DigitalOceanSSHKey
            $outputType = $commandInfo.OutputType.Name
            $outputType | Should -Be 'DigitalOcean.Account.SSHKeys'
        }

        It "3 - Should accept SSHKeyName parameter as optional" {
            $commandInfo = Get-Command Get-DigitalOceanSSHKey
            $sshKeyParam = $commandInfo.Parameters['SSHKeyName']
            $sshKeyParam.Attributes.Where({ $_.TypeId.Name -eq 'ParameterAttribute' }).Mandatory | Should -Be $false
        }
    }

    Context "Function Execution with Mocked API" {

        BeforeEach {
            # Mock the API call to return test data
            Mock Invoke-DigitalOceanAPI {
                return @{
                    ssh_keys = @(
                        @{
                            id          = 12345
                            name        = "test-key-1"
                            fingerprint = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
                            public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... test-key-1"
                        },
                        @{
                            id          = 67890
                            name        = "production-key"
                            fingerprint = "11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff:00"
                            public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... production-key"
                        }
                    )
                }
            } -ModuleName PSDigitalOcean
        }

        It "4 - Should call Invoke-DigitalOceanAPI with correct parameters" {
            Get-DigitalOceanSSHKey

            Assert-MockCalled Invoke-DigitalOceanAPI -Times 1 -ParameterFilter {
                $APIPath -eq "account/keys" -and
                $Parameters.per_page -eq 200
            } -ModuleName PSDigitalOcean
        }

        It "5 - Should return all SSH keys when no filter is specified" {
            $result = Get-DigitalOceanSSHKey

            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].name | Should -Be "test-key-1"
            $result[1].name | Should -Be "production-key"
        }

        It "6 - Should filter SSH keys by name when SSHKeyName is specified" {
            $result = Get-DigitalOceanSSHKey -SSHKeyName "test-key-1"

            $result | Should -Not -BeNullOrEmpty
            $result.name | Should -Be "test-key-1"
            $result.id | Should -Be 12345
        }

        It "7 - Should apply correct type name to returned objects" {
            $result = Get-DigitalOceanSSHKey

            $result[0].PSObject.TypeNames[0] | Should -Be 'DigitalOcean.Account.SSHKeys'
            $result[1].PSObject.TypeNames[0] | Should -Be 'DigitalOcean.Account.SSHKeys'
        }

        It "8 - Should write verbose messages when -Verbose is used" {
            $verboseOutput = @()
            Get-DigitalOceanSSHKey -Verbose 4>&1 | ForEach-Object {
                if ($_.GetType().Name -eq 'VerboseRecord')
                {
                    $verboseOutput += $_.Message
                }
            }

            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseOutput -join ' ' | Should -Match "Retrieving SSH keys"
            $verboseOutput -join ' ' | Should -Match "Found 2 SSH key"
        }

        It "9 - Should write warning when SSH key name is not found" {
            $warningOutput = @()
            Get-DigitalOceanSSHKey -SSHKeyName "non-existent-key" -WarningVariable warningOutput -WarningAction SilentlyContinue

            $warningOutput | Should -Not -BeNullOrEmpty
            $warningOutput -join ' ' | Should -Match "SSH key 'non-existent-key' not found"
        }
    }

    Context "Error Handling" {

        BeforeEach {
            # Mock API call to return empty response
            Mock Invoke-DigitalOceanAPI {
                return @{
                    ssh_keys = $null
                }
            } -ModuleName PSDigitalOcean
        }

        It "10 - Should handle empty SSH keys response gracefully" {
            $warningOutput = @()
            $result = Get-DigitalOceanSSHKey -WarningVariable warningOutput -WarningAction SilentlyContinue

            $result | Should -BeNullOrEmpty
            $warningOutput | Should -Not -BeNullOrEmpty
            $warningOutput -join ' ' | Should -Match "No SSH keys found"
        }
    }

    Context "API Error Handling" {

        BeforeEach {
            # Mock API call to throw an error
            Mock Invoke-DigitalOceanAPI {
                throw "API connection failed"
            } -ModuleName PSDigitalOcean
        }

        It "11 - Should handle API errors gracefully" {
            { Get-DigitalOceanSSHKey -ErrorAction Stop } | Should -Throw "Failed to retrieve SSH keys from DigitalOcean: API connection failed"
        }
    }

    Context "Help Documentation" {

        It "12 - Should have complete help documentation" {
            $help = Get-Help Get-DigitalOceanSSHKey

            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
            $help.Examples | Should -Not -BeNullOrEmpty
            $help.Examples.Count | Should -BeGreaterOrEqual 1
        }

        It "13 - Should have parameter help for SSHKeyName" {
            $help = Get-Help Get-DigitalOceanSSHKey -Parameter SSHKeyName

            $help.Name | Should -Be "SSHKeyName"
            $help.Description | Should -Not -BeNullOrEmpty
        }
    }
}
