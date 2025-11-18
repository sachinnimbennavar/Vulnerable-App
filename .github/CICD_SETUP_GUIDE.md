# GitHub Actions CI/CD Pipeline Setup Guide

## Overview
This pipeline automates the build, testing, packaging, and deployment of the Vulnerable Demo Application to your Windows XAMPP environment.

## Pipeline Stages

### 1. **Checkout Code**
   - Clones the latest code from the repository

### 2. **Set up PHP Environment**
   - Installs PHP 8.0 with required extensions (PDO, SQLite, GD)
   - Configures PHP settings

### 3. **Validate PHP Syntax**
   - Checks all PHP files for syntax errors

### 4. **Install Dependencies**
   - Runs `composer install` if composer.json exists

### 5. **Run Tests**
   - Validates database initialization
   - Tests PDO SQLite connection

### 6. **Create ZIP Artifact**
   - Packages the application excluding:
     - `.git/` files
     - `node_modules/`
     - `vendor/` (if included locally)
     - `.env` files
     - Old `database.db`

### 7. **Upload to GitHub Artifacts**
   - Stores ZIP in GitHub Actions artifacts (retained for 30 days)

### 8. **Upload to Nexus Repository**
   - Publishes ZIP to your Nexus Maven repository
   - Uses credentials from GitHub Secrets

### 9. **Deploy to XAMPP**
   - Creates backup of existing application
   - Extracts ZIP to `C:\xampp\htdocs\vulnerable-app\`
   - Sets file permissions

### 10. **Restart Apache**
   - Stops existing Apache process
   - Starts Apache service

### 11. **Verify Deployment**
   - Tests application accessibility
   - Retries up to 5 times if Apache is still starting

### 12. **Generate Report**
   - Creates deployment summary
   - Uploads as artifact

---

## Prerequisites

### On Your Windows VM
1. **XAMPP installed** at `C:\xampp`
2. **Apache enabled** in XAMPP Control Panel
3. **PHP 8.0+** with PDO and SQLite extensions

### On GitHub
1. **Repository** with this workflow file at `.github/workflows/ci-cd-pipeline.yml`
2. **GitHub Secrets** configured (see below)

### On Nexus (Optional)
1. **Nexus Repository** running
2. **maven2-hosted** repository created
3. **User credentials** with upload permissions

---

## GitHub Secrets Configuration

Add this secret to your GitHub repository:

### Required (for Nexus integration):
```
NEXUS_PASSWORD
Example: your-admin-password
```

**Note:** Other Nexus details are already configured:
- URL: http://127.0.0.1:8081
- Repository: JuiceShopMavenDemo
- Username: admin
- GroupId: com.example.vulnerable
- ArtifactId: vulnerable-app

### How to Add Secret:
1. Go to GitHub Repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add `NEXUS_PASSWORD` with your Nexus admin password

---

## Environment Variables in Pipeline

```
NEXUS_URL                    = http://127.0.0.1:8081
NEXUS_REPOSITORY            = JuiceShopMavenDemo
NEXUS_REPOSITORY_URL        = http://127.0.0.1:8081/repository/JuiceShopMavenDemo
NEXUS_USERNAME              = admin
NEXUS_PASSWORD              = {Your Nexus password}
NEXUS_GROUP_ID              = com.example.vulnerable
NEXUS_ARTIFACT_ID           = vulnerable-app
APP_NAME                    = vulnerable-app
ARTIFACT_VERSION            = {GitHub Run Number}
```

---

## Triggering the Pipeline

The pipeline runs automatically on:

### Push Events
```
- Pushes to main branch
- Pushes to develop branch
```

### Pull Request Events
```
- Pull requests targeting main branch
```

### Manual Trigger (Optional)
To enable manual triggering, add this to the workflow:
```yaml
on:
  workflow_dispatch:
```

---

## Artifact Output

After each successful build, the following artifacts are created:

### 1. Application ZIP
- **Name**: `vulnerable-app-<run-number>.zip`
- **Location**: GitHub Artifacts
- **Contents**: Complete application (excluding git, node_modules, etc.)

### 2. Deployment Report
- **Name**: `deployment-report.txt`
- **Contains**:
  - Build metadata
  - Deployment status
  - Access URLs
  - Test credentials
  - Next steps

---

## Accessing Nexus Repository (Optional)

### Upload Artifact Manually
```bash
# Using curl
curl -v --upload-file vulnerable-app-123.zip \
  -u deployment-user:password \
  https://nexus-server.com/repository/maven2-hosted/vulnerable-app/123/vulnerable-app-123.zip
