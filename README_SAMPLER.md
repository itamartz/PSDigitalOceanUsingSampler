# How to add function to this module

## Create a Class file for the response and put the file in source\Classes

## Add Function to source\Public folder - and use the Class in your Return Object

## Create test file with the name of the <functionName>.tests.ps1 in tests\Public\
## add this in the start of the tests 
```powershell
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

}
```

## Create at least 85 % Code Coverage tests

## Version Update Methods - GitVersion-Based

```bash
### For patch version bump (1.0.0 → 1.0.1)
git commit -m "fix: resolve API timeout issue"

# For minor version bump (1.0.0 → 1.1.0)  
git commit -m "feature: add support for Droplet management"

# For major version bump (1.0.0 → 2.0.0)
git commit -m "breaking change: remove deprecated functions"

# To skip version bump
git commit -m "docs: update README +semver: skip"
```
