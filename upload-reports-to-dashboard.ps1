# PowerShell script to upload scan reports to dashboard at http://localhost:3001/api
Write-Host "Uploading scan reports to dashboard at http://localhost:3001/api..." -ForegroundColor Cyan
$apiBaseUrl = "http://localhost:3001/api"
$localReportPath = "C:\Reports\Pipeline-Reports"
$reports = @(
  "$localReportPath\SonarQube-Report-Build-*.json",
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
    $fileName = $report.Name
    $uploadUrl = ""
    if ($fileName -like "SonarQube-Report-Build-*.json") {
      $uploadUrl = "$apiBaseUrl/sonarqube/upload"
    } elseif ($fileName -like "ZAP-Report-Build-*.json") {
      $uploadUrl = "$apiBaseUrl/owasp-zap/upload"
    } elseif ($fileName -like "DependencyCheck-Report-Build-*.json") {
      $uploadUrl = "$apiBaseUrl/owasp-dependency/upload"
    } elseif ($fileName -like "BlackDuck-RiskReport-Build-*.pdf") {
      $uploadUrl = "$apiBaseUrl/blackduck/upload"
    }

    if ($uploadUrl) {
      Write-Host "Uploading $($report.FullName) to $uploadUrl..." -ForegroundColor Yellow
      try {
        $form = @{
          file = Get-Item $report.FullName
          filename = $fileName
          build = "manual-upload"
        }
        Invoke-RestMethod -Uri $uploadUrl -Method Post -Form $form -TimeoutSec 30
        Write-Host "✓ Uploaded $fileName to dashboard" -ForegroundColor Green
      } catch {
        $errMsg = $_.Exception.Message
        Write-Host "✗ Failed to upload ${fileName}: $errMsg" -ForegroundColor Red
      }
    } else {
      Write-Host "✗ No upload endpoint configured for $fileName" -ForegroundColor DarkGray
    }
  }
}
Write-Host "✓ All available reports uploaded to dashboard." -ForegroundColor Cyan