# .github/scripts/run-sonarqube-scan.ps1

[CmdletBinding()]
param (
    [string]$ProjectKey = "vulnerable-demo-app",
    [string]$ProjectName = "Vulnerable Demo Application",
    [string]$ProjectVersion,
    [string]$SonarHostUrl,
    [string]$SonarToken,
    [string]$BuildNumber,
    [string]$ReportPath = "C:\Reports\Pipeline-Reports"
)

Write-Host "Starting SonarQube analysis..." -ForegroundColor Cyan

# Download SonarScanner if not present
$scannerPath = "C:\sonar-scanner"
if (-not (Test-Path "$scannerPath\bin\sonar-scanner.bat")) {
    Write-Host "Downloading SonarScanner..." -ForegroundColor Yellow
    $scannerUrl = "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-windows.zip"
    $zipPath = "$env:TEMP\sonar-scanner.zip"
    Invoke-WebRequest -Uri $scannerUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath "C:\" -Force
    Move-Item "C:\sonar-scanner-5.0.1.3006-windows" $scannerPath -Force
    Write-Host "✓ SonarScanner installed" -ForegroundColor Green
}

# Run SonarQube scan
$sonarArgs = @(
    "-Dsonar.projectKey=$ProjectKey",
    "-Dsonar.sources=.",
    "-Dsonar.host.url=$SonarHostUrl",
    "-Dsonar.token=$SonarToken",
    "-Dsonar.projectName=$ProjectName",
    "-Dsonar.projectVersion=$ProjectVersion"
)

& "$scannerPath\bin\sonar-scanner.bat" @sonarArgs

Write-Host "✓ SonarQube analysis complete" -ForegroundColor Green
Write-Host "View results: $SonarHostUrl/dashboard?id=$ProjectKey" -ForegroundColor Cyan

# Download detailed SonarQube report
Write-Host "Downloading SonarQube detailed report..." -ForegroundColor Cyan

