# Nexus Test Commands for Your Setup

Your Nexus instance is running at: **http://127.0.0.1:8081/**

Repository Details:
- **Name**: JuiceShopMavenDemo
- **URL**: http://127.0.0.1:8081/repository/JuiceShopMavenDemo
- **Username**: admin
- **Format**: Maven2

---

## Test 1: Access Nexus Web UI

Open in browser:
```
http://127.0.0.1:8081/
```

Login with: `admin` / (your password)

---

## Test 2: Verify Repository Access

### PowerShell Test
```powershell
$nexusUrl = "http://127.0.0.1:8081/service/rest/v1/repositories"
$username = "admin"
$password = "your-password"
$base64Creds = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$username:$password"))

$headers = @{
    "Authorization" = "Basic $base64Creds"
}

try {
    $response = Invoke-WebRequest -Uri $nexusUrl -Headers $headers -UseBasicParsing
    Write-Host "✓ Connected to Nexus successfully"
    Write-Host "Response: $($response.StatusCode)"
} catch {
    Write-Host "✗ Failed to connect: $($_.Exception.Message)"
}
```

---

## Test 3: Test Artifact Upload

### Manual Upload Test with PowerShell

```powershell
# Create a test ZIP file
$testFile = "test-upload-$(Get-Date -Format 'yyyyMMddHHmmss').zip"
New-Item -ItemType File -Path $testFile | Out-Null

# Prepare credentials
$nexusUrl = "http://127.0.0.1:8081/repository/JuiceShopMavenDemo"
$username = "admin"
$password = "your-password"
$groupId = "com/example/vulnerable"
$artifactId = "vulnerable-app"
$version = "test-001"

# Build upload URL (Maven2 structure)
$uploadUrl = "$nexusUrl/$groupId/$artifactId/$version/$artifactId-$version.zip"
$base64Creds = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$username:$password"))

$headers = @{
    "Authorization" = "Basic $base64Creds"
    "Content-Type" = "application/zip"
}

# Upload
try {
    Write-Host "Uploading to: $uploadUrl"
    $response = Invoke-WebRequest -Uri $uploadUrl -Method PUT -InFile $testFile -Headers $headers -UseBasicParsing
    Write-Host "✓ Upload successful! Status: $($response.StatusCode)"
} catch {
    Write-Host "✗ Upload failed: $($_.Exception.Message)"
}

# Cleanup
Remove-Item $testFile -ErrorAction SilentlyContinue
```

---

## Test 4: Using curl (If Installed)

### Upload Artifact
```bash
curl -v -X PUT \
  -u admin:your-password \
  --upload-file vulnerable-app-001.zip \
  http://127.0.0.1:8081/repository/JuiceShopMavenDemo/com/example/vulnerable/vulnerable-app/001/vulnerable-app-001.zip
```

### Download Artifact
```bash
curl -u admin:your-password \
  -O http://127.0.0.1:8081/repository/JuiceShopMavenDemo/com/example/vulnerable/vulnerable-app/001/vulnerable-app-001.zip
```

---

## Test 5: Browse Repository via Nexus UI

1. Open: http://127.0.0.1:8081/
2. Click **Browse** → **Repositories**
3. Select **JuiceShopMavenDemo**
4. View artifacts in: `com/example/vulnerable/vulnerable-app/`

---

## Test 6: GitHub Actions Test Upload

After configuring GitHub Secrets, you can test:

```powershell
# Simulate what GitHub Actions will do
$nexusPassword = "your-password"
$zipFile = "vulnerable-app-test-build.zip"
$nexusUrl = "http://127.0.0.1:8081/repository/JuiceShopMavenDemo/com/example/vulnerable/vulnerable-app/123/vulnerable-app-123.zip"

$base64Creds = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("admin:$nexusPassword"))

$headers = @{
    "Authorization" = "Basic $base64Creds"
    "Content-Type" = "application/zip"
}

# Create test file
New-Item -ItemType File -Path $zipFile | Out-Null

try {
    $response = Invoke-WebRequest -Uri $nexusUrl -Method PUT -InFile $zipFile -Headers $headers -UseBasicParsing
    Write-Host "✓ Test successful - Ready for GitHub Actions!"
} catch {
    Write-Host "✗ Test failed: $($_.Exception.Message)"
}

Remove-Item $zipFile -ErrorAction SilentlyContinue
```

---

## Maven2 Repository Path Structure

Your CI/CD pipeline uses this path structure:

```
Base URL: http://127.0.0.1:8081/repository/JuiceShopMavenDemo/

Format:   groupId/artifactId/version/artifactId-version.zip

Example:  com/example/vulnerable/vulnerable-app/1/vulnerable-app-1.zip
          com/example/vulnerable/vulnerable-app/2/vulnerable-app-2.zip
          com/example/vulnerable/vulnerable-app/123/vulnerable-app-123.zip
```

