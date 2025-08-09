$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)

    # Mock Invoke-RestMethod for API calls
    Mock Invoke-RestMethod -ModuleName PSDigitalOcean {
        return @{
            volume = @{
                id = "test-volume-id"
                name = "test-volume"
                size_gigabytes = 100
                region = @{ slug = "nyc1" }
                droplet_ids = @()
                created_at = "2023-01-01T00:00:00Z"
            }
        }
    }

    # Mock the DigitalOceanVolume class constructor
    if (-not ([System.Management.Automation.PSTypeName]'DigitalOceanVolume').Type)
    {
        Add-Type -TypeDefinition @"
            public class DigitalOceanVolume {
                public string Id { get; set; }
                public string Name { get; set; }
                public int SizeGigabytes { get; set; }

                public DigitalOceanVolume() { }
                public DigitalOceanVolume(object data) {
                    var dict = data as System.Collections.IDictionary;
                    if (dict != null) {
                        if (dict["id"] != null) {
                            Id = dict["id"].ToString();
                        }
                        if (dict["name"] != null) {
                            Name = dict["name"].ToString();
                        }
                        if (dict["size_gigabytes"] != null) {
                            int size;
                            if (int.TryParse(dict["size_gigabytes"].ToString(), out size)) {
                                SizeGigabytes = size;
                            }
                        }
                    }
                }
            }
"@
    }
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

