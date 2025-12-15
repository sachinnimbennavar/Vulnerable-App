# This script automates the IIS setup for the Vulnerable-App.
# IMPORTANT: Please run this script from PowerShell as an Administrator.

# Import IIS module
Import-Module WebAdministration

# Stop Apache service (service name might differ, common names are Apache2.4 or similar)
Write-Host "Attempting to stop the XAMPP Apache service..." -ForegroundColor Yellow
$apacheService = Get-Service -Name "Apache*" -ErrorAction SilentlyContinue
if ($apacheService) {
    Stop-Service -Name $apacheService.Name -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped service: $($apacheService.Name)" -ForegroundColor Green
} else {
    Write-Host "No active Apache service found to stop."
}

# Stop the default IIS site to prevent port conflicts
Write-Host "Stopping 'Default Web Site' to prevent port 80 conflicts..." -ForegroundColor Yellow
Stop-Website -Name "Default Web Site" -ErrorAction SilentlyContinue

# Website details
$siteName = "vulnerable-app"
$physicalPath = "c:\SSDLC\ssdlc-demo\ssdlc\Vulnerable-App"
$port = 80 # You can change this to 80 if that port is free on your system

# Remove existing site if it exists to ensure a clean setup
if (Get-Website -Name $siteName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing IIS website named '$siteName'..." -ForegroundColor Yellow
    Remove-Website -Name $siteName -Confirm:$false
}

# Create new website in IIS
Write-Host "Creating new IIS website '$siteName' on port $port..." -ForegroundColor Cyan
New-Website -Name $siteName -PhysicalPath $physicalPath -Port $port

# Run the PHP configuration script we prepared earlier
Write-Host "Running the PHP handler configuration script (configure-iis-php.ps1)..." -ForegroundColor Cyan
# The following script needs to be in the same directory
.\configure-iis-php.ps1

Write-Host ""
Write-Host "=== IIS Setup Complete ===" -ForegroundColor Green
Write-Host "You can now access your application at: http://localhost:$port"
Write-Host ""
