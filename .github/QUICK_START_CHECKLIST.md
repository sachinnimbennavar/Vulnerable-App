# CI/CD Pipeline - Quick Start Checklist

## 📋 Pre-Deployment Checklist

### Phase 1: Local Setup ✓
- [x] XAMPP installed at `C:\xampp`
- [x] Apache service running
- [x] PHP 8.0+ with PDO & SQLite
- [x] Application working at `http://localhost:8080/vulnerable-app/`

### Phase 2: Repository Setup
- [ ] Code pushed to GitHub repository
- [ ] `.github/workflows/ci-cd-pipeline.yml` file exists
- [ ] `.github/CICD_SETUP_GUIDE.md` file exists
- [ ] `.github/NEXUS_SETUP_GUIDE.md` file exists

### Phase 3: GitHub Configuration
- [ ] Repository is public or private with Actions enabled
- [ ] GitHub Secrets configured (if using Nexus):
  - [ ] `NEXUS_URL` - http://your-nexus:8081
  - [ ] `NEXUS_USERNAME` - deployment-user
  - [ ] `NEXUS_PASSWORD` - your-password

### Phase 4: Nexus Setup (Optional)
- [ ] Nexus running (Docker or local)
- [ ] `maven2-hosted` repository created
- [ ] Deployment user created
- [ ] User has repository write permissions
- [ ] Credentials match GitHub Secrets

---

## 🚀 Getting Started in 5 Minutes

### Step 1: Prepare Your Repository (2 min)

```bash
# Navigate to your repo
cd C:\path\to\Vulnerable-App

# Push code to GitHub
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

### Step 2: Configure GitHub Secrets (2 min)

If using Nexus:
1. Go to GitHub Repo → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add: `NEXUS_URL`, `NEXUS_USERNAME`, `NEXUS_PASSWORD`

(If NOT using Nexus, skip this step - pipeline still works!)

### Step 3: Trigger Pipeline (1 min)

Make a small commit to trigger the pipeline:
```bash
# Edit any file
echo "# Updated" >> README.md
git add README.md
git commit -m "Trigger CI/CD pipeline"
git push origin main
```

### Step 4: Monitor Pipeline (<1 min)

1. Go to GitHub Repo → Actions
2. Watch the workflow run
3. Check artifacts on completion

---

## 📊 Pipeline Execution Flow

```
Step 1:  Checkout Code                 ~5 sec
Step 2:  Setup PHP                     ~20 sec
Step 3:  Validate Syntax               ~10 sec
Step 4:  Install Dependencies          ~15 sec
Step 5:  Run Tests                     ~10 sec
Step 6:  Create ZIP                    ~15 sec
Step 7:  Upload to GitHub              ~10 sec
Step 8:  Upload to Nexus (if enabled)  ~30 sec
Step 9:  Deploy to XAMPP               ~20 sec
Step 10: Restart Apache                ~10 sec
Step 11: Verify Deployment             ~15 sec
Step 12: Generate Report               ~5 sec
           ─────────────────────────────
           TOTAL TIME: ~3-4 minutes
