$DescribeName = $MyInvocation.MyCommand.Name.Split('.')[0]

BeforeAll {
    $script:dscModuleName = 'PSDigitalOcean'

    Import-Module -Name $script:dscModuleName

    $DIGITALOCEAN_TOKEN = Get-Content -Path 'C:\Temp\DIGITALOCEAN_TOKEN.txt' -ErrorAction SilentlyContinue -Raw
    [Environment]::SetEnvironmentVariable("DIGITALOCEAN_TOKEN", $DIGITALOCEAN_TOKEN, [System.EnvironmentVariableTarget]::User)
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe -Name $DescribeName {
    Context 'When calling the function with string value' {
        It 'Get-DigitalOceanAPIAuthorizationBearerToken Should return Token from Environment Variable' {
            InModuleScope -ModuleName $dscModuleName {
                Get-DigitalOceanAPIAuthorizationBearerToken | Should -Not -BeNullOrEmpty
            }

        } #End It - 'Get-DigitalOceanAPIAuthorizationBearerToken Should return Token from Environment Variable'

    } #End Context
}
