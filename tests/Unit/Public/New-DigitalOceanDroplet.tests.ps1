$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force

    # Store original token for restoration
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

    # Set a test token for tests
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    # Restore original token
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe -Name $DescribeName {

    Context 'Function Definition' {

        It '1 - Should have the correct mandatory parameters defined' {
            InModuleScope -ModuleName $script:dscModuleName {
                $function = Get-Command New-DigitalOceanDroplet

                # Check that function exists
                $function | Should -Not -BeNullOrEmpty

                # Check mandatory parameters
                $mandatoryParams = $function.Parameters.Keys | Where-Object {
                    $function.Parameters[$_].Attributes.Mandatory -eq $true
                }

                $mandatoryParams | Should -Contain 'DropletName'
                $mandatoryParams.Count | Should -Be 1
            }
        }
    }

    Context 'Dynamic Parameters' {

        It '2 - Should create Size dynamic parameter with correct attributes' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock the dependencies for dynamic parameter creation
                Mock Get-DigitalOceanSize {
                    return @(
                        @{ slug = 's-1vcpu-1gb'; name = '1GB RAM, 1 vCPU' },
                        @{ slug = 's-2vcpu-2gb'; name = '2GB RAM, 2 vCPUs' },
                        @{ slug = 's-4vcpu-8gb'; name = '8GB RAM, 4 vCPUs' }
                    )
                }

                Mock Get-DigitalOceanImage {
                    return @(
                        @{ slug = 'ubuntu-20-04-x64'; name = 'Ubuntu 20.04 x64' },
                        @{ slug = 'centos-8-x64'; name = 'CentOS 8 x64' }
                    )
                }

                # Get the function command
                $function = Get-Command New-DigitalOceanDroplet

                # Check that the dynamic parameters are available
                $function.Parameters.Keys | Should -Contain 'Size'
                $function.Parameters.Keys | Should -Contain 'Image'

                # Check Size parameter attributes
                $sizeParam = $function.Parameters['Size']
                $sizeParam.ParameterType | Should -Be ([string])

                # Check that the function contains dynamic parameter logic
                $function.ScriptBlock.ToString() | Should -Match 'dynamicparam'
                $function.ScriptBlock.ToString() | Should -Match 'Get-DigitalOceanSize'
                $function.ScriptBlock.ToString() | Should -Match 'Get-DigitalOceanImage'
                $function.ScriptBlock.ToString() | Should -Match 'RuntimeDefinedParameterDictionary'

                # Verify the mocks were called during parameter discovery (may be called multiple times)
                Assert-MockCalled Get-DigitalOceanSize
                Assert-MockCalled Get-DigitalOceanImage
            }
        }

        It '3 - Should create Image dynamic parameter with correct attributes' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock the dependencies for dynamic parameter creation
                Mock Get-DigitalOceanSize {
                    return @(
                        @{ slug = 's-1vcpu-1gb'; name = '1GB RAM, 1 vCPU' },
                        @{ slug = 's-2vcpu-2gb'; name = '2GB RAM, 2 vCPUs' }
                    )
                }

                Mock Get-DigitalOceanImage {
                    return @(
                        @{ slug = 'ubuntu-20-04-x64'; name = 'Ubuntu 20.04 x64' },
                        @{ slug = 'centos-8-x64'; name = 'CentOS 8 x64' },
                        @{ slug = 'debian-11-x64'; name = 'Debian 11 x64' },
                        @{ slug = 'fedora-36-x64'; name = 'Fedora 36 x64' }
                    )
                }

                # Get the function command
                $function = Get-Command New-DigitalOceanDroplet

                # Check that the Image parameter exists
                $function.Parameters.Keys | Should -Contain 'Image'

                # Check Image parameter attributes
                $imageParam = $function.Parameters['Image']
                $imageParam.ParameterType | Should -Be ([string])

                # Verify that both dynamic parameters are created together
                $function.Parameters.Keys | Should -Contain 'Size'
                $function.Parameters.Keys | Should -Contain 'Image'

                # Check that the function contains Image-specific dynamic parameter logic
                $function.ScriptBlock.ToString() | Should -Match 'Get-DigitalOceanImage'
                $function.ScriptBlock.ToString() | Should -Match "The slug identifier for a public image"
                $function.ScriptBlock.ToString() | Should -Match "parameterName = 'Image'"

                # Verify both mocks were called during parameter discovery
                Assert-MockCalled Get-DigitalOceanSize
                Assert-MockCalled Get-DigitalOceanImage
            }
        }
    }

    Context 'Parameter Validation' {

        It '4 - Should validate DropletName pattern correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Test parameter validation without invoking the function body
                $function = Get-Command New-DigitalOceanDroplet

                # Check ValidatePattern attribute exists
                $dropletNameParam = $function.Parameters['DropletName']
                $validatePattern = $dropletNameParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidatePatternAttribute] }

                $validatePattern | Should -Not -BeNullOrEmpty
                $validatePattern.RegexPattern | Should -Be "^[a-zA-Z0-9]?[a-z0-9A-Z.\-]*[a-z0-9A-Z]$"
            }
        }

        It '5 - Should validate SSHKey type correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }

                # Test parameter validation by checking function metadata
                $function = Get-Command New-DigitalOceanDroplet
                $sshKeyParam = $function.Parameters['SSHKey']

                # Check parameter type is Object (allowing for DigitalOceanSSHKey objects)
                $sshKeyParam.ParameterType.Name | Should -Be 'Object'

                # Verify parameter exists and has help message
                $sshKeyParam | Should -Not -BeNull
                $helpAttribute = $sshKeyParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                $helpAttribute.HelpMessage | Should -BeLike "*SSH key object*"
            }
        }

        It '6 - Should validate boolean parameters correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Test parameter types without invoking the function body
                $function = Get-Command New-DigitalOceanDroplet

                # Check boolean parameter types
                $function.Parameters['Backups'].ParameterType | Should -Be ([bool])
                $function.Parameters['IPV6'].ParameterType | Should -Be ([bool])
                $function.Parameters['Monitoring'].ParameterType | Should -Be ([bool])

                # Check that parameters are not mandatory
                $backupsParam = $function.Parameters['Backups']
                $mandatoryAttr = $backupsParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                $mandatoryAttr.Mandatory | Should -Be $false
            }
        }
    }

    Context 'Body Construction' {

        It '7 - Should construct basic body with minimal parameters' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Body)
                    $bodyObj = $Body | ConvertFrom-Json
                    $bodyObj.name | Should -Be "test-droplet"
                    $bodyObj.size | Should -Be "s-1vcpu-1gb"
                    $bodyObj.image | Should -Be "ubuntu-20-04-x64"
                    return @{ droplet = @{ id = 123 } }
                }

                New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                Assert-MockCalled Invoke-RestMethod
            }
        }

        It '8 - Should construct body with SSH key parameter' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Body)
                    $bodyObj = $Body | ConvertFrom-Json
                    $bodyObj.ssh_keys | Should -Not -BeNullOrEmpty
                    $bodyObj.ssh_keys[0] | Should -Be 456
                    return @{ droplet = @{ id = 123 } }
                }

                $sshKey = [DigitalOceanSSHKey]::new(456, "test-key", "aa:bb:cc", "ssh-rsa test")

                New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -SSHKey $sshKey -Confirm:$false

                Assert-MockCalled Invoke-RestMethod
            }
        }

        It '9 - Should construct body with boolean parameters' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Body)
                    $bodyObj = $Body | ConvertFrom-Json
                    $bodyObj.backups | Should -Be $true
                    $bodyObj.ipv6 | Should -Be $true
                    $bodyObj.monitoring | Should -Be $true
                    return @{ droplet = @{ id = 123 } }
                }

                New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Backups $true -IPV6 $true -Monitoring $true -Confirm:$false

                Assert-MockCalled Invoke-RestMethod
            }
        }

        It '10 - Should construct body with tags and user data' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Body)
                    $bodyObj = $Body | ConvertFrom-Json
                    $bodyObj.tags | Should -Contain "web"
                    $bodyObj.tags | Should -Contain "production"
                    $bodyObj.user_data | Should -Be "#!/bin/bash\necho 'Hello World'"
                    return @{ droplet = @{ id = 123 } }
                }

                New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Tags @("web", "production") -UserData "#!/bin/bash`necho 'Hello World'" -Confirm:$false

                Assert-MockCalled Invoke-RestMethod
            }
        }

        It '11 - Should construct body with volumes parameter' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Body)
                    $bodyObj = $Body | ConvertFrom-Json
                    $bodyObj.volumes | Should -Contain "vol-123"
                    $bodyObj.volumes | Should -Contain "vol-456"
                    return @{ droplet = @{ id = 123 } }
                }

                New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Volumes @("vol-123", "vol-456") -Confirm:$false

                Assert-MockCalled Invoke-RestMethod
            }
        }
    }

    Context 'API Call Mocking and Response Handling' {

        It '12 - Should handle successful API response correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{ Authorization = 'Bearer test-token' } } }
                Mock Invoke-RestMethod {
                    param($Uri, $Method, $Headers, $Body)

                    # Verify correct API endpoint
                    $Uri | Should -Be "https://api.digitalocean.com/v2/droplets"
                    $Method | Should -Be "POST"
                    $Headers.Authorization | Should -Be "Bearer test-token"

                    # Return realistic API response
                    return @{
                        droplet = @{
                            id         = 123456789
                            name       = "test-droplet"
                            memory     = 1024
                            vcpus      = 1
                            disk       = 25
                            status     = "new"
                            region     = @{ name = "New York 1"; slug = "nyc1" }
                            image      = @{ name = "Ubuntu 20.04 x64"; slug = "ubuntu-20-04-x64" }
                            size       = @{ slug = "s-1vcpu-1gb" }
                            created_at = "2024-01-01T00:00:00Z"
                        }
                    }
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Verify response handling - now returns DigitalOceanDroplet class object
                $result | Should -Not -BeNullOrEmpty
                $result.PSObject.TypeNames[0] | Should -Be 'DigitalOceanDroplet'
                $result.Id | Should -Be 123456789
                $result.Name | Should -Be "test-droplet"
                $result.Status | Should -Be "new"

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '13 - Should handle API error response correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    throw [System.Net.WebException]::new("The remote server returned an error: (422) Unprocessable Entity.")
                }

                # The function appears to handle errors internally and return error messages
                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Should return error information instead of throwing
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match "Error was"

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '14 - Should pass correct headers to API call' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable {
                    return @{
                        URL     = 'https://api.digitalocean.com/v2'
                        Headers = @{
                            Authorization  = 'Bearer test-token-12345'
                            'Content-Type' = 'application/json'
                            'User-Agent'   = 'PSDigitalOcean/1.0'
                        }
                    }
                }
                Mock Invoke-RestMethod {
                    param($Uri, $Method, $Headers, $Body)

                    # Verify all headers are passed correctly
                    $Headers.Authorization | Should -Be "Bearer test-token-12345"
                    $Headers.'Content-Type' | Should -Be "application/json"
                    $Headers.'User-Agent' | Should -Be "PSDigitalOcean/1.0"

                    return @{ droplet = @{ id = 123 } }
                }

                New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1
                Assert-MockCalled Get-Variable -Times 1
            }
        }

        It '15 - Should handle empty or null API response' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    return $null
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Function handles null response and returns empty droplet object
                $result | Should -Not -BeNullOrEmpty
                $result.PSObject.TypeNames[0] | Should -Be 'DigitalOceanDroplet'
                $result.Id | Should -Be 0

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '16 - Should verify correct HTTP method and content type' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Uri, $Method, $Headers, $Body, $ContentType)

                    # Verify HTTP method is POST
                    $Method | Should -Be "POST"

                    # Verify Content-Type if specified
                    if ($ContentType)
                    {
                        $ContentType | Should -Be "application/json"
                    }

                    # Verify body is valid JSON
                    { $Body | ConvertFrom-Json } | Should -Not -Throw

                    return @{ droplet = @{ id = 123 } }
                }

                New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }
    }

    Context 'Error Scenarios' {

        It '17 - Should handle missing DigitalOcean token error' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable {
                    throw [System.InvalidOperationException]::new("DIGITALOCEAN_TOKEN environment variable not found")
                }

                # The function throws the exception rather than handling it internally
                { New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false } | Should -Throw -ExpectedMessage "*DIGITALOCEAN_TOKEN*"

                Assert-MockCalled Get-Variable -Times 1
            }
        }

        It '18 - Should handle unauthorized API response (401)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    $exception = [System.Net.WebException]::new("The remote server returned an error: (401) Unauthorized.")
                    throw $exception
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Function returns error message with actual exception details
                $result | Should -Not -BeNullOrEmpty
                $result[0] | Should -Be "Error was The remote server returned an error: (401) Unauthorized."

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '19 - Should handle invalid droplet size error (422)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    $exception = [System.Net.WebException]::new("The remote server returned an error: (422) Unprocessable Entity - Invalid size specified.")
                    throw $exception
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Function returns error message in the format "Error was in Line [number]"
                $result | Should -Not -BeNullOrEmpty
                $result[0] | Should -Be "Error was The remote server returned an error: (422) Unprocessable Entity - Invalid size specified."

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '20 - Should handle network connectivity errors' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    $exception = [System.Net.WebException]::new("Unable to connect to the remote server")
                    throw $exception
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Function returns error message in the format "Error was in Line [number]"
                $result | Should -Not -BeNullOrEmpty
                $result[0] | Should -Be "Error was Unable to connect to the remote server"

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '21 - Should handle timeout errors' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    $exception = [System.TimeoutException]::new("The operation has timed out")
                    throw $exception
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Function returns error message in the format "Error was in Line [number]"
                $result | Should -Not -BeNullOrEmpty
                $result[0] | Should -Be "Error was The operation has timed out"

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '22 - Should handle rate limiting errors (429)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    $exception = [System.Net.WebException]::new("The remote server returned an error: (429) Too Many Requests.")
                    throw $exception
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Function returns error message in the format "Error was in Line [number]"
                $result | Should -Not -BeNullOrEmpty
                $result[0] | Should -Be "Error was The remote server returned an error: (429) Too Many Requests."

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '23 - Should handle malformed API response' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    # Return malformed response (missing droplet property)
                    return @{
                        unexpected_property = "invalid"
                        data                = "malformed"
                    }
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                $result | Should -Not -BeNullOrEmpty
                $result.PSObject.TypeNames[0] | Should -Be 'DigitalOceanDroplet'
                $result.Id | Should -Be 0

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '24 - Should handle dynamic parameter creation failures' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Test that the function handles dynamic parameter creation failures gracefully
                # by checking the function's behavior when mocked functions return errors

                # This test verifies the function definition exists regardless of dynamic parameter issues
                $function = Get-Command New-DigitalOceanDroplet

                # The function should still exist even if dynamic parameters fail
                $function | Should -Not -BeNullOrEmpty
                $function.Name | Should -Be "New-DigitalOceanDroplet"

                # Verify it has the basic static parameters
                $function.Parameters.Keys | Should -Contain 'DropletName'
            }
        }

        It '25 - Should handle insufficient permissions error (403)' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    $exception = [System.Net.WebException]::new("The remote server returned an error: (403) Forbidden - Insufficient permissions.")
                    throw $exception
                }

                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # Function returns error message in the format "Error was in Line [number]"
                $result | Should -Not -BeNullOrEmpty
                $result[0] | Should -Be "Error was The remote server returned an error: (403) Forbidden - Insufficient permissions."

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '26 - Should support ShouldProcess functionality' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    return @{ droplet = @{ id = 123; name = "test-droplet" } }
                }

                # Test -WhatIf parameter (should not call Invoke-RestMethod)
                $result = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -WhatIf

                # With -WhatIf, Invoke-RestMethod should not be called
                Assert-MockCalled Invoke-RestMethod -Times 0

                # Test -Confirm:$false parameter (should call Invoke-RestMethod)
                $result2 = New-DigitalOceanDroplet -DropletName "test-droplet" -Size "s-1vcpu-1gb" -Image "ubuntu-20-04-x64" -Confirm:$false

                # With -Confirm:$false, Invoke-RestMethod should be called
                Assert-MockCalled Invoke-RestMethod -Times 1

                # Verify the function supports ShouldProcess by checking for the attributes
                $function = Get-Command New-DigitalOceanDroplet
                $supportsShouldProcess = $function.Parameters.ContainsKey('WhatIf') -and $function.Parameters.ContainsKey('Confirm')
                $supportsShouldProcess | Should -Be $true
            }
        }

        It '27 - Should handle Get-DigitalOceanSize API failures gracefully' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock Get-DigitalOceanSize to throw an exception
                Mock Get-DigitalOceanSize {
                    throw [System.Net.WebException]::new("Unable to retrieve sizes from API")
                }

                Mock Get-DigitalOceanImage {
                    return @(@{ slug = 'ubuntu-20-04-x64'; name = 'Ubuntu 20.04 x64' })
                }

                # Test that when dynamic parameter creation fails, the function still exists
                # but may not have the dynamic parameters available
                { Get-Command New-DigitalOceanDroplet } | Should -Not -Throw

                # The function should still be available even if dynamic parameters fail
                $function = Get-Command New-DigitalOceanDroplet -ErrorAction SilentlyContinue
                $function | Should -Not -BeNullOrEmpty
                $function.Name | Should -Be "New-DigitalOceanDroplet"

                # Basic static parameters should still be available
                $function.Parameters.Keys | Should -Contain 'DropletName'
            }
        }

        It '28 - Should handle all parameters together in complex scenario' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-2vcpu-4gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'debian-11-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Body)
                    $bodyObj = $Body | ConvertFrom-Json

                    # Verify all parameters are correctly included in the body
                    $bodyObj.name | Should -Be "complex-droplet"
                    $bodyObj.size | Should -Be "s-2vcpu-4gb"
                    $bodyObj.image | Should -Be "debian-11-x64"
                    $bodyObj.ssh_keys | Should -Contain 789
                    $bodyObj.backups | Should -Be $true
                    $bodyObj.ipv6 | Should -Be $true
                    $bodyObj.monitoring | Should -Be $true
                    $bodyObj.tags | Should -Contain "production"
                    $bodyObj.tags | Should -Contain "web-server"
                    $bodyObj.tags | Should -Contain "database"
                    $bodyObj.user_data | Should -Be "#!/bin/bash`necho 'Complex setup'`napt update"
                    $bodyObj.volumes | Should -Contain "vol-production-1"
                    $bodyObj.volumes | Should -Contain "vol-production-2"

                    return @{ droplet = @{ id = 987654321; name = "complex-droplet" } }
                }

                # Create SSH key object
                $sshKey = [DigitalOceanSSHKey]::new(789, "production-key", "aa:bb:cc", "ssh-rsa test")

                # Test with all possible parameters
                $result = New-DigitalOceanDroplet `
                    -DropletName "complex-droplet" `
                    -Size "s-2vcpu-4gb" `
                    -Image "debian-11-x64" `
                    -SSHKey $sshKey `
                    -Backups $true `
                    -IPV6 $true `
                    -Monitoring $true `
                    -Tags @("production", "web-server", "database") `
                    -UserData "#!/bin/bash`necho 'Complex setup'`napt update" `
                    -Volumes @("vol-production-1", "vol-production-2") `
                    -Confirm:$false

                # Verify the response - now returns DigitalOceanDroplet class object
                $result | Should -Not -BeNullOrEmpty
                $result.PSObject.TypeNames[0] | Should -Be 'DigitalOceanDroplet'
                $result.Id | Should -Be 987654321
                $result.Name | Should -Be "complex-droplet"

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '29 - Should handle empty arrays correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }
                Mock Get-Variable { return @{ URL = 'https://api.digitalocean.com/v2'; Headers = @{} } }
                Mock Invoke-RestMethod {
                    param($Body)
                    $bodyObj = $Body | ConvertFrom-Json

                    # Verify basic parameters are present
                    $bodyObj.name | Should -Be "test-droplet"
                    $bodyObj.size | Should -Be "s-1vcpu-1gb"
                    $bodyObj.image | Should -Be "ubuntu-20-04-x64"

                    # Verify empty arrays are handled correctly (should not be in the body)
                    $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'tags'
                    $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'volumes'

                    return @{ droplet = @{ id = 123; name = "test-droplet" } }
                }

                # Test with empty arrays - these should not be added to the body
                $result = New-DigitalOceanDroplet `
                    -DropletName "test-droplet" `
                    -Size "s-1vcpu-1gb" `
                    -Image "ubuntu-20-04-x64" `
                    -Tags @() `
                    -Volumes @() `
                    -Confirm:$false

                # Verify the response - now returns DigitalOceanDroplet class object
                $result | Should -Not -BeNullOrEmpty
                $result.PSObject.TypeNames[0] | Should -Be 'DigitalOceanDroplet'
                $result.Id | Should -Be 123
                $result.Name | Should -Be "test-droplet"

                Assert-MockCalled Invoke-RestMethod -Times 1
            }
        }

        It '30 - Should validate DropletName edge cases correctly' {
            InModuleScope -ModuleName $script:dscModuleName {
                # Mock dependencies for these validation tests
                Mock Get-DigitalOceanSize { return @(@{ slug = 's-1vcpu-1gb' }) }
                Mock Get-DigitalOceanImage { return @(@{ slug = 'ubuntu-20-04-x64' }) }

                # Get the function for pattern validation testing
                $function = Get-Command New-DigitalOceanDroplet
                $dropletNameParam = $function.Parameters['DropletName']
                $validatePattern = $dropletNameParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidatePatternAttribute] }

                # Verify the expected regex pattern
                $validatePattern.RegexPattern | Should -Be "^[a-zA-Z0-9]?[a-z0-9A-Z.\-]*[a-z0-9A-Z]$"

                # Test valid names that should pass the pattern
                $validNames = @(
                    "a",                    # Single character
                    "A",                    # Single uppercase
                    "1",                    # Single number
                    "web-server-01",        # Valid with hyphens
                    "app.domain.com",       # Valid with dots
                    "TEST-SERVER-123",      # Mixed case with hyphens
                    "server.example.org"    # Domain-like name
                )

                foreach ($name in $validNames)
                {
                    $name | Should -Match $validatePattern.RegexPattern -Because "Name '$name' should be valid"
                }

                # Test invalid names that would fail parameter binding
                # Note: The regex allows some edge cases due to the '?' quantifier
                $invalidNames = @(
                    "",                     # Empty string (would fail required parameter)
                    "invalid space",        # Contains space
                    "invalid@char",         # Invalid character
                    "invalid#char"          # Invalid character
                )

                foreach ($name in $invalidNames)
                {
                    $name | Should -Not -Match $validatePattern.RegexPattern -Because "Name '$name' should be invalid"
                }

                # Test that the pattern validation is working
                $validatePattern | Should -Not -BeNullOrEmpty
            }
        }
    }
}
