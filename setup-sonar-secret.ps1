# Add SonarQube Token to GitHub Secrets
# You need to run this manually or add it via GitHub UI

Write-Host "=== GitHub Secret Setup for SonarQube ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To add SONAR_TOKEN secret to GitHub:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to your GitHub repository:" -ForegroundColor White
Write-Host "   https://github.com/sachinnimbennavar/Vulnerable-App" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Navigate to: Settings → Secrets and variables → Actions" -ForegroundColor White
Write-Host ""
Write-Host "3. Click 'New repository secret'" -ForegroundColor White
Write-Host ""
Write-Host "4. Add the following secret:" -ForegroundColor White
Write-Host "   Name:  SONAR_TOKEN" -ForegroundColor Cyan
Write-Host "   Value: squ_6e6dc9505d799884d7dc2188aa31ec0fb7395cad" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Click 'Add secret'" -ForegroundColor White
Write-Host ""
Write-Host "=== Alternative: Use GitHub CLI ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you have GitHub CLI installed, run:" -ForegroundColor Yellow
Write-Host ""
Write-Host 'gh secret set SONAR_TOKEN --body "squ_6e6dc9505d799884d7dc2188aa31ec0fb7395cad"' -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
