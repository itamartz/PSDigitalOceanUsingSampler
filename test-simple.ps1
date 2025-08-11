BeforeAll {
    Write-Host "Test setup"
}

Describe "Simple Test" {
    It "Should work" {
        $true | Should -Be $true
    }
}
