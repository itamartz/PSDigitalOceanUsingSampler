$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'
    Import-Module -Name $script:dscModuleName -Force
    $script:originalToken = [Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", "test-token", [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $script:originalToken, [System.EnvironmentVariableTarget]::User)
}

InModuleScope $script:dscModuleName {
    Describe 'Default Constructors Coverage' {
        Context 'DigitalOceanImage default constructor' {
            It '1 - Should initialize all properties with default constructor' {
                $image = [DigitalOceanImage]::new()

                $image.Id | Should -Be 0
                $image.Name | Should -Be ''
                $image.Type | Should -Be ''
                $image.Distribution | Should -Be ''
                $image.Slug | Should -Be ''
                $image.Public | Should -Be $false
                $image.Regions | Should -Be @()
                $image.CreatedAt | Should -Be ([datetime]::MinValue)
                $image.Status | Should -Be ''
                $image.ErrorMessage | Should -Be ''
                $image.SizeGigabytes | Should -Be 0
                $image.MinDiskSize | Should -Be 0
                $image.Description | Should -Be ''
                $image.Tags | Should -BeOfType [hashtable]
            }
        }

        Context 'DigitalOceanSSHKey default constructor' {
            It '2 - Should initialize all properties with default constructor' {
                $sshKey = [DigitalOceanSSHKey]::new()

                $sshKey.Id | Should -Be 0
                $sshKey.Name | Should -Be ''
                $sshKey.Fingerprint | Should -Be ''
                $sshKey.PublicKey | Should -Be ''
            }
        }

        Context 'DigitalOceanSize default constructor' {
            It '3 - Should initialize all properties with default constructor' {
                $size = [DigitalOceanSize]::new()

                $size.Slug | Should -BeNullOrEmpty
                $size.Memory | Should -Be 0
            }
        }

        Context 'Root class constructor' {
            It '4 - Should create Root object' {
                # Create a Team object first
                $team = [Team]::new("team-uuid", "team-name")

                # Create Account object with proper constructor parameters
                $accountObj = [Account]::new(
                    25,                    # droplet_limit
                    5,                     # floating_ip_limit
                    "test@example.com",    # email
                    "Test User",           # name
                    "test-uuid",           # uuid
                    $true,                 # email_verified
                    "active",              # status
                    "",                    # status_message
                    $team                  # team
                )

                $root = [Root]::new($accountObj)
                $root.account | Should -Not -BeNullOrEmpty
            }
        }
    }
}
