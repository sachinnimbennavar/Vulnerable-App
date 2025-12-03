# .github/scripts/run-zap-scan.ps1

[CmdletBinding()]
param (
    [string]$TargetUrl,
    [string]$WorkspacePath,
    [string]$BuildNumber,
    [string]$ReportPath = "C:\Reports\Pipeline-Reports"
)

Write-Host "Starting OWASP ZAP security scan..." -ForegroundColor Cyan

$zapInstallPath = "C:\Program Files\ZAP\Zed Attack Proxy"
$htmlReport = "$WorkspacePath\zap-report.html"
$jsonReport = "$WorkspacePath\zap-report.json"
$xmlReport = "$WorkspacePath\zap-report.xml"

# Verify application is running
try {
    Invoke-WebRequest -Uri $TargetUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✓ Application is accessible for scanning at $TargetUrl" -ForegroundColor Green
}
catch {
    Write-Host "✗ Application not accessible at $TargetUrl, cannot scan. Exiting." -ForegroundColor Red
    exit 1 # Exit with an error code
}

# ZAP Configuration
$zapApiKey = "zap-api-key-12345"
$zapPort = 8090
$baseUrl = "http://localhost:$zapPort"

# Clean up any existing ZAP processes
Write-Host "Cleaning up any existing ZAP processes..." -ForegroundColor Yellow
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5

# Start ZAP in daemon mode
Write-Host "Starting ZAP daemon..." -ForegroundColor Yellow
$zapArgs = @(
    "-daemon",
    "-host", "127.0.0.1",
    "-port", $zapPort,
    "-config", "api.key=$zapApiKey",
    "-config", "api.disablekey=false",
    "-config", "api.addrs.addr.name=.*",
    "-config", "api.addrs.addr.regex=true"
)

$zapProcess = Start-Process -FilePath "$zapInstallPath\zap.bat" -ArgumentList $zapArgs -WorkingDirectory $zapInstallPath -PassThru -WindowStyle Hidden
if (-not $zapProcess) {
    throw "Failed to start ZAP process."
}
Write-Host "ZAP process started with PID: $($zapProcess.Id)" -ForegroundColor Cyan

# Wait for ZAP to be ready
$maxWait = 120; $waited = 0; $zapReady = $false
Write-Host "Waiting for ZAP daemon to initialize..." -ForegroundColor Yellow
while ($waited -lt $maxWait) {
    Start-Sleep -Seconds 5; $waited += 5
    try {
        $testUrl = "$baseUrl/JSON/core/view/version/?apikey=$zapApiKey"
        $response = Invoke-RestMethod -Uri $testUrl -Method Get -TimeoutSec 5 -ErrorAction Stop
        $zapReady = $true
        Write-Host "✓ ZAP daemon ready after $waited seconds (Version: $($response.version))" -ForegroundColor Green
        break
    }
    catch { Write-Host "Waiting... ($waited/$maxWait seconds)" -ForegroundColor Gray }
}

if (-not $zapReady) {
    Write-Host "✗ ZAP daemon failed to start after $maxWait seconds." -ForegroundColor Red
    $logPath = "$env:USERPROFILE\.ZAP\zap.log"
    if (Test-Path $logPath) {
        Write-Host "Last 20 lines of ZAP log:" -ForegroundColor Cyan
        Get-Content $logPath -Tail 20
    }
    throw "ZAP daemon failed to start."
}

try {
    # Spider the application
    Write-Host "Spidering application..." -ForegroundColor Yellow
    $spiderUrl = "$baseUrl/JSON/spider/action/scan/?url=${TargetUrl}&apikey=${zapApiKey}"
    $spiderId = (Invoke-RestMethod -Uri $spiderUrl -Method Get).scan
    $spiderStatus = 0
    while ($spiderStatus -lt 100) {
        Start-Sleep -Seconds 5
        $statusUrl = "$baseUrl/JSON/spider/view/status/?scanId=${spiderId}&apikey=${zapApiKey}"
        $spiderStatus = (Invoke-RestMethod -Uri $statusUrl -Method Get).status
        Write-Host "Spider progress: $spiderStatus%" -ForegroundColor Cyan
    }
    Write-Host "✓ Spidering complete." -ForegroundColor Green

    # Run active scan
    Write-Host "Running active security scan..." -ForegroundColor Yellow
    $scanUrl = "$baseUrl/JSON/ascan/action/scan/?url=${TargetUrl}&apikey=${zapApiKey}"
    $scanId = (Invoke-RestMethod -Uri $scanUrl -Method Get).scan
    $scanStatus = 0
    while ($scanStatus -lt 100) {
        Start-Sleep -Seconds 10
        $statusUrl = "$baseUrl/JSON/ascan/view/status/?scanId=${scanId}&apikey=${zapApiKey}"
        $scanStatus = (Invoke-RestMethod -Uri $statusUrl -Method Get).status
        Write-Host "Active Scan progress: $scanStatus%" -ForegroundColor Cyan
    }
    Write-Host "✓ Active scan complete." -ForegroundColor Green

    # Generate reports
    Write-Host "Generating reports..." -ForegroundColor Yellow
    Invoke-RestMethod -Uri "$baseUrl/OTHER/core/other/htmlreport/?apikey=$zapApiKey" -Method Get -OutFile $htmlReport
    Invoke-RestMethod -Uri "$baseUrl/OTHER/core/other/jsonreport/?apikey=$zapApiKey" -Method Get -OutFile $jsonReport
    Invoke-RestMethod -Uri "$baseUrl/OTHER/core/other/xmlreport/?apikey=$zapApiKey" -Method Get -OutFile $xmlReport
    Write-Host "✓ Reports generated in workspace." -ForegroundColor Green

    # Copy reports to local directory
    Write-Host "Copying ZAP reports to $ReportPath..." -ForegroundColor Cyan
    if (-not (Test-Path $ReportPath)) {
        New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null
        icacls $ReportPath /grant "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)F" /T | Out-Null
    }
    Copy-Item $htmlReport -Destination "$ReportPath\ZAP-Report-Build-${BuildNumber}.html" -Force
    Copy-Item $jsonReport -Destination "$ReportPath\ZAP-Report-Build-${BuildNumber}.json" -Force
    Copy-Item $xmlReport -Destination "$ReportPath\ZAP-Report-Build-${BuildNumber}.xml" -Force
    Write-Host "✓ ZAP reports copied." -ForegroundColor Green
}
catch {
    Write-Host "Error during ZAP scan: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    # Stop ZAP
    Write-Host "Stopping ZAP daemon..." -ForegroundColor Yellow
    try {
        $shutdownUrl = "$baseUrl/JSON/core/action/shutdown/?apikey=$zapApiKey"
        Invoke-RestMethod -Uri $shutdownUrl -Method Get -ErrorAction SilentlyContinue
    }
    catch {}
    Start-Sleep -Seconds 5
    Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
    Write-Host "✓ ZAP stopped." -ForegroundColor Green
}