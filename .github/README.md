# GitHub Actions CI/CD Pipeline for Vulnerable-App

## 📦 What's Been Created

Your complete CI/CD pipeline has been set up! Here's what's included:

### Files Created
```
.github/
├── workflows/
│   └── ci-cd-pipeline.yml              ← Main CI/CD workflow (all steps in one file)
├── CICD_SETUP_GUIDE.md                 ← Detailed setup instructions
├── NEXUS_SETUP_GUIDE.md                ← Optional Nexus repository guide
└── QUICK_START_CHECKLIST.md            ← Quick reference checklist
```

---

## 🚀 Pipeline Overview

Your GitHub Actions CI/CD pipeline automates:

### Build Phase
1. ✅ Code checkout from repository
2. ✅ PHP 8.0 environment setup
3. ✅ PHP syntax validation
4. ✅ Composer dependency installation
5. ✅ Database initialization tests
6. ✅ ZIP artifact creation

### Deployment Phase
7. ✅ Upload to GitHub Artifacts
8. ✅ Upload to Nexus Repository (optional)
9. ✅ Deploy to XAMPP `htdocs`
10. ✅ Restart Apache service
11. ✅ Verify application accessibility

### Reporting Phase
12. ✅ Generate deployment report
13. ✅ Upload summary artifacts

---

## 📋 Pipeline Specifications

### Trigger Events
- **Push** to `main` or `develop` branch
- **Pull Request** to `main` branch
- Can be triggered manually via GitHub UI

### Execution Environment
- **Runner**: Windows Latest (windows-latest)
- **PHP Version**: 8.0
- **Extensions**: PDO, SQLite, GD
- **Execution Time**: ~3-4 minutes

### Artifacts Generated
- `vulnerable-app-<build-number>.zip` - Application package
- `deployment-report.txt` - Deployment summary
- Available in GitHub Actions for 30 days

### Deployment Target
- **Path**: `C:\xampp\htdocs\vulnerable-app\`
- **Access**: `http://localhost:8080/vulnerable-app/`

---

## 🔧 Setup Steps

### Step 1: Basic Setup (No Nexus)

**Minimum requirements:**
- XAMPP installed at `C:\xampp`
- Apache service running
- Repository on GitHub

**That's it!** Your pipeline is ready to use. Just push code to trigger it.

### Step 2: Optional Nexus Integration

If you want artifact repository storage:

1. **Set up Nexus** (see `NEXUS_SETUP_GUIDE.md`)
   - Docker: `docker run -d -p 8081:8081 sonatype/nexus3:latest`
   - Or use local Nexus installation

2. **Create Maven2 Repository**
   - Repository name: `maven2-hosted`
   - Type: Hosted

3. **Create Deployment User**
   - Username: `deployment-user`
   - Assign repository permissions

4. **Add GitHub Secrets**
   - Go to Repository Settings → Secrets
   - Add: `NEXUS_URL`, `NEXUS_USERNAME`, `NEXUS_PASSWORD`

### Step 3: Verify Setup

```powershell
# Check XAMPP
Test-Path C:\xampp\apache\bin\httpd.exe

# Check PHP
php -v

# Verify application (after first deployment)
Invoke-WebRequest -Uri "http://localhost:8080/vulnerable-app/" -UseBasicParsing
```

---

## 📖 Documentation

### Read These First

1. **QUICK_START_CHECKLIST.md** ← START HERE
   - 5-minute setup
   - Quick reference
   - Troubleshooting

2. **CICD_SETUP_GUIDE.md**
   - Detailed pipeline stages
   - Configuration options
   - Customization guide

3. **NEXUS_SETUP_GUIDE.md** (optional)
   - Nexus installation
   - Repository creation
   - Integration steps

### Key Sections

| Document | Key Info |
|----------|----------|
| QUICK_START_CHECKLIST | Phase 1-4 checklist, 5-min setup |
| CICD_SETUP_GUIDE | Pipeline stages 1-13, troubleshooting |
| NEXUS_SETUP_GUIDE | Docker setup, user creation, testing |
| ci-cd-pipeline.yml | Actual workflow code (reference) |

---

## 🎯 Quick Start (5 Minutes)

```bash
# 1. Ensure XAMPP is running
# Open XAMPP Control Panel → Start Apache

# 2. Commit and push your code
cd C:\path\to\Vulnerable-App
git add .
git commit -m "Add CI/CD pipeline"
git push origin main

# 3. Watch pipeline run
# Go to GitHub Repo → Actions → click workflow

# 4. Application will be at
# http://localhost:8080/vulnerable-app/
```

**That's it!** Pipeline is now automated. Every push to main/develop will trigger deployment.

---

## 📊 Pipeline Workflow Diagram

```
GitHub Push Event
       ↓
┌─────────────────────────────────────────┐
│ CHECKOUT & BUILD PHASE                  │
├─────────────────────────────────────────┤
│ 1. Checkout code                        │
│ 2. Setup PHP 8.0                        │
│ 3. Validate PHP syntax                  │
│ 4. Install dependencies (Composer)      │
│ 5. Run database tests                   │
│ 6. Create ZIP artifact                  │
└──────────────┬──────────────────────────┘
               ↓
        ┌──────────────────────────┐
        │ UPLOAD TO GITHUB         │
        │ (Artifacts stored 30 days)
        └──────────┬───────────────┘
                   ↓
        ┌──────────────────────────┐
        │ UPLOAD TO NEXUS (optional)
        └──────────┬───────────────┘
                   ↓
┌─────────────────────────────────────────┐
│ DEPLOY & VERIFY PHASE                   │
├─────────────────────────────────────────┤
│ 7. Deploy to XAMPP (extract ZIP)        │
│ 8. Restart Apache service               │
│ 9. Verify application accessibility     │
│ 10. Generate deployment report          │
└──────────────┬──────────────────────────┘
               ↓
    ✅ DEPLOYMENT COMPLETE
    
Application available at:
http://localhost:8080/vulnerable-app/
```

