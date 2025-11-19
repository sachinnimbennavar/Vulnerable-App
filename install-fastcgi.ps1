# Install IIS FastCGI Module
# Run this script as Administrator

Write-Host "=== Installing IIS FastCGI Module ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "Installing CGI feature for IIS..." -ForegroundColor Cyan

# Install the CGI feature which includes FastCGI
try {
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-CGI -All -NoRestart
    Write-Host "✓ CGI/FastCGI module installed successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to install CGI module: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying alternative method..." -ForegroundColor Yellow
    
    # Alternative method using DISM
    dism /online /enable-feature /featurename:IIS-CGI /all
}

Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Cyan

# Check if FastCGI module is now available
$fastCgiModule = Get-WindowsOptionalFeature -Online -FeatureName IIS-CGI

if ($fastCgiModule.State -eq "Enabled") {
    Write-Host "✓ FastCGI module is enabled" -ForegroundColor Green
} else {
    Write-Host "✗ FastCGI module is not enabled" -ForegroundColor Red
    Write-Host "Current state: $($fastCgiModule.State)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run the PHP configuration script again:" -ForegroundColor White
Write-Host "     c:\SSDLC\ssdlc-demo\deleteaftetest\Vulnerable-App\configure-iis-php.ps1" -ForegroundColor Gray
Write-Host "  2. Test the application: http://localhost/vulnerable-app/" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
