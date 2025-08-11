$DescribeName = 'Remove-DigitalOceanDroplet.Coverage'
BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

InModuleScope 'PSDigitalOcean' {
    Describe 'Remove-DigitalOceanDroplet Coverage Boost' {
        BeforeAll {
            # Mock dependencies
            Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "mock-token" }
        }

        Context 'Complex Error Response Parsing' {
            It '1 - Should execute all API error response parsing commands' {
                Mock Invoke-DigitalOceanAPI {
                    # Create a proper memory stream with JSON
                    $errorJson = '{"message":"API validation failed","id":"validation_error_123"}'
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($errorJson)
                    $memStream = New-Object System.IO.MemoryStream
                    $memStream.Write($bytes, 0, $bytes.Length)
                    $memStream.Position = 0

                    # Create proper mock response object that supports GetResponseStream
                    $mockResponse = New-Object -TypeName PSObject
                    $mockResponse | Add-Member -MemberType ScriptMethod -Name 'GetResponseStream' -Value {
                        return $memStream
                    }

                    # Create exception with Response property
                    $ex = New-Object System.Exception("API Error")
                    $ex | Add-Member -MemberType NoteProperty -Name 'Response' -Value $mockResponse
                    throw $ex
                }

                $result = Remove-DigitalOceanDroplet -DropletId "error-parsing-test" -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose
                $result | Should -Be $false
            }

            It '2 - Should handle tag-based 404 to trigger warning message' {
                Mock Invoke-DigitalOceanAPI {
                    throw New-Object System.Exception("404 Not Found - tag not found")
                }

                $result = Remove-DigitalOceanDroplet -Tag "missing-tag-test" -Force -Confirm:$false -WarningAction SilentlyContinue
                $result | Should -Be $false
            }

            It '3 - Should trigger 401 authentication error path' {
                Mock Invoke-DigitalOceanAPI {
                    throw New-Object System.Exception("401 Unauthorized access token invalid")
                }

                { Remove-DigitalOceanDroplet -DropletId "auth-fail-test" -Force -Confirm:$false -ErrorAction Stop } | Should -Throw
            }
        }
    }
}

AfterAll {
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
}