---

## 🔐 Security Considerations

### GitHub Secrets (If Using Nexus)
- Store Nexus credentials as GitHub Secrets
- Never commit secrets to repository
- Use unique passwords for each environment
- Rotate credentials periodically

### Pipeline Security
- Workflow file is version controlled
- Secrets are encrypted by GitHub
- Deployment only on authorized branch pushes
- Non-critical steps have error handling

---

## ⚙️ Customization

### Change Deployment Path
Edit `ci-cd-pipeline.yml`, Step 9:
```powershell
$xamppPath = "C:\your\custom\path\vulnerable-app"
```

### Change Trigger Branch
Edit `ci-cd-pipeline.yml`, `on:` section:
```yaml
on:
  push:
    branches: [ your-branch-name ]
```

### Add Environment Variables
Add to workflow file `env:` section:
```yaml
env:
  CUSTOM_VAR: "value"
```

### Enable Manual Trigger
Add to `ci-cd-pipeline.yml` `on:` section:
```yaml
  workflow_dispatch:
```
Then trigger from Actions tab.

---

## 🐛 Troubleshooting

### Pipeline Fails to Start
- Check `.github/workflows/ci-cd-pipeline.yml` exists
- Verify branch name is `main` or `develop`
- Try manual trigger: Actions → Run workflow

### Deployment to XAMPP Fails
- Verify XAMPP installed at `C:\xampp`
- Start Apache: XAMPP Control Panel → Start
- Check path: `ls C:\xampp\htdocs\vulnerable-app\`

### Application Not Accessible
- Check Apache is running: `Get-Process httpd`
- Verify URL: `http://localhost:8080/vulnerable-app/`
- Check logs: `Get-Content C:\xampp\apache\logs\error.log`

### Nexus Upload Fails (Non-Critical)
- Verify GitHub Secrets are set
- Check Nexus is running: `docker ps`
- Confirm credentials are correct
- Note: Pipeline continues despite this error

---

## 📈 What Happens On Each Push

```
You push code to GitHub
        ↓
Pipeline automatically triggers
        ↓
Builds application
        ↓
Creates ZIP artifact
        ↓
Uploads to GitHub & Nexus
        ↓
Deploys to C:\xampp\htdocs\vulnerable-app\
        ↓
Restarts Apache
        ↓
Verifies application is running
        ↓
Generates deployment report
        ↓
✅ Done! Your changes are live at localhost:8080
```

---

## 🎓 Learning Resources

### GitHub Actions
- Documentation: https://docs.github.com/en/actions
- Workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- Examples: https://github.com/actions

### Nexus Repository
- Documentation: https://help.sonatype.com/en/nexus-repository-oss.html
- Docker: https://hub.docker.com/r/sonatype/nexus3
- Maven format: https://help.sonatype.com/en/maven-repositories.html

### XAMPP
- Website: https://www.apachefriends.org/
- Documentation: https://www.apachefriends.org/faq.html
- Apache: https://httpd.apache.org/

---

## ✅ Success Indicators

### Pipeline Working Correctly When:
✓ Workflow runs and completes in ~3-4 minutes
✓ All steps show green checkmarks
✓ Artifacts available for download
✓ Application accessible at localhost:8080
✓ Deployment report generated
✓ No critical errors in logs

### Test It
```powershell
# After pipeline completes, test login:
Invoke-WebRequest -Uri "http://localhost:8080/vulnerable-app/index.php?url=login" -UseBasicParsing
```

Expected: Status 200 with login form HTML

---

## 🚀 Next Steps

1. **Read QUICK_START_CHECKLIST.md** ← Start here
2. **Push code to GitHub** to trigger pipeline
3. **Monitor Actions tab** to watch deployment
4. **Verify application** at http://localhost:8080/vulnerable-app/
5. **Optional: Set up Nexus** following NEXUS_SETUP_GUIDE.md

---

## 📞 Quick Reference

| Command | Purpose |
|---------|---------|
| View artifacts | GitHub Actions → Artifacts section |
| Check logs | GitHub Actions → Click workflow step |
| Restart Apache | XAMPP Control Panel → Stop/Start |
| Check app | http://localhost:8080/vulnerable-app/ |
| View Nexus | http://localhost:8081 (if running) |

---

## 🎉 You're All Set!

Your CI/CD pipeline is ready to automate deployments to XAMPP. Every push to your repository will:

1. Build the application
2. Create a ZIP artifact
3. Store it securely
4. Deploy to your Windows VM
5. Restart Apache automatically
6. Verify it's working

**No manual deployment steps needed!**

Good luck! 🚀

---

## 📞 File Summary

### Main Workflow File
- **ci-cd-pipeline.yml** - GitHub Actions workflow (all steps in one file)
  - 13 deployment steps
  - 2 optional jobs (security scan, notifications)
  - Complete automation
  - Error handling and retries

### Documentation Files
- **QUICK_START_CHECKLIST.md** - 5-minute quick start
- **CICD_SETUP_GUIDE.md** - Detailed configuration guide
- **NEXUS_SETUP_GUIDE.md** - Optional artifact repository guide
- **README.md** - This file

**All pipeline steps are in one file: ci-cd-pipeline.yml** ✅
