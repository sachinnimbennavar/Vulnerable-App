# Configure IIS to handle PHP files using XAMPP PHP installation
# Run this script as Administrator

Write-Host "=== IIS PHP Configuration Script ===" -ForegroundColor Cyan
Write-Host ""

# Import IIS module
Import-Module WebAdministration

# PHP CGI path
$phpCgiPath = "C:\xampp\php\php-cgi.exe"

# Verify PHP exists
if (-not (Test-Path $phpCgiPath)) {
    Write-Host "ERROR: PHP CGI not found at $phpCgiPath" -ForegroundColor Red
    exit 1
}

Write-Host "Found PHP: $phpCgiPath" -ForegroundColor Green
& $phpCgiPath -v | Select-Object -First 1
Write-Host ""

# Check if handler already exists
$handler = Get-WebConfiguration -Filter "system.webServer/handlers/add[@name='PHP_via_FastCGI']" -PSPath "IIS:\"

if ($handler) {
    Write-Host "PHP handler already exists. Removing old configuration..." -ForegroundColor Yellow
    Remove-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/handlers" -name "." -AtElement @{name='PHP_via_FastCGI'}
}

# Add PHP FastCGI handler
Write-Host "Adding PHP FastCGI handler to IIS..." -ForegroundColor Cyan
Add-WebConfiguration -Filter "system.webServer/handlers" -PSPath "IIS:\" -Value @{
    name = 'PHP_via_FastCGI'
    path = '*.php'
    verb = '*'
    modules = 'FastCgiModule'
    scriptProcessor = "$phpCgiPath"
    resourceType = 'Either'
    requireAccess = 'Script'
}

# Configure FastCGI settings
Write-Host "Configuring FastCGI application settings..." -ForegroundColor Cyan

# Check if FastCGI application exists
$fastCgiApp = Get-WebConfiguration -Filter "system.webServer/fastCgi/application[@fullPath='$phpCgiPath']" -PSPath "IIS:\"

if ($fastCgiApp) {
    Write-Host "FastCGI application already configured." -ForegroundColor Yellow
} else {
    Add-WebConfiguration -Filter "system.webServer/fastCgi" -PSPath "IIS:\" -Value @{
        fullPath = "$phpCgiPath"
        maxInstances = 4
        instanceMaxRequests = 10000
        activityTimeout = 600
        requestTimeout = 600
        protocol = 'NamedPipe'
    }
}

# Set environment variables for PHP
Write-Host "Setting PHP environment variables..." -ForegroundColor Cyan
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/fastCgi/application[@fullPath='$phpCgiPath']/environmentVariables" -name "." -value @{name='PHP_FCGI_MAX_REQUESTS';value='10000'}

# Grant permissions to IIS user accounts
Write-Host "Setting directory permissions..." -ForegroundColor Cyan
$appPath = "C:\inetpub\wwwroot\JuiceShop\vulnerable-app"
icacls "$appPath" /grant "IIS_IUSRS:(OI)(CI)RX" /T
icacls "$appPath" /grant "IUSR:(OI)(CI)RX" /T

Write-Host ""
Write-Host "=== Configuration Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Test the application: http://localhost/JuiceShop/vulnerable-app/" -ForegroundColor White
Write-Host "  2. If you get a 500 error, check: C:\xampp\php\php.ini" -ForegroundColor White
Write-Host "     - Ensure extension_dir is set correctly" -ForegroundColor White
Write-Host "     - Ensure required extensions are enabled" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
