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

    # Get token directly using the same method as the private function
    $token = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

    # Check if we have a valid token
    $script:hasValidToken = $false

    if ($token -and $token -ne "test-token")
    {
        try
        {
            # Test API connectivity
            $account = Get-DigitalOceanAccount -ErrorAction Stop
            if ($account)
            {
                # Create a test volume for deletion tests
                $script:testVolumeName = "integration-test-volume-$(Get-Random)"
                $script:testRegion = "nyc1"

                $script:testVolume = New-DigitalOceanVolume -Name $script:testVolumeName -Region $script:testRegion -Size 1 -Description "Integration test volume" -ErrorAction Stop
                $script:hasValidToken = $true
            }
        }
        catch
        {
            $script:hasValidToken = $false
        }
    }
}

AfterAll {
    # Clean up any remaining test volumes
    if ($script:hasValidToken -and $script:testVolume)
    {
        try
        {
            # Attempt to remove the test volume if it still exists
            Remove-DigitalOceanVolume -VolumeId $script:testVolume.id -Force -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-Warning "Failed to clean up test volume: $_"
        }
    }
}

Describe 'Remove-DigitalOceanVolume Integration Tests' -Tag 'Integration' {

    Context 'When removing volume by ID' {

        It '1 - Should successfully remove volume by ID' {
            # Check token availability first
            $token = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

            if (-not $token -or $token -eq "test-token")
            {
                Set-ItResult -Skipped -Because "No valid DigitalOcean token available"
                return
            }

            # If we don't have a test volume from BeforeAll, create one
            if (-not $script:testVolume)
            {
                $script:testVolumeName = "integration-test-volume-$(Get-Random)"
                $script:testRegion = "nyc1"
                $script:testVolume = New-DigitalOceanVolume -Name $script:testVolumeName -Region $script:testRegion -Size 1 -Description "Integration test volume"
            }

            # Arrange - we now have a test volume
            $volumeId = $script:testVolume.id

            # Act
            $result = Remove-DigitalOceanVolume -VolumeId $volumeId -Force

            # Assert
            $result | Should -Be $true

            # Verify volume is actually deleted
            Start-Sleep -Seconds 2  # Brief wait for API consistency
            { Get-DigitalOceanVolume -VolumeId $volumeId } | Should -Throw
        }
    }

    Context 'When removing volume by name and region' {

        It '2 - Should successfully remove volume by name and region' {
            # Check token availability first
            $token = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

            if (-not $token -or $token -eq "test-token")
            {
                Set-ItResult -Skipped -Because "No valid DigitalOcean token available"
                return
            }

            # Arrange - create another test volume
            $testVolumeName2 = "integration-test-volume-2-$(Get-Random)"
            $testRegion = "nyc1"
            $testVolume2 = New-DigitalOceanVolume -Name $testVolumeName2 -Region $testRegion -Size 1 -Description "Integration test volume 2"

            # Act
            $result = Remove-DigitalOceanVolume -Name $testVolumeName2 -Region $testRegion -Force

            # Assert
            $result | Should -Be $true

            # Verify volume is actually deleted
            Start-Sleep -Seconds 2  # Brief wait for API consistency
            $volumes = Get-DigitalOceanVolume
            $volumes | Where-Object { $_.name -eq $testVolumeName2 } | Should -BeNullOrEmpty
        }
    }

    Context 'When attempting to remove non-existent volume' {

        It '3 - Should handle non-existent volume ID gracefully' {
            # Check token availability first
            $token = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

            if (-not $token -or $token -eq "test-token")
            {
                Set-ItResult -Skipped -Because "No valid DigitalOcean token available"
                return
            }

            # Arrange
            $fakeVolumeId = "00000000-0000-0000-0000-000000000000"

            # Act & Assert - Function should handle gracefully without throwing
            $result = Remove-DigitalOceanVolume -VolumeId $fakeVolumeId -Force -WarningAction SilentlyContinue

            # The function should return False for non-existent volumes
            $result | Should -Be $false
        }
    }

    Context 'When using WhatIf parameter' {

        It '4 - Should support WhatIf without making actual changes' {
            # Check token availability first
            $token = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

            if (-not $token -or $token -eq "test-token")
            {
                Set-ItResult -Skipped -Because "No valid DigitalOcean token available"
                return
            }

            # Arrange - create a volume that should remain after WhatIf
            $testVolumeName3 = "integration-test-whatif-$(Get-Random)"
            $testRegion = "nyc1"
            $testVolume3 = New-DigitalOceanVolume -Name $testVolumeName3 -Region $testRegion -Size 1 -Description "Integration test WhatIf volume"

            # Act
            $result = Remove-DigitalOceanVolume -VolumeId $testVolume3.id -WhatIf

            # Assert - volume should still exist
            $existingVolume = Get-DigitalOceanVolume -VolumeId $testVolume3.id
            $existingVolume | Should -Not -BeNullOrEmpty
            $existingVolume.id | Should -Be $testVolume3.id

            # Clean up
            Remove-DigitalOceanVolume -VolumeId $testVolume3.id -Force
        }
    }
}