Describe "$DescribeName" {
    Context "Parameter Validation" {
        It "1 - Should have mandatory Name parameter" {
            (Get-Command New-DigitalOceanVolume).Parameters['Name'].Attributes.Mandatory | Should -Be $true
        }

        It "2 - Should validate Name pattern correctly" {
            { New-DigitalOceanVolume -Name "INVALID-NAME" -SizeGigabytes 10 -Region "nyc1" -WhatIf } | Should -Throw
            { New-DigitalOceanVolume -Name "1invalid" -SizeGigabytes 10 -Region "nyc1" -WhatIf } | Should -Throw
            { New-DigitalOceanVolume -Name "valid-name" -SizeGigabytes 10 -Region "nyc1" -WhatIf } | Should -Not -Throw
        }

        It "3 - Should validate SizeGigabytes range" {
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 0 -Region "nyc1" -WhatIf } | Should -Throw
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 16385 -Region "nyc1" -WhatIf } | Should -Throw
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -WhatIf } | Should -Not -Throw
        }

        It "4 - Should validate FilesystemType values" {
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 10 -Region "nyc1" -FilesystemType "invalid" -WhatIf } | Should -Throw
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 10 -Region "nyc1" -FilesystemType "ext4" -WhatIf } | Should -Not -Throw
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 10 -Region "nyc1" -FilesystemType "xfs" -WhatIf } | Should -Not -Throw
        }

        It "5 - Should validate FilesystemLabel length" {
            $longLabel = "a" * 17
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 10 -Region "nyc1" -FilesystemType "ext4" -FilesystemLabel $longLabel -WhatIf } | Should -Throw
        }
    }

    Context "Parameter Sets" {
        It "6 - Should have CreateNew parameter set as default" {
            (Get-Command New-DigitalOceanVolume).DefaultParameterSet | Should -Be "CreateNew"
        }

        It "7 - Should allow FromSnapshot parameter set" {
            { New-DigitalOceanVolume -Name "test-volume" -Region "nyc1" -SnapshotId "test-snapshot-id" -WhatIf } | Should -Not -Throw
        }

        It "8 - Should not allow SizeGigabytes with FromSnapshot parameter set" {
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 10 -Region "nyc1" -SnapshotId "test-snapshot-id" -WhatIf } | Should -Throw
        }
    }

    Context "API Interaction" {
        BeforeEach {
            Mock -ModuleName PSDigitalOcean Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod
        }

        It "9 - Should call API with correct parameters for new volume" {
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{
                    volume = @{
                        id             = "test-volume-id"
                        name           = "test-volume"
                        size_gigabytes = 100
                        region         = @{
                            slug = "nyc1"
                        }
                        status         = "creating"
                    }
                }
            }

            New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1"

            Assert-MockCalled -ModuleName PSDigitalOcean Invoke-RestMethod -Exactly 1 -ParameterFilter {
                $Uri -eq "https://api.digitalocean.com/v2/volumes" -and $Method -eq "Post" -and $Body -like "*test-volume*"
            }
        }

        It "10 - Should call API with correct parameters for volume from snapshot" {
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{
                    volume = @{
                        id = "test-volume-id"
                        name = "test-volume"
                        snapshot_id = "test-snapshot-id"
                        region = @{ slug = "nyc1" }
                        status = "creating"
                    }
                }
            }

            New-DigitalOceanVolume -Name "test-volume" -Region "nyc1" -SnapshotId "test-snapshot-id"

            Assert-MockCalled -ModuleName PSDigitalOcean Invoke-RestMethod -Exactly 1 -ParameterFilter {
                $Uri -eq "https://api.digitalocean.com/v2/volumes" -and $Method -eq "Post" -and $Body -like "*test-snapshot-id*"
            }
        }

        It "11 - Should include filesystem parameters in API call" {
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{
                    volume = @{
                        id = "test-volume-id"
                        name = "test-volume"
                        size_gigabytes = 100
                        filesystem_type = "ext4"
                        filesystem_label = "testlabel"
                        region = @{ slug = "nyc1" }
                        status = "creating"
                    }
                }
            }

            New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -FilesystemType "ext4" -FilesystemLabel "testlabel"

            Assert-MockCalled -ModuleName PSDigitalOcean Invoke-RestMethod -Exactly 1 -ParameterFilter {
                $Body -like "*ext4*" -and $Body -like "*testlabel*"
            }
        }

        It "12 - Should include optional parameters in API call" {
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{
                    volume = @{
                        id = "test-volume-id"
                        name = "test-volume"
                        size_gigabytes = 100
                        description = "Test description"
                        tags = @("tag1", "tag2")
                        region = @{ slug = "nyc1" }
                        status = "creating"
                    }
                }
            }

            $tags = @("tag1", "tag2")
            New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -Description "Test description" -Tags $tags

            Assert-MockCalled -ModuleName PSDigitalOcean Invoke-RestMethod -Exactly 1 -ParameterFilter {
                $Body -like "*Test description*" -and $Body -like "*tag1*" -and $Body -like "*tag2*"
            }
        }
    }

    Context "Return Value" {
        BeforeEach {
            Mock -ModuleName PSDigitalOcean Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
        }

        It "13 - Should return DigitalOceanVolume object on success" {
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{
                    volume = @{
                        id = "test-volume-id"
                        name = "test-volume"
                        size_gigabytes = 100
                        region = @{ slug = "nyc1" }
                        status = "creating"
                        description = ""
                        filesystem_type = ""
                        filesystem_label = ""
                        droplet_ids = @()
                        tags = @()
                        created_at = "2023-01-01T00:00:00Z"
                    }
                }
            }

            $result = New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1"

            $result.GetType().Name | Should -Be "DigitalOceanVolume"
            $result.Name | Should -Be "test-volume"
            $result.SizeGigabytes | Should -Be 100
        }

        It "14 - Should return null on API failure" {
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{ volume = $null }
            }

            $result = New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -WarningAction SilentlyContinue

            $result | Should -BeNullOrEmpty
        }
    }

    Context "Error Handling" {
        It "15 - Should handle missing API token" {
            # Clear the environment variable temporarily for this test
            $originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
            [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $null, [System.EnvironmentVariableTarget]::User)

            try
            {
                # The function should either throw an error or return null when no token is available
                $result = $null
                $errorOccurred = $false

                try
                {
                    $result = New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                }
                catch
                {
                    $errorOccurred = $true
                    $_.Exception.Message | Should -Match "token"
                }

                # Either an error occurred OR the result is null (both are acceptable for missing token)
                ($errorOccurred -or ($null -eq $result)) | Should -Be $true
            }
            finally
            {
                # Restore the token
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $originalToken, [System.EnvironmentVariableTarget]::User)
            }
        }

        It "16 - Should handle API errors gracefully" {
            Mock -ModuleName PSDigitalOcean Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod { throw "API Error" }

            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -ErrorAction Stop } | Should -Throw
        }
    }

    Context "ShouldProcess Support" {
        BeforeEach {
            Mock -ModuleName PSDigitalOcean Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{
                    volume = @{
                        id = "test-volume-id"
                        name = "test-volume"
                        size_gigabytes = 100
                        region = @{ slug = "nyc1" }
                        status = "creating"
                    }
                }
            }
        }

        It "17 - Should support WhatIf parameter" {
            New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -WhatIf

            Assert-MockCalled -ModuleName PSDigitalOcean Invoke-RestMethod -Exactly 0
        }

        It "18 - Should support Confirm parameter" {
            # This test verifies the parameter exists, actual confirmation testing requires user interaction
            { New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -Confirm:$false } | Should -Not -Throw
        }
    }

    Context "Verbose Output" {
        BeforeEach {
            Mock -ModuleName PSDigitalOcean Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
            Mock -ModuleName PSDigitalOcean Invoke-RestMethod {
                return @{
                    volume = @{
                        id = "test-volume-id"
                        name = "test-volume"
                        size_gigabytes = 100
                        region = @{ slug = "nyc1" }
                        status = "creating"
                    }
                }
            }
        }

        It "19 - Should write verbose messages when verbose is enabled" {
            $verboseOutput = New-DigitalOceanVolume -Name "test-volume" -SizeGigabytes 100 -Region "nyc1" -Verbose 4>&1

            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseOutput | Where-Object { $_ -like "*Starting New-DigitalOceanVolume function*" } | Should -Not -BeNullOrEmpty
        }
    }

    Context "Help Documentation" {
        It "20 - Should have complete help documentation" {
            $help = Get-Help New-DigitalOceanVolume

            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
            $help.Examples | Should -Not -BeNullOrEmpty
            # Check that examples contain multiple scenarios by looking for specific content
            $exampleText = $help.Examples.Example.Code -join " "
            $exampleText | Should -Match "my-volume"
            $exampleText | Should -Match "database-storage"
            $exampleText | Should -Match "backup-restore"
            $exampleText | Should -Match "SnapshotId"
        }

        It "21 - Should have parameter help for all parameters" {
            $help = Get-Help New-DigitalOceanVolume -Parameter Name
            $help.Description | Should -Not -BeNullOrEmpty

            $help = Get-Help New-DigitalOceanVolume -Parameter SizeGigabytes
            $help.Description | Should -Not -BeNullOrEmpty

            $help = Get-Help New-DigitalOceanVolume -Parameter Region
            $help.Description | Should -Not -BeNullOrEmpty
        }
    }
}
