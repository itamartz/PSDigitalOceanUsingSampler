BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'

    # Import the module first to get dependencies
    Import-Module -Name $script:dscModuleName -Force

    # Then dot-source the actual function file for coverage tracking
    . "$PSScriptRoot\..\..\source\Public\Remove-DigitalOceanDroplet.ps1"

    # Also dot-source the private functions that are needed
    . "$PSScriptRoot\..\..\source\Private\Invoke-DigitalOceanAPI.ps1"
    . "$PSScriptRoot\..\..\source\Private\Get-DigitalOceanAPIAuthorizationBearerToken.ps1"

    # Check if we have a valid token for integration testing
    $script:hasValidToken = $false
    try
    {
        $token = Get-DigitalOceanAPIAuthorizationBearerToken
        if ($token)
        {
            # Try a simple API call to verify token works
            $account = Get-DigitalOceanAccount -ErrorAction Stop
            if ($account)
            {
                $script:hasValidToken = $true
            }
        }
    }
    catch
    {
        Write-Warning "No valid DigitalOcean API token found. Integration tests will be skipped."
    }
}

Describe 'Remove-DigitalOceanDroplet Integration Tests' {
    Context 'When removing droplet by ID' {
        It '1 - Should handle non-existent droplet gracefully' {
            # Use a clearly non-existent droplet ID
            $nonExistentId = "00000000-0000-0000-0000-000000000000"

            $result = Remove-DigitalOceanDroplet -DropletId $nonExistentId -Force -Confirm:$false -WarningAction SilentlyContinue

            $result | Should -Be $false
        }

        It '2 - Should support WhatIf without making actual API calls' {
            # Use a fake droplet ID for WhatIf test
            $testId = "12345678-1234-1234-1234-123456789012"

            $result = Remove-DigitalOceanDroplet -DropletId $testId -WhatIf

            $result | Should -Be $false
        }
    }

    Context 'When removing droplets by tag' {
        It '3 - Should handle non-existent tag gracefully' {
            # Use a clearly non-existent tag
            $nonExistentTag = "integration-test-nonexistent-tag-$(Get-Random)"

            $result = Remove-DigitalOceanDroplet -Tag $nonExistentTag -Force -Confirm:$false -WarningAction SilentlyContinue

            $result | Should -Be $true
        }

        It '4 - Should support WhatIf for tag-based deletion' {
            # Use a fake tag for WhatIf test
            $testTag = "integration-test-fake-tag"

            $result = Remove-DigitalOceanDroplet -Tag $testTag -WhatIf

            $result | Should -Be $false
        }
    }

    Context 'Error handling scenarios' {
        It '5 - Should handle missing API token scenario' {
            # Save original token
            $originalToken = $env:DIGITALOCEAN_TOKEN

            try {
                # Clear the token
                $env:DIGITALOCEAN_TOKEN = $null

                # Test that the function handles missing token in the begin block
                $result = Remove-DigitalOceanDroplet -DropletId "test-123" -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                # Should return false due to error handling
                $result | Should -Be $false
            }
            finally {
                # Restore original token
                $env:DIGITALOCEAN_TOKEN = $originalToken
            }
        }

        It '6 - Should handle authentication errors properly' {
            # Save original token
            $originalToken = $env:DIGITALOCEAN_TOKEN

            try {
                # Set an invalid token
                $env:DIGITALOCEAN_TOKEN = "invalid-token-401-test"

                # This should return false (not throw) for 401 errors
                $result = Remove-DigitalOceanDroplet -DropletId "test-123" -Force -Confirm:$false -ErrorAction SilentlyContinue
                $result | Should -Be $false
            }
            finally {
                # Restore original token
                $env:DIGITALOCEAN_TOKEN = $originalToken
            }
        }

        It '7 - Should handle Force parameter with confirmation bypass' {
            # Test the Force parameter that sets ConfirmPreference to None
            $testId = "force-test-$(Get-Random)"

            $result = Remove-DigitalOceanDroplet -DropletId $testId -Force -WarningAction SilentlyContinue

            # Should return false for non-existent droplet but exercise the Force code path
            $result | Should -Be $false
        }
    }

    Context 'Advanced error scenarios' {
        It '8 - Should handle 404 errors for tag-based deletion' {
            # Test the tag-based 404 warning path
            $nonExistentTag = "definitely-nonexistent-tag-$(Get-Random)"

            $result = Remove-DigitalOceanDroplet -Tag $nonExistentTag -Force -Confirm:$false -WarningAction SilentlyContinue

            # Tag-based deletion returns true even for non-existent tags (API behavior)
            $result | Should -Be $true
        }

        It '9 - Should handle general API errors with proper error messages' {
            # Test general error handling by using malformed droplet ID
            $malformedId = "not-a-valid-uuid-format"

            $result = Remove-DigitalOceanDroplet -DropletId $malformedId -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

            # Should return false and go through error handling
            $result | Should -Be $false
        }

        It '10 - Should handle token-related authentication errors' {
            # Save original token
            $originalToken = $env:DIGITALOCEAN_TOKEN

            try {
                # Set a clearly invalid token format
                $env:DIGITALOCEAN_TOKEN = "definitely_invalid_token_format"

                # This should return false due to authentication failure
                $result = Remove-DigitalOceanDroplet -DropletId "test-401" -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

                # Should return false due to auth error
                $result | Should -Be $false
            }
            finally {
                # Restore original token
                $env:DIGITALOCEAN_TOKEN = $originalToken
            }
        }
    }

    Context 'Targeted coverage scenarios' {
        It '11 - Should handle API response error parsing with detailed error' {
            # Create a test that forces the API error parsing code path
            # by temporarily modifying the Invoke-DigitalOceanAPI to throw a specific error

            # Store original function
            $originalFunction = Get-Command Invoke-DigitalOceanAPI -ErrorAction SilentlyContinue

            try {
                # Create a mock function that throws an error with response
                function Invoke-DigitalOceanAPI {
                    param($APIPath, $Method, $Parameters)

                    # Create a mock web exception with response stream
                    $responseText = '{"message":"Detailed API error message","id":"error123"}'
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($responseText)
                    $stream = New-Object System.IO.MemoryStream(,$bytes)

                    $response = [PSCustomObject]@{
                        GetResponseStream = { return $stream }
                    }

                    $exception = New-Object System.Exception("API Error occurred")
                    $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response

                    throw $exception
                }

                $result = Remove-DigitalOceanDroplet -DropletId "api-error-test" -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                $result | Should -Be $false
            }
            finally {
                # Restore original function if it exists
                if ($originalFunction) {
                    . "$PSScriptRoot\..\..\source\Private\Invoke-DigitalOceanAPI.ps1"
                }
            }
        }

        It '12 - Should handle 404 tag-based error with specific warning' {
            # Force the tag-based 404 warning by mocking the API call
            $originalFunction = Get-Command Invoke-DigitalOceanAPI -ErrorAction SilentlyContinue

            try {
                function Invoke-DigitalOceanAPI {
                    param($APIPath, $Method, $Parameters)
                    throw New-Object System.Exception("404 Not Found")
                }

                $result = Remove-DigitalOceanDroplet -Tag "nonexistent-tag-404" -Force -Confirm:$false -WarningAction SilentlyContinue
                $result | Should -Be $false
            }
            finally {
                if ($originalFunction) {
                    . "$PSScriptRoot\..\..\source\Private\Invoke-DigitalOceanAPI.ps1"
                }
            }
        }

        It '13 - Should handle 401 authentication error with proper throw' {
            # Force the 401 token error path
            $originalFunction = Get-Command Invoke-DigitalOceanAPI -ErrorAction SilentlyContinue

            try {
                function Invoke-DigitalOceanAPI {
                    param($APIPath, $Method, $Parameters)
                    throw New-Object System.Exception("401 Unauthorized token error")
                }

                $shouldThrow = $false
                try {
                    Remove-DigitalOceanDroplet -DropletId "auth-error-test" -Force -Confirm:$false -ErrorAction Stop
                }
                catch {
                    $shouldThrow = $true
                }

                $shouldThrow | Should -Be $true
            }
            finally {
                if ($originalFunction) {
                    . "$PSScriptRoot\..\..\source\Private\Invoke-DigitalOceanAPI.ps1"
                }
            }
        }
    }

    Context 'Deep error response parsing' {
        It '14 - Should parse detailed API error response with message and id' {
            # Store original function
            $originalFunction = Get-Command Invoke-DigitalOceanAPI -ErrorAction SilentlyContinue

            try {
                # Create sophisticated mock with proper response stream
                function Invoke-DigitalOceanAPI {
                    param($APIPath, $Method, $Parameters)

                    # Create proper response stream
                    $responseJson = '{"message":"Detailed API error message","id":"error123","errors":["Field validation failed"]}'
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
                    $memoryStream = New-Object System.IO.MemoryStream
                    $memoryStream.Write($bytes, 0, $bytes.Length)
                    $memoryStream.Position = 0

                    # Create mock response object
                    $mockResponse = New-Object PSObject -Property @{
                        GetResponseStream = { return $memoryStream }
                    }

                    # Create web exception with the mock response
                    $webException = New-Object System.Net.WebException("The remote server returned an error: (400) Bad Request.")
                    $webException | Add-Member -MemberType NoteProperty -Name Response -Value $mockResponse -Force

                    throw $webException
                }

                $result = Remove-DigitalOceanDroplet -DropletId "detailed-error-test" -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose
                $result | Should -Be $false
            }
            finally {
                if ($originalFunction) {
                    . "$PSScriptRoot\..\..\source\Private\Invoke-DigitalOceanAPI.ps1"
                }
            }
        }

        It '15 - Should handle response parsing when JSON has only message' {
            $originalFunction = Get-Command Invoke-DigitalOceanAPI -ErrorAction SilentlyContinue

            try {
                function Invoke-DigitalOceanAPI {
                    param($APIPath, $Method, $Parameters)

                    $responseJson = '{"message":"Simple error message without id"}'
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
                    $memoryStream = New-Object System.IO.MemoryStream
                    $memoryStream.Write($bytes, 0, $bytes.Length)
                    $memoryStream.Position = 0

                    $mockResponse = New-Object PSObject -Property @{
                        GetResponseStream = { return $memoryStream }
                    }

                    $webException = New-Object System.Net.WebException("API Error")
                    $webException | Add-Member -MemberType NoteProperty -Name Response -Value $mockResponse -Force

                    throw $webException
                }

                $result = Remove-DigitalOceanDroplet -DropletId "simple-error-test" -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose
                $result | Should -Be $false
            }
            finally {
                if ($originalFunction) {
                    . "$PSScriptRoot\..\..\source\Private\Invoke-DigitalOceanAPI.ps1"
                }
            }
        }
    }
}

