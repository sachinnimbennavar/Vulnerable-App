# PowerShell script to upload scan reports to dashboard at http://localhost:3002/api
Write-Host "Uploading scan reports to dashboard at http://localhost:3002/api..." -ForegroundColor Cyan
$baseUrl = "http://localhost:3002/api/upload"
$localReportPath = "C:\Reports\Pipeline-Reports"
$reports = @(
  "$localReportPath\SonarQube-Report-Build-*.html",
  "$localReportPath\SonarQube-Report-Build-*.json",
  "$localReportPath\SonarQube-Report-Build-*.txt",
  "$localReportPath\ZAP-Report-Build-*.html",
  "$localReportPath\ZAP-Report-Build-*.json",
  "$localReportPath\ZAP-Report-Build-*.xml",
  "$localReportPath\DependencyCheck-Report-Build-*.html",
  "$localReportPath\DependencyCheck-Report-Build-*.json",
  "$localReportPath\DependencyCheck-Report-Build-*.xml",
  "$localReportPath\BlackDuck-RiskReport-Build-*.pdf"
)
foreach ($pattern in $reports) {
  $files = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
  foreach ($report in $files) {
    Write-Host "Uploading $($report.FullName)..." -ForegroundColor Yellow
    try {
      $fileName = $report.Name
      $form = @{
        file = Get-Item $report.FullName
        filename = $fileName
        build = "manual-upload"
      }
      Invoke-RestMethod -Uri $baseUrl -Method Post -Form $form -TimeoutSec 30
      Write-Host "✓ Uploaded $fileName to dashboard" -ForegroundColor Green
    } catch {
      $errMsg = $_.Exception.Message
      Write-Host "✗ Failed to upload $fileName: $errMsg" -ForegroundColor Red
    }
  }
}
Write-Host "✓ All available reports uploaded to dashboard." -ForegroundColor Cyan
