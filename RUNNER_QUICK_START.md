# 🚀 Self-Hosted Runner Quick Start

## What You Need to Do

Your CI/CD pipeline is working! Now to get Nexus uploads working automatically, set up a self-hosted runner on your VM.

---

## 5-Minute Setup

### 1️⃣ Create GitHub Personal Access Token

**URL:** https://github.com/settings/tokens

1. Click **Generate new token (classic)**
2. **Token name:** `vulnerable-app-runner`
3. **Expiration:** 90 days
4. **Scopes:** Check only `repo`
5. Click **Generate token**
6. **COPY the token immediately** (you won't see it again!)

---

### 2️⃣ Run Setup Script on Your VM

Open **PowerShell as Administrator** and run:

```powershell
cd C:\SSDLC\ssdlc-demo\deleteaftetest\Vulnerable-App

.\setup-runner.ps1 -Token "ghp_YOUR_TOKEN_HERE"
```

Replace `ghp_YOUR_TOKEN_HERE` with your actual token.

---

### 3️⃣ Start the Runner

**Option A - For Testing:**
```powershell
cd C:\github-runner
.\run.cmd
```
Keep this window open. You should see:
```
Listening for Jobs
```

**Option B - As Background Service:**
```powershell
cd C:\github-runner
.\svc.cmd install
.\svc.cmd start
```

---

### 4️⃣ Verify in GitHub

Go to: **Repository → Settings → Actions → Runners**

You should see your runner with:
- ✅ Status: **Idle** (green dot)
- ✅ Name: Something like `COMPUTERNAME`

---

### 5️⃣ Update Workflow

Edit `.github/workflows/ci-cd-pipeline.yml`

Change line 20:
```yaml
# FROM:
runs-on: windows-latest

# TO:
runs-on: self-hosted
```

Commit and push:
```powershell
git add .github/workflows/ci-cd-pipeline.yml
git commit -m "Configure to use self-hosted runner"
git push origin main
```

---

### 6️⃣ Test It!

Push any change to trigger a build:

```powershell
git commit --allow-empty -m "Test self-hosted runner"
git push origin main
```

Then:
1. Go to **Actions** tab
2. Watch the build run on **your VM** (not GitHub cloud!)
3. Check **Nexus** after build completes
4. Artifact should appear at: `http://127.0.0.1:8081/repository/JuiceShopMavenDemo/`

---

## That's It! 🎉

Your complete CI/CD pipeline is now working:
- ✅ Code push → GitHub Actions triggered
- ✅ Runs on your local VM runner
- ✅ Automatically uploads to local Nexus
- ✅ Artifact available for deployment

---

## Troubleshooting

### Runner not appearing in GitHub UI?
- Verify script ran without errors
- Check: `C:\github-runner` directory exists
- Restart the runner: `cd C:\github-runner && .\run.cmd`

### Nexus upload still failing?
- Ensure Nexus is running: `http://127.0.0.1:8081/`
- Verify workflow is using `self-hosted` runner
- Check GitHub Actions logs for exact error

### Need more details?
- Full guide: `.github/SELF_HOSTED_RUNNER_SETUP.md`
- Workflow file: `.github/workflows/ci-cd-pipeline.yml`

---

**Support Commands:**

```powershell
# Check if runner is running
ps -Name github.runner.listener -ErrorAction SilentlyContinue

# Start runner (service)
cd C:\github-runner && .\svc.cmd start

# Stop runner (service)
cd C:\github-runner && .\svc.cmd stop

# View runner logs (service)
Get-ChildItem C:\github-runner\_diag\ | Sort-Object LastWriteTime -Descending | Select-Object -First 3
```

---

**Last Updated:** November 18, 2025
