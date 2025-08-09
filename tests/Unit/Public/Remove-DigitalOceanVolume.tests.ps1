BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

Describe 'Remove-DigitalOceanVolume' {
    Context 'Parameter Validation' {
        It '1 - Should have mandatory VolumeId parameter in ById parameter set' {
            $function = Get-Command Remove-DigitalOceanVolume
            $parameter = $function.Parameters['VolumeId']
            $parameter.Attributes.Mandatory | Should -Be $true
            $parameter.Attributes.ParameterSetName | Should -Contain 'ById'
        }

        It '2 - Should have mandatory Name parameter in ByName parameter set' {
            $function = Get-Command Remove-DigitalOceanVolume
            $parameter = $function.Parameters['Name']
            $parameter.Attributes.Mandatory | Should -Be $true
            $parameter.Attributes.ParameterSetName | Should -Contain 'ByName'
        }

        It '3 - Should have mandatory Region parameter in ByName parameter set' {
            $function = Get-Command Remove-DigitalOceanVolume
            $parameter = $function.Parameters['Region']
            $parameter.Attributes.Mandatory | Should -Be $true
            $parameter.Attributes.ParameterSetName | Should -Contain 'ByName'
        }

        It '4 - Should have Force parameter as optional switch' {
            $function = Get-Command Remove-DigitalOceanVolume
            $parameter = $function.Parameters['Force']
            $parameter.SwitchParameter | Should -Be $true
            $parameter.Attributes.Mandatory | Should -Be $false
        }

        It '5 - Should have ById as default parameter set' {
            $function = Get-Command Remove-DigitalOceanVolume
            $function.DefaultParameterSet | Should -Be 'ById'
        }

        It '6 - Should support ShouldProcess' {
            $function = Get-Command Remove-DigitalOceanVolume
            $cmdletBinding = $function.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.SupportsShouldProcess | Should -Be $true
        }

        It '7 - Should have ConfirmImpact set to High' {
            $function = Get-Command Remove-DigitalOceanVolume
            $cmdletBinding = $function.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Parameter Set ById' {
        BeforeEach {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
                Mock Invoke-RestMethod { return $null }
            }
        }

        It '8 - Should call API with correct URI for volume ID' {
            InModuleScope $script:dscModuleName {
                Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Method -eq 'Delete' -and
                    $Uri -eq 'https://api.digitalocean.com/v2/volumes/test-volume-id'
                }
            }
        }

        It '9 - Should URL encode volume ID' {
            InModuleScope $script:dscModuleName {
                Remove-DigitalOceanVolume -VolumeId "test volume with spaces" -Force -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq 'https://api.digitalocean.com/v2/volumes/test%20volume%20with%20spaces'
                }
            }
        }

        It '10 - Should include correct headers' {
            InModuleScope $script:dscModuleName {
                Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Headers['Authorization'] -eq 'Bearer test-token' -and
                    $Headers['Content-Type'] -eq 'application/json'
                }
            }
        }
    }

    Context 'Parameter Set ByName' {
        BeforeEach {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
                Mock Invoke-RestMethod { return $null }
            }
        }

        It '11 - Should call API with correct URI for name and region' {
            InModuleScope $script:dscModuleName {
                Remove-DigitalOceanVolume -Name "test-volume" -Region "nyc1" -Force -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Method -eq 'Delete' -and
                    $Uri -eq 'https://api.digitalocean.com/v2/volumes?name=test-volume&region=nyc1'
                }
            }
        }

        It '12 - Should URL encode name and region parameters' {
            InModuleScope $script:dscModuleName {
                Remove-DigitalOceanVolume -Name "test volume" -Region "new york 1" -Force -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq 'https://api.digitalocean.com/v2/volumes?name=test%20volume&region=new%20york%201'
                }
            }
        }

        It '13 - Should require both Name and Region parameters' {
            # Test that Region parameter is mandatory in ByName parameter set
            $function = Get-Command Remove-DigitalOceanVolume
            $regionParam = $function.Parameters['Region']
            $regionParam.ParameterSets['ByName'].IsMandatory | Should -Be $true

            # Test that Name parameter is mandatory in ByName parameter set
            $nameParam = $function.Parameters['Name']
            $nameParam.ParameterSets['ByName'].IsMandatory | Should -Be $true
        }
    }

    Context 'Return Values' {
        BeforeEach {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
            }
        }

        It '14 - Should return true when deletion succeeds' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod { return $null }

                $result = Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false
                $result | Should -Be $true
            }
        }

        It '15 - Should return false when user cancels with WhatIf' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod { return $null }

                $result = Remove-DigitalOceanVolume -VolumeId "test-volume-id" -WhatIf
                $result | Should -Be $false
            }
        }

        It '16 - Should return false when volume not found (404)' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod {
                    $exception = New-Object System.Net.WebException("404 Not Found")
                    throw $exception
                }

                $result = Remove-DigitalOceanVolume -VolumeId "non-existent-volume" -Force -Confirm:$false -WarningAction SilentlyContinue
                $result | Should -Be $false
            }
        }
    }

    Context 'Error Handling' {
        BeforeEach {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
            }
        }

        It '17 - Should handle missing API token' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return $null }

                { Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false } | Should -Throw "*API token not found*"
            }
        }

        It '18 - Should handle API errors gracefully' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod {
                    throw "API Error: Internal Server Error"
                }

                $result = Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false -ErrorAction SilentlyContinue
                $result | Should -Be $false
            }
        }

        It '19 - Should handle 401 unauthorized errors' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod {
                    throw "401 Unauthorized"
                }

                { Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false } | Should -Throw "*401 Unauthorized*"
            }
        }

        It '20 - Should show warning for volume not found by ID' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod {
                    $exception = New-Object System.Net.WebException("404 Not Found")
                    throw $exception
                }

                $warningMessages = @()
                Remove-DigitalOceanVolume -VolumeId "non-existent-id" -Force -Confirm:$false -WarningVariable warningMessages -WarningAction SilentlyContinue

                $warningMessages | Should -Not -BeNullOrEmpty
                $warningMessages[0] -match "Volume with ID 'non-existent-id' was not found" | Should -Be $true
            }
        }

        It '21 - Should show warning for volume not found by name' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod {
                    $exception = New-Object System.Net.WebException("404 Not Found")
                    throw $exception
                }

                $warningMessages = @()
                Remove-DigitalOceanVolume -Name "non-existent" -Region "nyc1" -Force -Confirm:$false -WarningVariable warningMessages -WarningAction SilentlyContinue

                $warningMessages | Should -Not -BeNullOrEmpty
                $warningMessages[0] -match "Volume 'non-existent' was not found in region 'nyc1'" | Should -Be $true
            }
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
                Mock Invoke-RestMethod { return $null }
            }
        }

        It '22 - Should support WhatIf parameter for ID-based deletion' {
            InModuleScope $script:dscModuleName {
                $result = Remove-DigitalOceanVolume -VolumeId "test-volume-id" -WhatIf

                Assert-MockCalled Invoke-RestMethod -Times 0
                $result | Should -Be $false
            }
        }

        It '23 - Should support WhatIf parameter for name-based deletion' {
            InModuleScope $script:dscModuleName {
                $result = Remove-DigitalOceanVolume -Name "test-volume" -Region "nyc1" -WhatIf

                Assert-MockCalled Invoke-RestMethod -Times 0
                $result | Should -Be $false
            }
        }

        It '24 - Should call API when Force is used' {
            InModuleScope $script:dscModuleName {
                Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }
    }

    Context 'Verbose Output' {
        BeforeEach {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
                Mock Invoke-RestMethod { return $null }
            }
        }

        It '25 - Should write verbose messages when verbose is enabled' {
            InModuleScope $script:dscModuleName {
                $verboseMessages = @()
                Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false -Verbose -OutVariable verboseMessages 4>&1

                # Check that verbose messages were generated during execution
                $verboseMessages | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'API Error Response Parsing' {
        BeforeEach {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return "test-token" }
            }
        }

        It '26 - Should parse API error response with message' {
            InModuleScope $script:dscModuleName {
                Mock Invoke-RestMethod {
                    throw "Failed to remove DigitalOcean volume: Volume is currently attached to a droplet"
                }

                $errorMessages = @()
                Remove-DigitalOceanVolume -VolumeId "attached-volume" -Force -Confirm:$false -ErrorVariable errorMessages -ErrorAction SilentlyContinue

                $errorMessages | Should -Not -BeNullOrEmpty
                $errorMessages[0].Exception.Message | Should -Match "Volume is currently attached to a droplet"
            }
        }
    }

    Context 'Help Documentation' {
        It '27 - Should have complete help documentation' {
            $help = Get-Help Remove-DigitalOceanVolume -Full
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
            $help.Examples | Should -Not -BeNullOrEmpty
            $help.Examples.example.Count | Should -BeGreaterThan 3
        }

        It '28 - Should have parameter help for all parameters' {
            $help = Get-Help Remove-DigitalOceanVolume -Full
            $help.Parameters.Parameter | Where-Object { $_.Name -eq 'VolumeId' } | Should -Not -BeNullOrEmpty
            $help.Parameters.Parameter | Where-Object { $_.Name -eq 'Name' } | Should -Not -BeNullOrEmpty
            $help.Parameters.Parameter | Where-Object { $_.Name -eq 'Region' } | Should -Not -BeNullOrEmpty
            $help.Parameters.Parameter | Where-Object { $_.Name -eq 'Force' } | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Output Type' {
        It '29 - Should have correct output type attribute' {
            $function = Get-Command Remove-DigitalOceanVolume
            $outputType = $function.OutputType
            $outputType.Type.Name | Should -Contain 'Boolean'
        }
    }

    Context 'Aliases' {
        It '30 - Should support Id alias for VolumeId parameter' {
            $function = Get-Command Remove-DigitalOceanVolume
            $parameter = $function.Parameters['VolumeId']
            $parameter.Aliases | Should -Contain 'Id'
        }

        It '31 - Should support VolumeName alias for Name parameter' {
            $function = Get-Command Remove-DigitalOceanVolume
            $parameter = $function.Parameters['Name']
            $parameter.Aliases | Should -Contain 'VolumeName'
        }
    }

    Context 'Additional Coverage Tests' {
        It '32 - Should handle missing API token in ByName parameter set' {
            InModuleScope $script:dscModuleName {
                Mock Get-DigitalOceanAPIAuthorizationBearerToken { return $null }

                { Remove-DigitalOceanVolume -Name "test-volume" -Region "nyc1" -Force -Confirm:$false } | Should -Throw "*API token not found*"
            }
        }

        It '33 - Should handle API error response with detailed error parsing' {
            InModuleScope $script:dscModuleName {
                # Create a more complex mock that simulates an actual WebException with response
                Mock Invoke-RestMethod {
                    $webException = [System.Net.WebException]::new("The remote server returned an error: (422) Unprocessable Entity.")

                    # Mock response object
                    $response = New-Object PSObject
                    Add-Member -InputObject $response -MemberType ScriptMethod -Name "GetResponseStream" -Value {
                        $jsonResponse = '{"message":"Volume is currently attached to a droplet","errors":["Cannot delete attached volume"]}'
                        $bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
                        return [System.IO.MemoryStream]::new($bytes)
                    }

                    # Add response to exception
                    Add-Member -InputObject $webException -MemberType NoteProperty -Name "Response" -Value $response -Force

                    throw $webException
                }

                $errorMessages = @()
                $verboseMessages = @()
                Remove-DigitalOceanVolume -VolumeId "attached-volume" -Force -Confirm:$false -ErrorVariable errorMessages -ErrorAction SilentlyContinue -Verbose -OutVariable verboseMessages 4>&1

                # Check that the function handled the error and returned false
                $errorMessages | Should -Not -BeNullOrEmpty
                # The error should be about the HTTP error, but verbose should show API parsing worked
                ($verboseMessages -join " ") | Should -BeLike "*Full API Response:*"
            }
        }

        It '34 - Should handle malformed API error response gracefully' {
            InModuleScope $script:dscModuleName {
                # Mock an exception with response that returns invalid JSON
                Mock Invoke-RestMethod {
                    $webException = [System.Net.WebException]::new("Server Error")

                    $response = New-Object PSObject
                    Add-Member -InputObject $response -MemberType ScriptMethod -Name "GetResponseStream" -Value {
                        $invalidJson = 'invalid json response'
                        $bytes = [System.Text.Encoding]::UTF8.GetBytes($invalidJson)
                        return [System.IO.MemoryStream]::new($bytes)
                    }

                    Add-Member -InputObject $webException -MemberType NoteProperty -Name "Response" -Value $response -Force

                    throw $webException
                }

                $result = Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false -ErrorAction SilentlyContinue -Verbose
                $result | Should -Be $false
            }
        }

        It '35 - Should handle empty API error response body' {
            InModuleScope $script:dscModuleName {
                # Mock an exception with response that returns empty body
                Mock Invoke-RestMethod {
                    $webException = [System.Net.WebException]::new("Server Error")

                    $response = New-Object PSObject
                    Add-Member -InputObject $response -MemberType ScriptMethod -Name "GetResponseStream" -Value {
                        $emptyResponse = ''
                        $bytes = [System.Text.Encoding]::UTF8.GetBytes($emptyResponse)
                        return [System.IO.MemoryStream]::new($bytes)
                    }

                    Add-Member -InputObject $webException -MemberType NoteProperty -Name "Response" -Value $response -Force

                    throw $webException
                }

                $result = Remove-DigitalOceanVolume -VolumeId "test-volume-id" -Force -Confirm:$false -ErrorAction SilentlyContinue
                $result | Should -Be $false
            }
        }
    }
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
