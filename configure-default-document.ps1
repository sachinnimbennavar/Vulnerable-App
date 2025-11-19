# Add index.php as default document for IIS
# Run this script as Administrator

Write-Host "=== Configuring Default Document for PHP ===" -ForegroundColor Cyan
Write-Host ""

Import-Module WebAdministration

# Add index.php to default documents if not already present
$defaultDocs = Get-WebConfiguration -Filter "system.webServer/defaultDocument/files/*" -PSPath "IIS:\" | Select-Object -ExpandProperty value

if ($defaultDocs -notcontains "index.php") {
    Write-Host "Adding index.php to default documents..." -ForegroundColor Cyan
    Add-WebConfiguration -Filter "system.webServer/defaultDocument/files" -PSPath "IIS:\" -Value @{value='index.php'} -AtIndex 0
    Write-Host "✓ index.php added as first default document" -ForegroundColor Green
} else {
    Write-Host "✓ index.php already in default documents" -ForegroundColor Green
}

Write-Host ""
Write-Host "Current default documents (in order):" -ForegroundColor Yellow
Get-WebConfiguration -Filter "system.webServer/defaultDocument/files/*" -PSPath "IIS:\" | Select-Object -ExpandProperty value | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }

Write-Host ""
Write-Host "=== Configuration Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Test the application: http://localhost/vulnerable-app/" -ForegroundColor Cyan
Write-Host ""