```

---

## ✅ Success Indicators

### Pipeline Completed Successfully When:
✓ All steps show green checkmark
✓ Artifacts available for download
✓ Application accessible at http://localhost:8080/vulnerable-app/
✓ Deployment report generated
✓ "DEPLOYMENT SUCCESSFUL" message in logs

### Check Application After Deployment:
```powershell
# In PowerShell on your Windows VM
Invoke-WebRequest -Uri "http://localhost:8080/vulnerable-app/index.php?url=home" -UseBasicParsing
```

Expected output: Status 200 with HTML content

---

## 🔧 Configuration Options

### Without Nexus (Recommended for Testing)
No additional configuration needed! Pipeline will:
- Build the app
- Create ZIP
- Upload to GitHub Artifacts
- Deploy to XAMPP
- Restart Apache

### With Nexus (For Production)
Follow these steps:
1. Set up Nexus (Docker or local)
2. Create `maven2-hosted` repository
3. Create deployment user
4. Add GitHub Secrets
5. Pipeline will automatically upload to Nexus

---

## 📝 Accessing Pipeline Artifacts

### GitHub Artifacts (Always Available)
1. Go to GitHub Repo → Actions
2. Click on workflow run
3. Scroll to "Artifacts"
4. Download:
   - `vulnerable-app-build-<number>.zip` - Application package
   - `deployment-report.txt` - Deployment summary

### Nexus Repository (If Configured)
1. Open Nexus browser: http://localhost:8081
2. Go to Browse → `maven2-hosted`
3. Navigate: `vulnerable-app/<number>/vulnerable-app-<number>.zip`
4. Download or copy URL

---

## 🐛 Troubleshooting

### Pipeline Fails at "Deploy to XAMPP"
```
Error: XAMPP not found at C:\xampp
```
**Solution**: 
- Edit workflow Step 9: Change `C:\xampp` to your XAMPP path
- Verify XAMPP is installed: `Test-Path C:\xampp`

### Apache Won't Start
```
Error: Could not start Apache
```
**Solution**:
- Start Apache manually: Open XAMPP Control Panel → Click Start
- Check port 80 availability: `netstat -an | findstr :80`
- Change XAMPP port if needed

### Nexus Upload Fails
```
Error: 401 Unauthorized or 403 Forbidden
```
**Solution**:
- Verify credentials in GitHub Secrets
- Check Nexus user permissions
- Ensure repository exists: `maven2-hosted`
- Note: Pipeline continues despite this error (non-critical)

### Application Not Accessible After Deployment
```
Error: Connection refused to http://localhost:8080/vulnerable-app/
```
**Solution**:
- Check if Apache is running
- Verify deployment path: `ls C:\xampp\htdocs\vulnerable-app\`
- Check Apache logs: `Get-Content C:\xampp\apache\logs\error.log`
- Restart Apache manually

### Workflow Doesn't Trigger
**Solution**:
- Verify `.github/workflows/ci-cd-pipeline.yml` exists
- Check branch name (default: `main`)
- Manually trigger: Actions tab → "Run workflow"

---

## 🔐 Security Notes

### GitHub Secrets Best Practices
- Never commit secrets to repository
- Regenerate secrets periodically
- Use unique passwords for each environment
- Restrict repository access if needed

### Nexus Security
- Change default Nexus password immediately
- Use strong credentials for deployment user
- Enable HTTPS in production
- Limit user permissions to required repositories only

---

## 📈 Next Steps

### After First Successful Pipeline Run:

1. **Verify Application**
   - Login: admin / admin123
   - Test features
   - Check database created

2. **Set Up Security Scanning**
   - Configure OWASP ZAP scanning
   - Run SonarQube analysis
   - Enable Trivy vulnerability scanning

3. **Configure Notifications**
   - Add Slack/email notifications
   - Set up GitHub status checks
   - Monitor deployment reports

4. **Optimize Pipeline**
   - Cache dependencies
   - Parallel job execution
   - Conditional deployments based on branch

5. **Production Deployment**
   - Test on staging environment
   - Add approval steps
   - Implement rollback procedures

---

## 📚 Documentation References

| Document | Purpose |
|----------|---------|
| `ci-cd-pipeline.yml` | Main workflow definition |
| `CICD_SETUP_GUIDE.md` | Detailed setup instructions |
| `NEXUS_SETUP_GUIDE.md` | Nexus configuration guide |
| This file | Quick start checklist |

---

## 💡 Quick Commands

### Verify XAMPP Setup
```powershell
Test-Path C:\xampp
Test-Path C:\xampp\apache\bin\httpd.exe
Test-Path C:\xampp\php\php.exe
```

### Check Apache Status
```powershell
Get-Process -Name httpd
```

### Start Apache Manually
```powershell
C:\xampp\apache\bin\httpd.exe -k start
```

### Stop Apache Manually
```powershell
C:\xampp\apache\bin\httpd.exe -k stop
```

### View Application Files
```powershell
Get-ChildItem C:\xampp\htdocs\vulnerable-app\ -Recurse | Select-Object -First 20
```

### Check Apache Logs
```powershell
Get-Content C:\xampp\apache\logs\error.log -Tail 50
```

---

## 🎯 Success Criteria Checklist

### Build Phase ✓
- [x] Code checkout successful
- [x] PHP syntax validation passes
- [x] Dependencies installed
- [x] Database tests pass
- [x] ZIP artifact created

### Deployment Phase ✓
- [x] Artifact uploaded to GitHub
- [x] (Optional) Artifact uploaded to Nexus
- [x] Files extracted to `C:\xampp\htdocs\vulnerable-app\`
- [x] Permissions set correctly

### Verification Phase ✓
- [x] Apache restarted successfully
- [x] Application accessible at localhost:8080
- [x] Deployment report generated
- [x] No critical errors in logs

---

## 📞 Support

### Getting Help

1. **Check GitHub Actions Logs**
   - Go to Actions → Failed Workflow → Click Step
   - Read error messages and stack traces

2. **Review Guides**
   - Check `CICD_SETUP_GUIDE.md` for detailed steps
   - Check `NEXUS_SETUP_GUIDE.md` for Nexus issues

3. **Manual Testing**
   - Test PHP: `php -v`
   - Test application: `http://localhost:8080/vulnerable-app/`
   - Test Apache: `C:\xampp\apache\bin\httpd.exe -t`

---

**You're all set! 🚀 Your CI/CD pipeline is ready to automate deployments to XAMPP.**

Good luck!
