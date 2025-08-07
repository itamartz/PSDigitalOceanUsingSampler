# Debug script to test the exact null scenarios for coverage
Import-Module ".\output\module\PSDigitalOcean\1.2.0\PSDigitalOcean.psd1" -Force

# Test scenario 1: Team object with null uuid and name
Write-Host "=== Testing team with null uuid/name ===" -ForegroundColor Yellow

# Create a mock response exactly like our test
$teamObject = [PSCustomObject]@{
    uuid       = $null
    name       = $null
    created_at = "2024-01-01T00:00:00Z"
}

$obj = [PSCustomObject]@{
    droplet_limit     = 25
    floating_ip_limit = 5
    email             = "test@example.com"
    name              = "Test User"
    uuid              = "user-uuid"
    email_verified    = $true
    status            = "active"
    status_message    = "Active user"
    team              = $teamObject
}

Write-Host "Testing null conditions directly:" -ForegroundColor Cyan
Write-Host "obj.team exists: $($null -ne $obj.team)" -ForegroundColor White
Write-Host "obj.team.uuid is null: $($null -eq $obj.team.uuid)" -ForegroundColor White
Write-Host "obj.team.name is null: $($null -eq $obj.team.name)" -ForegroundColor White

Write-Host "Testing the exact conditional expressions:" -ForegroundColor Cyan
$uuid_result = $(if ($null -ne $obj.team.uuid)
    {
        $obj.team.uuid 
    }
    else
    {
        "EMPTY_STRING_DEFAULT" 
    })
$name_result = $(if ($null -ne $obj.team.name)
    {
        $obj.team.name 
    }
    else
    {
        "EMPTY_STRING_DEFAULT" 
    })

Write-Host "UUID conditional result: '$uuid_result'" -ForegroundColor White
Write-Host "Name conditional result: '$name_result'" -ForegroundColor White

# Test scenario 2: Status message null
Write-Host "`n=== Testing status_message null ===" -ForegroundColor Yellow

$obj2 = [PSCustomObject]@{
    droplet_limit     = 25
    floating_ip_limit = 5
    email             = "test2@example.com"
    name              = "Test User 2"
    uuid              = "user-uuid-2"
    email_verified    = $true
    status            = "active"
    status_message    = $null
    team              = [PSCustomObject]@{
        uuid = "team-uuid"
        name = "Team Name"
    }
}

Write-Host "obj2.status_message is null: $($null -eq $obj2.status_message)" -ForegroundColor White
$status_result = $(if ($null -ne $obj2.status_message)
    {
        $obj2.status_message 
    }
    else
    {
        "EMPTY_STRING_DEFAULT" 
    })
Write-Host "Status message conditional result: '$status_result'" -ForegroundColor White

Write-Host "`nDebug complete!" -ForegroundColor Green