Where:
- **groupId**: com.example.vulnerable (converted to com/example/vulnerable)
- **artifactId**: vulnerable-app
- **version**: GitHub run number (auto-incremented: 1, 2, 3, ...)

---

## Expected Nexus Upload Path

When GitHub Actions runs, artifacts will be uploaded to:

```
http://127.0.0.1:8081/repository/JuiceShopMavenDemo/com/example/vulnerable/vulnerable-app/{RUN_NUMBER}/vulnerable-app-{RUN_NUMBER}.zip
```

Examples:
- Build #1 → `/com/example/vulnerable/vulnerable-app/1/vulnerable-app-1.zip`
- Build #2 → `/com/example/vulnerable/vulnerable-app/2/vulnerable-app-2.zip`
- Build #42 → `/com/example/vulnerable/vulnerable-app/42/vulnerable-app-42.zip`

---

## Troubleshooting Nexus Uploads

### Error: 401 Unauthorized
- **Cause**: Wrong password
- **Solution**: Verify admin password is correct
- **Test**: `curl -u admin:password http://127.0.0.1:8081/`

### Error: 403 Forbidden
- **Cause**: User doesn't have write permission
- **Solution**: Check admin user has repository write permission
- **Fix**: Go to Nexus UI → Security → Roles → admin → ensure repository write

### Error: 404 Not Found
- **Cause**: Repository doesn't exist or wrong path
- **Solution**: Verify repository name is `JuiceShopMavenDemo`
- **Check**: Go to Nexus → Browse → Repositories

### Error: Connection Refused
- **Cause**: Nexus not running
- **Solution**: Start Nexus: `docker ps` to verify running
- **Command**: `docker run -d -p 8081:8081 sonatype/nexus3:latest`

---

## GitHub Actions Integration

### What Gets Uploaded

On each GitHub push, the pipeline will:

1. Build the application
2. Create ZIP: `vulnerable-app-{RUN_NUMBER}.zip`
3. Upload to Nexus at: `/com/example/vulnerable/vulnerable-app/{RUN_NUMBER}/`
4. Store for artifact retrieval

### GitHub Secrets Required

Only this secret needs to be configured:

```
NEXUS_PASSWORD = your-nexus-admin-password
```

All other Nexus details are hardcoded in the workflow.

### Verify After First Build

1. Go to GitHub Actions → completed workflow
2. Look for "Upload to Nexus" step
3. Should say: "✓ Upload successful to Nexus (Status: 201)"
4. Check Nexus UI to see artifact in repository

---

## Nexus API Endpoints

For reference, here are useful Nexus REST API endpoints:

```
List all repositories:
GET http://127.0.0.1:8081/service/rest/v1/repositories

Get repository details:
GET http://127.0.0.1:8081/service/rest/v1/repositories/JuiceShopMavenDemo

Search artifacts:
GET http://127.0.0.1:8081/service/rest/v1/search?q=vulnerable-app

List components in repository:
GET http://127.0.0.1:8081/service/rest/v1/search/assets?repository=JuiceShopMavenDemo
```

All require: `-u admin:password` authentication

---

## Quick Reference

| Task | Command |
|------|---------|
| Access Nexus | http://127.0.0.1:8081 |
| Browse artifacts | http://127.0.0.1:8081 → Browse → JuiceShopMavenDemo |
| Upload test artifact | Run "Test 3" PowerShell script above |
| Check connection | Run "Test 2" PowerShell script above |
| View all repositories | GET `/service/rest/v1/repositories` (with auth) |

---

## For GitHub Actions

Add this secret to your repository:

**Settings → Secrets and variables → Actions → New repository secret**

```
Name: NEXUS_PASSWORD
Value: your-nexus-admin-password
```

Done! Your CI/CD pipeline is now configured to automatically upload artifacts to Nexus.

---

## Example Upload Flow

```
GitHub Push
    ↓
GitHub Actions Workflow Starts
    ↓
Build & Package Application
    ↓
Create vulnerable-app-123.zip
    ↓
Upload to:
http://127.0.0.1:8081/repository/JuiceShopMavenDemo/
  com/example/vulnerable/vulnerable-app/123/vulnerable-app-123.zip
    ↓
Deploy to XAMPP
    ↓
✓ Complete!

Artifact accessible via:
- Nexus UI
- Direct URL download
- GitHub Actions Artifacts
- Re-deployment to XAMPP
```

---

This setup is ready for your GitHub Actions pipeline!
