# 🚀 Self-Hosted Runner Quick Setup

## Current Status
✅ Workflow is running and creating artifacts  
⚠️ Nexus uploads fail from cloud runner (cannot access 127.0.0.1:8081)  
✅ Self-hosted runner setup script is ready

---

## What You Need To Do

### 1️⃣ Get GitHub Personal Access Token (2 minutes)

Go to: https://github.com/settings/tokens/new

- **Name**: `VULNERABLE_APP_RUNNER`
- **Scopes**: Select `repo` and `workflow`
- **Click**: Generate token
- **Copy**: The token (starts with `ghp_`)

### 2️⃣ Run Setup Script on Your VM (5 minutes)

On your Windows VM, open **PowerShell as Administrator** and run:

```powershell
cd C:\SSDLC\ssdlc-demo\deleteaftetest\Vulnerable-App
.\setup-github-runner.ps1 -GitHubToken "ghp_your_token_here"
```

Replace `ghp_your_token_here` with your actual token from Step 1.

### 3️⃣ Start the Runner (1 minute)

Choose one:

**For Testing (run in console):**
```powershell
cd C:\github-runner
.\run.cmd
```
Keep the window open. Stop with Ctrl+C.

**For Production (install as service):**
```powershell
cd C:\github-runner
.\svc.cmd install
.\svc.cmd start
```

### 4️⃣ Verify Runner is Connected (1 minute)

Go to: https://github.com/sachinnimbennavar/Vulnerable-App/settings/actions/runners

Look for: `vulnerable-app-vm-runner`  
Status should show: **Idle** (green dot)

### 5️⃣ Update Workflow (1 minute)

Edit `.github/workflows/ci-cd-pipeline.yml`

Find line ~22:
```yaml
runs-on: windows-latest
```

Change to:
```yaml
runs-on: self-hosted
```

Commit and push:
```powershell
git add .github/workflows/ci-cd-pipeline.yml
git commit -m "Use self-hosted runner for local Nexus access"
git push origin main
```

### 6️⃣ Test the Pipeline (< 1 minute)

Push any code change to trigger the workflow:
```powershell
echo "test" >> test.txt
git add test.txt
git commit -m "Test runner"
git push origin main
```

Watch: https://github.com/sachinnimbennavar/Vulnerable-App/actions

You should see:
- ✅ Build ZIP
- ✅ Upload to GitHub Artifacts
- ✅ **Upload to Nexus** (NOW WORKS!)

---

## Expected Result

After setup, your pipeline will:

```
Code Push
   ↓
Self-Hosted Runner (on your VM)
   ↓
┌──────────────────────────┐
│ Build & Create ZIP       │ ✅
│ Upload to GitHub         │ ✅
│ Upload to Nexus          │ ✅ (NOW THIS WORKS!)
└──────────────────────────┘
```

All artifacts will be in: `http://127.0.0.1:8081/repository/JuiceShopMavenDemo/com/example/vulnerable/vulnerable-app/`

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Runner shows "Offline" | Make sure `run.cmd` or service is running |
| Nexus upload fails | Check if `http://127.0.0.1:8081` is accessible |
| Token error | Verify token starts with `ghp_` and has correct scopes |
| Runner won't start | Check runner logs: `C:\github-runner\_diag` |

---

## Total Time: ~10 minutes

You're almost there! Follow the 6 steps above and your pipeline will be fully automated with Nexus uploads! 🎉
