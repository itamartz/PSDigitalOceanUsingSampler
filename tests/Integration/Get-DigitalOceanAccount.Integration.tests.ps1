$script:dscModuleName = 'PSDigitalOcean'

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name $script:dscModuleName -ListAvailable))
        {
            # In case we are importing the module from output folder
            $moduleRootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
            $moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath "output/module/$script:dscModuleName"
            Import-Module -Name $moduleManifestPath -Force -ErrorAction Stop
        }
        else
        {
            Import-Module -Name $script:dscModuleName -Force -ErrorAction Stop
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please install the module or make sure it is available in the module path.'
    }
}

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force

    # Store original token
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

    # Check if we have a valid token for integration tests
    $script:hasValidToken = $false
    if ($script:originalToken -and $script:originalToken -ne "test-token")
    {
        $script:hasValidToken = $true
        Write-Information "Found valid DigitalOcean token for integration tests" -InformationAction Continue
    }
    else
    {
        Write-Information "No valid DigitalOcean token found - skipping integration tests" -InformationAction Continue
        Write-Information "Set DIGITALOCEAN_TOKEN environment variable to run integration tests" -InformationAction Continue
    }
}

AfterAll {
    # Restore original token
    if ($script:originalToken)
    {
        [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
    }
}

Describe 'Get-DigitalOceanAccount Integration Tests' -Tag 'Integration' {

    Context 'When called with valid API token' {

        It '1 - Should return account information successfully' -Skip:(-not $script:hasValidToken) {
            # Act
            $result = Get-DigitalOceanAccount

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'Account'
            $result.email | Should -Not -BeNullOrEmpty
            $result.uuid | Should -Not -BeNullOrEmpty
            $result.email_verified | Should -BeOfType 'bool'
            $result.status | Should -Not -BeNullOrEmpty
            # Note: status_message can be empty for active accounts
        }

        It '2 - Should return valid email format' -Skip:(-not $script:hasValidToken) {
            # Act
            $result = Get-DigitalOceanAccount

            # Assert
            $result.email | Should -Match '^[^@]+@[^@]+\.[^@]+$'
        }

        It '3 - Should return valid UUID format' -Skip:(-not $script:hasValidToken) {
            # Act
            $result = Get-DigitalOceanAccount

            # Assert
            $result.uuid | Should -Match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
        }

        It '4 - Should have valid status values' -Skip:(-not $script:hasValidToken) {
            # Act
            $result = Get-DigitalOceanAccount

            # Assert
            $result.status | Should -BeIn @('active', 'warning', 'locked')
        }

        It '5 - Should have team information if account is part of a team' -Skip:(-not $script:hasValidToken) {
            # Act
            $result = Get-DigitalOceanAccount

            # Assert
            if ($result.team)
            {
                $result.team.GetType().Name | Should -Be 'Team'
                $result.team.name | Should -Not -BeNullOrEmpty
                $result.team.uuid | Should -Match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
            }
        }

        It '6 - Should handle API rate limiting gracefully' -Skip:(-not $script:hasValidToken) {
            # Act & Assert - Multiple rapid calls should not throw errors
            for ($i = 1; $i -le 3; $i++)
            {
                { Get-DigitalOceanAccount } | Should -Not -Throw
                Start-Sleep -Milliseconds 100  # Small delay to avoid rate limiting
            }
        }

        It '7 - Should return consistent data across multiple calls' -Skip:(-not $script:hasValidToken) {
            # Act
            $result1 = Get-DigitalOceanAccount
            Start-Sleep -Milliseconds 500
            $result2 = Get-DigitalOceanAccount

            # Assert - Account data should be consistent
            $result1.email | Should -Be $result2.email
            $result1.uuid | Should -Be $result2.uuid
            $result1.email_verified | Should -Be $result2.email_verified
        }
    }

    Context 'When called with invalid API token' {

        BeforeAll {
            # Set invalid token for these tests
            [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "invalid-token-12345", [System.EnvironmentVariableTarget]::User)
        }

        AfterAll {
            # Restore original token
            if ($script:originalToken)
            {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
            }
        }

        It '8 - Should throw appropriate error for invalid token' {
            # Act & Assert
            { Get-DigitalOceanAccount } | Should -Throw -ExpectedMessage "*401*"
        }
    }

    Context 'When called without API token' {

        BeforeAll {
            # Remove token for these tests
            [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $null, [System.EnvironmentVariableTarget]::User)
        }

        AfterAll {
            # Restore original token
            if ($script:originalToken)
            {
                [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
            }
        }

        It '9 - Should throw appropriate error when no token is set' {
            # Act & Assert
            { Get-DigitalOceanAccount } | Should -Throw -ExpectedMessage "*DIGITALOCEAN_TOKEN*"
        }
    }
}
