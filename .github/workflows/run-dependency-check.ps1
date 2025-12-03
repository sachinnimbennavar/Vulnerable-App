# .github/scripts/run-dependency-check.ps1

[CmdletBinding()]
param (
    [string]$WorkspacePath,
    [string]$NvdApiKey,
    [string]$BuildNumber,
    [string]$ReportPath = "C:\Reports\Pipeline-Reports"
)

Write-Host "Starting OWASP Dependency Check scan..." -ForegroundColor Cyan

$depCheckInstallPath = "C:\SSDLC\dependency-check-12.1.0-release\dependency-check"
$scanReportPath = "$WorkspacePath\dependency-check-report"

New-Item -Path $scanReportPath -ItemType Directory -Force | Out-Null

if ($NvdApiKey) {
    Write-Host "✓ NVD API Key found - faster scan enabled" -ForegroundColor Green
}
else {
    Write-Host "⚠ NVD API Key not configured - scan will be slower" -ForegroundColor Yellow
}

try {
    $depCheckArgs = @(
        "--scan", $WorkspacePath,
        "--out", $scanReportPath,
        "--format", "ALL",
        "--project", "Vulnerable-App",
        "--disableYarnAudit",
        "--disableNodeAudit",
        "--disableAssembly",
        "--failOnCVSS", "11" # Do not fail the build
    )

    if ($NvdApiKey) {
        $depCheckArgs += "--nvdApiKey", $NvdApiKey
    }

    & "$depCheckInstallPath\bin\dependency-check.bat" @depCheckArgs

    Write-Host "✓ Dependency Check scan completed." -ForegroundColor Green

    # Copy reports to local directory
    Write-Host "Copying Dependency Check reports to $ReportPath..." -ForegroundColor Cyan
    if (-not (Test-Path $ReportPath)) {
        New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null
        icacls $ReportPath /grant "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)F" /T | Out-Null
    }

    $htmlFile = "$scanReportPath\dependency-check-report.html"
    $jsonFile = "$scanReportPath\dependency-check-report.json"
    $xmlFile = "$scanReportPath\dependency-check-report.xml"

    Copy-Item $htmlFile -Destination "$ReportPath\DependencyCheck-Report-Build-${BuildNumber}.html" -Force
    Copy-Item $jsonFile -Destination "$ReportPath\DependencyCheck-Report-Build-${BuildNumber}.json" -Force
    Copy-Item $xmlFile -Destination "$ReportPath\DependencyCheck-Report-Build-${BuildNumber}.xml" -Force
    Write-Host "✓ Dependency Check reports copied." -ForegroundColor Green
}
catch {
    Write-Host "Error during Dependency Check scan: $($_.Exception.Message)" -ForegroundColor Red
}