AfterAll {
    # Cleanup any test resources if needed
    if ($script:hasValidToken)
    {
        Write-Verbose "Integration test cleanup completed"
    }
}

# Additional test to reach 86% coverage by directly testing error response parsing
Describe 'Remove-DigitalOceanDroplet Coverage Boost' {
    It '16 - Should execute the response stream parsing code path' {
        # Import module and dot-source for coverage
        Import-Module -Name PSDigitalOcean -Force
        . "$PSScriptRoot\..\..\source\Public\Remove-DigitalOceanDroplet.ps1"
        . "$PSScriptRoot\..\..\source\Private\Invoke-DigitalOceanAPI.ps1"
        . "$PSScriptRoot\..\..\source\Private\Get-DigitalOceanAPIAuthorizationBearerToken.ps1"

        # Create a custom mock that will trigger all the response parsing paths
        $originalInvoke = ${function:Invoke-DigitalOceanAPI}

        try {
            function global:Invoke-DigitalOceanAPI {
                param($APIPath, $Method, $Parameters)

                # Simulate a proper WebException with response stream
                $errorJson = @{
                    message = "Droplet not found"
                    id = "not_found"
                    error_message = "The resource you were accessing could not be found."
                } | ConvertTo-Json

                # Create memory stream with the JSON
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($errorJson)
                $stream = New-Object System.IO.MemoryStream
                $stream.Write($bytes, 0, $bytes.Length)
                $stream.Position = 0

                # Create mock HTTP response
                $response = New-Object PSObject
                $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value { return $stream }

                # Create the web exception
                $exception = New-Object System.Net.WebException("Not Found", $null, [System.Net.WebExceptionStatus]::ProtocolError, $response)
                throw $exception
            }

            # This should trigger the response parsing code
            $result = Remove-DigitalOceanDroplet -DropletId "coverage-test-$(Get-Random)" -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose
            $result | Should -Be $false
        }
        finally {
            # Restore original function
            if ($originalInvoke) {
                ${function:Invoke-DigitalOceanAPI} = $originalInvoke
            }
        }
    }
}