```

### Download from Nexus
```bash
wget https://nexus-server.com/repository/maven2-hosted/vulnerable-app/123/vulnerable-app-123.zip
```

---

## Troubleshooting

### Pipeline Fails at "Deploy to XAMPP"
- **Cause**: XAMPP not installed at `C:\xampp`
- **Solution**: Modify the path in the workflow or install XAMPP

### Apache Won't Start
- **Cause**: Port 80/443 already in use
- **Solution**: 
  - Start Apache manually from XAMPP Control Panel
  - Or change XAMPP port in httpd.conf

### Nexus Upload Fails
- **Cause**: Credentials incorrect or network unreachable
- **Solution**:
  - Verify GitHub Secrets are set correctly
  - Check Nexus URL is accessible from GitHub runners
  - This step is marked `continue-on-error: true` so it won't fail the build

### Application Not Accessible After Deployment
- **Cause**: Apache not started or application path wrong
- **Solution**:
  - Check `C:\xampp\apache\logs\error.log`
  - Manually start Apache from XAMPP Control Panel
  - Verify application at `http://localhost:8080/vulnerable-app/`

---

## Customization

### Change Deployment Path
Edit the workflow at Step 9 "Deploy to XAMPP":
```powershell
$xamppPath = "C:\your\custom\path\vulnerable-app"
```

### Change Port
Modify the verification step:
```powershell
$response = Invoke-WebRequest -Uri "http://localhost:9090/vulnerable-app/..."
```

### Add Security Scanning
The pipeline includes an optional `security-scan` job that runs Trivy scanning. It's already configured but runs only on push events.

### Enable Manual Trigger
Add to the `on:` section:
```yaml
on:
  workflow_dispatch:
```
Then use GitHub UI "Actions" tab to manually trigger.

---

## Pipeline Flow Diagram

```
┌─────────────────┐
│  Push to main   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│ Checkout & Setup PHP        │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ Validate & Test             │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ Create ZIP Artifact         │
└────────┬────────────────────┘
         │
         ├──────────────────────────────┐
         │                              │
         ▼                              ▼
    Upload to            Upload to Nexus
    GitHub Artifacts    (Optional)
         │                              │
         └──────────────┬───────────────┘
                        │
                        ▼
             ┌──────────────────────┐
             │ Deploy to XAMPP      │
             │ - Backup existing    │
             │ - Extract ZIP        │
             │ - Set permissions    │
             └──────┬───────────────┘
                    │
                    ▼
             ┌──────────────────────┐
             │ Restart Apache       │
             │ - Stop process       │
             │ - Start service      │
             └──────┬───────────────┘
                    │
                    ▼
             ┌──────────────────────┐
             │ Verify Deployment    │
             │ - Test URL access    │
             │ - Retry if needed    │
             └──────┬───────────────┘
                    │
                    ▼
             ┌──────────────────────┐
             │ Generate Report      │
             │ Upload Artifacts     │
             └──────────────────────┘
```

---

## Next Steps

1. **Commit workflow file** to `.github/workflows/ci-cd-pipeline.yml`
2. **Add GitHub Secrets** if using Nexus
3. **Push to main branch** to trigger first pipeline run
4. **Monitor** the Actions tab in GitHub
5. **Verify** application deployment in XAMPP

---

## Support Resources

- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Nexus Repository**: https://www.sonatype.com/nexus-repository-oss
- **XAMPP**: https://www.apachefriends.org/
- **PowerShell Scripting**: https://learn.microsoft.com/en-us/powershell/

---

## Key Features

✅ **Automated Build** - Every push triggers build
✅ **PHP Validation** - Syntax checking before deployment
✅ **Artifact Storage** - ZIP stored in GitHub for 30 days
✅ **Nexus Integration** - Optional artifact repository
✅ **XAMPP Deployment** - Automatic extraction to Windows VM
✅ **Apache Management** - Auto-restart service
✅ **Deployment Verification** - Tests application accessibility
✅ **Error Handling** - Non-critical steps use `continue-on-error`
✅ **Reporting** - Generates comprehensive deployment report
✅ **Security Scanning** - Optional Trivy vulnerability scanning
