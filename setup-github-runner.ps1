# GitHub Self-Hosted Runner Setup Script
# This script automates the setup of a GitHub Actions self-hosted runner on your Windows VM

param(
    [string]$Token = "",
    [string]$Repo = "sachinnimbennavar/Vulnerable-App",
    [string]$RunnerName = "vulnerable-app-vm-runner",
    [string]$RunnerPath = "C:\github-runner",
    [string]$Labels = "windows,xampp,nexus,demo"
)

Write-Host "========================================" -ForegroundColor Green
Write-Host "GitHub Actions Self-Hosted Runner Setup" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: This script must run as Administrator" -ForegroundColor Red
    exit 1
}

# Check if token is provided
if (-not $Token) {
    Write-Host "❌ ERROR: A GitHub token is required." -ForegroundColor Red
    Write-Host ""
    Write-Host "Get a token from: https://github.com/$Repo/settings/actions/runners" -ForegroundColor Yellow
    Write-Host "Usage: .\setup-github-runner.ps1 -Token 'YOUR_TOKEN'" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Create runner directory
if (-not (Test-Path $RunnerPath)) {
    Write-Host "Creating runner directory: $RunnerPath"
    New-Item -ItemType Directory -Path $RunnerPath -Force | Out-Null
}

Set-Location $RunnerPath

# Download latest runner
Write-Host "Downloading GitHub Actions Runner..." -ForegroundColor Cyan

$latestReleaseUrl = "https://api.github.com/repos/actions/runner/releases/latest"
try {
    Write-Host "  Fetching latest runner version..."
    $latestRelease = Invoke-RestMethod -Uri $latestReleaseUrl -UseBasicParsing
    $runnerVersion = $latestRelease.tag_name.TrimStart('v')
    Write-Host "  ✓ Latest version is $runnerVersion"
} catch {
    Write-Host "  ⚠ Could not fetch latest version, falling back to a recent stable version. Error: $($_.Exception.Message)" -ForegroundColor Yellow
    $runnerVersion = "2.317.0" # A recent, stable version as a fallback
}

$runnerZip = "actions-runner-win-x64-$runnerVersion.zip"
$runnerUrl = "https://github.com/actions/runner/releases/download/v$runnerVersion/$runnerZip"

if (Test-Path $runnerZip) {
    Write-Host "  ✓ Runner zip file for version $runnerVersion already exists. Skipping download." -ForegroundColor Green
} else {
    Write-Host "  Downloading runner version $runnerVersion..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $runnerUrl -OutFile $runnerZip -UseBasicParsing
}

Write-Host "Extracting runner..." -ForegroundColor Cyan
Expand-Archive -Path $runnerZip -DestinationPath $RunnerPath -Force

# Configure runner
Write-Host "Configuring runner..." -ForegroundColor Cyan
& "$RunnerPath\config.cmd" `
    --url "https://github.com/$Repo" `
    --token $Token `
    --name $RunnerName `
    --labels $Labels `
    --unattended `
    --replace

# Install and start the service
Write-Host "Installing and starting runner as a Windows Service..." -ForegroundColor Cyan
& "$RunnerPath\svc.cmd" uninstall | Out-Null # Uninstall first to ensure a clean state
& "$RunnerPath\svc.cmd" install
& "$RunnerPath\svc.cmd" start

Start-Sleep -Seconds 5
$service = Get-Service -Name "GitHub Runner ($RunnerName)" -ErrorAction SilentlyContinue
if ($service.Status -eq "Running") {
    Write-Host "✓ Service '$($service.Name)' is running." -ForegroundColor Green
} else {
    Write-Host "⚠ Service status is '$($service.Status)'. Please check logs in '$RunnerPath\_diag'." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Runner Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Verify the runner is online and idle in your repository settings:"
Write-Host "   https://github.com/$Repo/settings/actions/runners"
Write-Host ""
Write-Host "2. Your pipeline should now use this runner for jobs with 'runs-on: self-hosted'."
Write-Host ""
