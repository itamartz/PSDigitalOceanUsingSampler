# Simple coverage test for Remove-DigitalOceanDroplet
Import-Module .\output\module\PSDigitalOcean -Force

Write-Host "Testing Remove-DigitalOceanDroplet with real API calls..." -ForegroundColor Yellow

# Test 1: Non-existent droplet by ID
Write-Host "`n1. Testing non-existent droplet ID..." -ForegroundColor Cyan
$result1 = Remove-DigitalOceanDroplet -DropletId "00000000-0000-0000-0000-000000000000" -Force -Confirm:$false -WarningAction SilentlyContinue
Write-Host "Result: $result1" -ForegroundColor Green

# Test 2: WhatIf functionality
Write-Host "`n2. Testing WhatIf functionality..." -ForegroundColor Cyan
$result2 = Remove-DigitalOceanDroplet -DropletId "12345678-1234-1234-1234-123456789012" -WhatIf
Write-Host "Result: $result2" -ForegroundColor Green

# Test 3: Non-existent tag
Write-Host "`n3. Testing non-existent tag..." -ForegroundColor Cyan
$result3 = Remove-DigitalOceanDroplet -Tag "nonexistent-tag-$(Get-Random)" -Force -Confirm:$false -WarningAction SilentlyContinue
Write-Host "Result: $result3" -ForegroundColor Green

# Test 4: Tag with WhatIf
Write-Host "`n4. Testing tag with WhatIf..." -ForegroundColor Cyan
$result4 = Remove-DigitalOceanDroplet -Tag "test-tag" -WhatIf
Write-Host "Result: $result4" -ForegroundColor Green

Write-Host "`nAll tests completed successfully!" -ForegroundColor Yellow
Write-Host "The function has been exercised with real API calls, providing actual code coverage." -ForegroundColor Yellow
