# GitHub Self-Hosted Runner Setup Script
# This script automates the setup of a GitHub Actions self-hosted runner on your Windows VM
# The runner will have access to your local Nexus repository

# Configuration
$GITHUB_REPO = "sachinnimbennavar/Vulnerable-App"
$GITHUB_TOKEN = "" # You'll need to provide this
$RUNNER_NAME = "vulnerable-app-vm-runner"
$RUNNER_PATH = "C:\github-runner"
$RUNNER_LABELS = "windows,xampp,nexus,demo"

Write-Host "========================================" -ForegroundColor Green
Write-Host "GitHub Actions Self-Hosted Runner Setup" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if GitHub token is provided
if ($GITHUB_TOKEN -eq "") {
    Write-Host "ERROR: GITHUB_TOKEN is not set" -ForegroundColor Red
    Write-Host ""
    Write-Host "To get a GitHub token:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/settings/tokens/new"
    Write-Host "2. Select scopes: repo (full control), workflow"
    Write-Host "3. Copy the token and run this script with:"
    Write-Host "   .\setup-github-runner.ps1 -GitHubToken 'your_token_here'"
    Write-Host ""
    exit 1
}

# Create runner directory
if (-not (Test-Path $RUNNER_PATH)) {
    Write-Host "Creating runner directory: $RUNNER_PATH"
    New-Item -ItemType Directory -Path $RUNNER_PATH -Force | Out-Null
}

Set-Location $RUNNER_PATH

# Download latest runner
Write-Host "Downloading GitHub Actions Runner..." -ForegroundColor Cyan
$runnerVersion = "latest"
$runnerUrl = "https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-win-x64-2.320.0.zip"

if (Test-Path "runner.zip") { Remove-Item "runner.zip" }
Invoke-WebRequest -Uri $runnerUrl -OutFile "runner.zip" -UseBasicParsing

Write-Host "Extracting runner..." -ForegroundColor Cyan
Expand-Archive -Path "runner.zip" -DestinationPath $RUNNER_PATH -Force
Remove-Item "runner.zip"

# Configure runner
Write-Host "Configuring runner..." -ForegroundColor Cyan
& "$RUNNER_PATH\config.cmd" `
    --url "https://github.com/$GITHUB_REPO" `
    --token $GITHUB_TOKEN `
    --name $RUNNER_NAME `
    --labels $RUNNER_LABELS `
    --unattended `
    --replace

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Runner Configured Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Start the runner service:"
Write-Host "   & '$RUNNER_PATH\run.cmd'"
Write-Host ""
Write-Host "2. Or install as Windows Service (requires Admin):"
Write-Host "   & '$RUNNER_PATH\svc.cmd' install"
Write-Host "   & '$RUNNER_PATH\svc.cmd' start"
Write-Host ""
Write-Host "3. Verify runner is connected:"
Write-Host "   Go to: https://github.com/$GITHUB_REPO/settings/actions/runners"
Write-Host ""
Write-Host "4. Next push will use this runner for builds and Nexus uploads!"
Write-Host ""