try {
    if (-not (Test-Path $ReportPath)) {
        New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null
        icacls $ReportPath /grant "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)F" /T | Out-Null
        Write-Host "Created directory: $ReportPath" -ForegroundColor Yellow
    }

    Write-Host "Waiting for SonarQube to process results..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10

    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${SonarToken}:"))
    $headers = @{ Authorization = "Basic $auth" }

    $issuesUrl = "${SonarHostUrl}/api/issues/search?componentKeys=${ProjectKey}&ps=500"
    $issues = Invoke-RestMethod -Uri $issuesUrl -Headers $headers -Method Get

    $metricsUrl = "${SonarHostUrl}/api/measures/component?component=${ProjectKey}&metricKeys=bugs,vulnerabilities,code_smells,security_hotspots,coverage,duplicated_lines_density"
    $metrics = Invoke-RestMethod -Uri $metricsUrl -Headers $headers -Method Get

    # Create detailed HTML report
    $htmlReport = "$ReportPath\SonarQube-Report-Build-${BuildNumber}.html"
    $htmlContent = @"
<!DOCTYPE html><html><head><title>SonarQube Analysis Report - Build ${BuildNumber}</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
.header { background: #3498db; color: white; padding: 20px; border-radius: 5px; }
.metrics { display: flex; gap: 15px; margin: 20px 0; flex-wrap: wrap; }
.metric-box { background: white; padding: 15px; border-radius: 5px; min-width: 150px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.metric-value { font-size: 32px; font-weight: bold; }
table { width: 100%; border-collapse: collapse; background: white; margin-top: 20px; }
th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
th { background: #34495e; color: white; }
.severity-BLOCKER { background: #c0392b; color: white; padding: 5px 10px; border-radius: 3px; }
.severity-CRITICAL { background: #e74c3c; color: white; padding: 5px 10px; border-radius: 3px; }
.severity-MAJOR { background: #e67e22; color: white; padding: 5px 10px; border-radius: 3px; }
</style></head><body>
<div class="header"><h1>SonarQube Security Analysis Report</h1>
<p>Build #${BuildNumber} - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
<p>Project: $ProjectName</p></div>
<div class="metrics">
"@
    foreach ($measure in $metrics.component.measures) {
        $htmlContent += "<div class='metric-box'><div class='metric-value'>$($measure.value)</div><div>$($measure.metric)</div></div>"
    }
    $htmlContent += "</div><h2>Issues Found: $($issues.total)</h2>"
    $htmlContent += '<table><tr><th>Severity</th><th>Type</th><th>Message</th><th>File</th><th>Line</th></tr>'

    foreach ($issue in $issues.issues) {
        $message = $issue.message -replace '<', '&lt;' -replace '>', '&gt;'
        $component = $issue.component -replace '.*:', ''
        $line = if ($issue.line) { $issue.line } else { 'N/A' }
        $htmlContent += "<tr><td><span class='severity-$($issue.severity)'>$($issue.severity)</span></td><td>$($issue.type)</td><td>$message</td><td>$component</td><td>$line</td></tr>"
    }

    $htmlContent += '</table><div style="margin-top: 20px; padding: 15px; background: white; border-radius: 5px;">'
    $htmlContent += "<h3>Dashboard Link</h3><p><a href='$SonarHostUrl/dashboard?id=$ProjectKey'>View in SonarQube Dashboard</a></p>"
    $htmlContent += '</div></body></html>'
    $htmlContent | Out-File -FilePath $htmlReport -Encoding UTF8 -Force

    # Create JSON report
    $jsonReport = "$ReportPath\SonarQube-Report-Build-${BuildNumber}.json"
    @{
        build_number = "$BuildNumber"
        project = $ProjectName
        scan_date = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        metrics = $metrics.component.measures
        issues = $issues.issues
        total_issues = $issues.total
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonReport -Encoding UTF8 -Force

    # Create text summary
    $txtReport = "$ReportPath\SonarQube-Report-Build-${BuildNumber}.txt"
    $summary = "SonarQube Analysis Report`n=========================`n"
    $summary += "Build Number: $BuildNumber`n"
    $summary += "Project: $ProjectName`n"
    $summary += "Version: $ProjectVersion`n"
    $summary += "Scan Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    $summary += "Dashboard: $SonarHostUrl/dashboard?id=$ProjectKey`n`n"
    $summary += "Metrics:`n--------`n"
    foreach ($measure in $metrics.component.measures) {
        $summary += "$($measure.metric): $($measure.value)`n"
    }
    $summary += "`nTotal Issues: $($issues.total)`n"
    $summary += "`nIssues by Severity:`n-------------------`n"
    $severityGroups = $issues.issues | Group-Object severity
    foreach ($group in $severityGroups) {
        $summary += "$($group.Name): $($group.Count)`n"
    }
    $summary | Out-File -FilePath $txtReport -Encoding UTF8 -Force

    Write-Host "✓ SonarQube HTML report: $htmlReport" -ForegroundColor Green
    Write-Host "✓ SonarQube JSON report: $jsonReport" -ForegroundColor Green
    Write-Host "✓ SonarQube TXT report: $txtReport" -ForegroundColor Green

}
catch {
    Write-Host "Error downloading SonarQube report: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Creating basic summary..." -ForegroundColor Yellow
    $fallbackReport = "$ReportPath\SonarQube-Report-Build-${BuildNumber}.txt"
    $reportContent = @"
SonarQube Analysis Report
=========================
Build Number: $BuildNumber
Project: $ProjectName
Version: $ProjectVersion
Scan Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Dashboard URL: $SonarHostUrl/dashboard?id=$ProjectKey

Status: Analysis Complete (API report failed, view dashboard for details)
"@
    $reportContent | Out-File -FilePath $fallbackReport -Encoding UTF8 -Force
}