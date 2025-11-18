# 🚀 FINAL SETUP INSTRUCTIONS - GitHub Self-Hosted Runner

## Your GitHub CI/CD Pipeline is Ready!

The workflow is building and uploading to GitHub Artifacts successfully. Now we need to set up a self-hosted runner so it can upload directly to your local Nexus.

---

## ⚡ Quick Setup (15 minutes)

### STEP 1: Get GitHub Personal Access Token (3 min)

1. Go to: **https://github.com/settings/tokens/new**
2. Fill in:
   - **Token name**: `VULNERABLE_APP_RUNNER`
   - **Expiration**: 90 days (or your preference)
   - **Scopes**: Select `repo` (full control) + `workflow`
3. Click **Generate token**
4. **COPY the token** - it starts with `ghp_` and you won't see it again

### STEP 2: Run the Setup Script (8 min)

Open **PowerShell as Administrator** on your VM:

```powershell
# Navigate to repo
cd C:\SSDLC\ssdlc-demo\deleteaftetest\Vulnerable-App

# Run setup script
& 'C:\github-runner-setup.ps1'
```

The script will:
- Ask for your GitHub token (paste from Step 1)
- Download GitHub Actions Runner
- Configure it for your repo
- Display next instructions

### STEP 3: Start the Runner (2 min)

After script completes, choose ONE option:

**Option A - For Testing (keep terminal open):**
```powershell
cd C:\github-runner
.\run.cmd
```
Keep this window open. Stop with `Ctrl+C`.

**Option B - Install as Service (recommended for production):**
```powershell
cd C:\github-runner
.\svc.cmd install
.\svc.cmd start
```

### STEP 4: Verify Runner is Online (2 min)

Go to: **https://github.com/sachinnimbennavar/Vulnerable-App/settings/actions/runners**

You should see:
- Runner name: `vulnerable-app-vm-runner`
- Status: **Idle** (green dot)

### STEP 5: Update Workflow to Use Self-Hosted Runner (1 min)

Edit file: `.github/workflows/ci-cd-pipeline.yml`

Find line ~22:
```yaml
    runs-on: windows-latest
```

Change to:
```yaml
    runs-on: self-hosted
```

Save, commit, and push:
```powershell
git add .github/workflows/ci-cd-pipeline.yml
git commit -m "Switch to self-hosted runner for Nexus uploads"
git push origin main
```

### STEP 6: Test the Pipeline (< 1 min)

Push any code change to trigger the workflow:
```powershell
echo "test" >> test.txt
git add test.txt
git commit -m "Test self-hosted runner"
git push origin main
```

Watch your builds: **https://github.com/sachinnimbennavar/Vulnerable-App/actions**

---

## ✅ Success Indicators

After these steps, you should see:

✅ Build #10+ triggers  
✅ Runner shows as "Running" on Actions page  
✅ ZIP created and uploaded to GitHub Artifacts  
✅ **Nexus upload SUCCESS** (no more errors!)  
✅ Artifact appears in Nexus: http://127.0.0.1:8081/

---

## 📊 Final Pipeline Flow

```
Push Code to GitHub
        ↓
Self-Hosted Runner (on your VM)
        ↓
┌─────────────────────────────┐
│ 1. Checkout code            │ ✅
│ 2. Setup PHP 8.0            │ ✅
│ 3. Create ZIP               │ ✅
│ 4. Upload to GitHub         │ ✅
│ 5. Upload to Nexus          │ ✅ (NOW WORKS!)
└─────────────────────────────┘
        ↓
✨ FULLY AUTOMATED ✨
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Token is invalid" | Go to https://github.com/settings/tokens and regenerate |
| Runner shows "Offline" | Make sure `.\run.cmd` or service is running |
| Nexus upload still fails | Check if http://127.0.0.1:8081 is accessible on VM |
| "Access Denied" running script | Right-click PowerShell → Run as Administrator |
| Runner won't start | Check logs: `C:\github-runner\_diag` |

---

## 📁 Files Reference

| File | Purpose |
|------|---------|
| `C:\github-runner-setup.ps1` | Main setup script (run this!) |
| `setup-github-runner.ps1` | Alternative setup (in repo root) |
| `RUNNER_SETUP_GUIDE.md` | Detailed documentation |
| `.github/SELF_HOSTED_RUNNER_SETUP.md` | Additional reference |
| `.github/workflows/ci-cd-pipeline.yml` | Workflow file (edit line 22) |

---

## 🎯 Timeline

- **Step 1**: 3 minutes (get token)
- **Step 2**: 8 minutes (run setup)
- **Step 3**: 2 minutes (start runner)
- **Step 4**: 2 minutes (verify)
- **Step 5**: 1 minute (update workflow)
- **Step 6**: < 1 minute (test)

**TOTAL: ~17 minutes to fully automated Nexus uploads!**

---

## 🎉 That's It!

After these steps, your entire CI/CD pipeline is automated:
- GitHub detects code pushes
- Self-hosted runner builds the application
- Creates and uploads ZIP to Nexus
- All in one pipeline!

**Your demo application is now production-ready with automated builds!** 🚀

---

**Last Updated**: November 18, 2025
**Status**: Ready for Self-Hosted Runner Setup
