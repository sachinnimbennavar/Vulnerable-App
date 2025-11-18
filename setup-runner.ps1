# GitHub Self-Hosted Runner Auto-Setup Script
# Run this on your Windows VM as Administrator

param(
    [string]$Token = "",
    [string]$RunnerName = "vulnerable-app-runner-1",
    [string]$RunnerPath = "C:\github-runner"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Self-Hosted Runner Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: This script must run as Administrator" -ForegroundColor Red
    exit 1
}

# Get token if not provided
if (-not $Token) {
    Write-Host "❌ Token is required!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Get your token from:" -ForegroundColor Yellow
    Write-Host "GitHub → Repository → Settings → Actions → Runners → New self-hosted runner"
    Write-Host ""
    Write-Host "Usage: .\setup-runner.ps1 -Token 'YOUR_TOKEN_HERE'" -ForegroundColor Yellow
    exit 1
}

# Step 1: Create runner directory
Write-Host "Step 1: Creating runner directory..." -ForegroundColor Green
if (Test-Path $RunnerPath) {
    Write-Host "  ℹ Directory already exists"
} else {
    New-Item -ItemType Directory -Path $RunnerPath -Force | Out-Null
    Write-Host "  ✓ Created: $RunnerPath"
}

# Step 2: Download runner
Write-Host ""
Write-Host "Step 2: Downloading GitHub Actions Runner..." -ForegroundColor Green
$runnerVersion = "2.329.0"
$zipFile = "$RunnerPath\actions-runner-win-x64-$runnerVersion.zip"
$url = "https://github.com/actions/runner/releases/download/v$runnerVersion/actions-runner-win-x64-$runnerVersion.zip"

if (Test-Path $zipFile) {
    Write-Host "  ℹ Runner already downloaded"
} else {
    try {
        Write-Host "  Downloading from: $url"
        Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
        Write-Host "  ✓ Downloaded successfully"
    } catch {
        Write-Host "  ❌ Download failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Extract runner
Write-Host ""
Write-Host "Step 3: Extracting runner..." -ForegroundColor Green
try {
    Expand-Archive -Path $zipFile -DestinationPath $RunnerPath -Force
    Write-Host "  ✓ Extracted successfully"
    Remove-Item $zipFile
    Write-Host "  ✓ Cleaned up zip file"
} catch {
    Write-Host "  ❌ Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Configure runner
Write-Host ""
Write-Host "Step 4: Configuring runner..." -ForegroundColor Green
Set-Location $RunnerPath

$configArgs = @(
    "--url", "https://github.com/sachinnimbennavar/Vulnerable-App",
    "--token", $Token,
    "--name", $RunnerName,
    "--runnergroup", "Default",
    "--work", "_work",
    "--labels", "windows,demo",
    "--unattended",
    "--replace"
)

try {
    & .\config.cmd @configArgs
    Write-Host "  ✓ Configuration completed"
} catch {
    Write-Host "  ❌ Configuration failed: $_" -ForegroundColor Red
    exit 1
}

# Step 5: Install as Windows service
Write-Host ""
Write-Host "Step 5: Installing as Windows service..." -ForegroundColor Green
try {
    & .\svc.cmd install
    Write-Host "  ✓ Service installed"
} catch {
    Write-Host "  ❌ Service installation failed: $_" -ForegroundColor Red
    exit 1
}

# Step 6: Start service
Write-Host ""
Write-Host "Step 6: Starting Windows service..." -ForegroundColor Green
try {
    & .\svc.cmd start
    Start-Sleep -Seconds 2
    $service = Get-Service -Name "GitHub Runner" -ErrorAction SilentlyContinue
    if ($service.Status -eq "Running") {
        Write-Host "  ✓ Service started successfully"
    } else {
        Write-Host "  ⚠ Service status: $($service.Status)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ Failed to start service: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Go to GitHub → Repository → Settings → Actions → Runners"
Write-Host "2. Verify your runner appears and is 'Idle' (green)"
Write-Host "3. Update workflow to use: runs-on: self-hosted"
Write-Host "4. Push a commit to trigger the pipeline"
Write-Host ""
Write-Host "Your pipeline will now have access to:" -ForegroundColor Cyan
Write-Host "  ✓ Local Nexus at http://127.0.0.1:8081/"
Write-Host "  ✓ Local XAMPP and Apache"
Write-Host "  ✓ Direct artifact uploads to Nexus"
Write-Host ""
