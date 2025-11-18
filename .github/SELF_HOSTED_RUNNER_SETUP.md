# 🖥️ GitHub Self-Hosted Runner Setup

## Why Self-Hosted Runner?

GitHub's cloud runners (windows-latest) cannot access your local Nexus at `127.0.0.1:8081`. A self-hosted runner on your VM can access both local resources and push to Nexus directly.

---

## Prerequisites

- ✅ GitHub account with repo access
- ✅ Windows VM with XAMPP installed
- ✅ Git installed on VM
- ✅ PowerShell 7+ (comes with XAMPP)
- ✅ Nexus running locally

---

## Step 1: Get Runner Registration Token

1. Go to GitHub: `https://github.com/sachinnimbennavar/Vulnerable-App`
2. Settings → Actions → Runners
3. Click "New self-hosted runner"
4. Choose: **Windows** | **x64**
5. Keep the page open - you'll need the registration commands

---

## Step 2: Create Runner Directory

On your Windows VM, open PowerShell as Administrator:

```powershell
# Create directory for runner
New-Item -ItemType Directory -Path "C:\github-runner" -Force
Set-Location "C:\github-runner"
```

---

## Step 3: Download & Extract Runner

```powershell
# Download the latest runner
$runnerVersion = "2.329.0"
$url = "https://github.com/actions/runner/releases/download/v$runnerVersion/actions-runner-win-x64-$runnerVersion.zip"

Invoke-WebRequest -Uri $url -OutFile "actions-runner-win-x64-$runnerVersion.zip"
Expand-Archive -Path "actions-runner-win-x64-$runnerVersion.zip" -DestinationPath "." -Force

# Clean up zip
Remove-Item "actions-runner-win-x64-$runnerVersion.zip"
```

---

## Step 4: Configure Runner

Run the configuration script from GitHub (copy from the GitHub Actions Runners page):

```powershell
# From the GitHub Runners page, run something like:
# .\config.cmd --url https://github.com/sachinnimbennavar/Vulnerable-App --token [YOUR_TOKEN]

# Replace [YOUR_TOKEN] with the token shown in GitHub

.\config.cmd --url https://github.com/sachinnimbennavar/Vulnerable-App --token XXXXXXXXXXXXXXXXXX
```

When prompted:
- **Runner group**: Accept default (Default)
- **Runner name**: Enter something like `vulnerable-app-runner-1`
- **Work directory**: Accept default `_work`
- **Run as service**: Type `Y` to run as a Windows service

---

## Step 5: Install as Windows Service

```powershell
# Install as service
.\svc.cmd install

# Start the service
.\svc.cmd start

# Verify it's running
Get-Service -Name "GitHub Runner"
```

---

## Step 6: Verify Runner is Online

Go back to GitHub Actions → Runners. You should see your runner listed and **Idle** (green status).

---

## Step 7: Update Workflow to Use Self-Hosted Runner

Update `.github/workflows/ci-cd-pipeline.yml`:

Change this line:
```yaml
runs-on: windows-latest
```

To this:
```yaml
runs-on: self-hosted
```

Then commit and push:

```powershell
cd C:\SSDLC\ssdlc-demo\deleteaftetest\Vulnerable-App
git add .github/workflows/ci-cd-pipeline.yml
git commit -m "Use self-hosted runner for Nexus access"
git push
```

---

## Step 8: Next Workflow Run

Push a change to trigger the workflow:

```powershell
git commit --allow-empty -m "Trigger workflow on self-hosted runner"
git push
```

Now the pipeline will:
1. ✅ Build on your VM
2. ✅ Create ZIP artifact
3. ✅ Upload to GitHub Artifacts
4. ✅ **Upload directly to Nexus** (now accessible!)
5. ✅ No more connection refused errors

---

## Troubleshooting

### Runner Not Showing in GitHub

**Problem**: Runner doesn't appear in GitHub Actions → Runners

**Solution**:
```powershell
# Check if service is running
Get-Service -Name "GitHub Runner"

# If stopped, start it
Start-Service -Name "GitHub Runner"

# Check logs
Get-Content "C:\github-runner\_diag\Runner_*.log"
```

### Runner Offline After Reboot

**Problem**: Runner goes offline after VM restart

**Solution**: The service should auto-start. If not:
```powershell
# Enable auto-start
Set-Service -Name "GitHub Runner" -StartupType Automatic

# Restart service
Restart-Service -Name "GitHub Runner"
```

### Nexus Upload Still Fails

**Problem**: Nexus upload fails even with self-hosted runner

**Solution**: 
1. Verify Nexus is running: `Invoke-WebRequest -Uri "http://127.0.0.1:8081/" -UseBasicParsing`
2. Verify NEXUS_PASSWORD secret is set in GitHub
3. Check runner logs: `Get-Content "C:\github-runner\_diag\Runner_*.log"`

---

## Managing the Runner

### Stop the Service

```powershell
Stop-Service -Name "GitHub Runner"
```

### Start the Service

```powershell
Start-Service -Name "GitHub Runner"
```

### Uninstall the Service

```powershell
cd C:\github-runner
.\svc.cmd stop
.\svc.cmd uninstall
```

### Remove from GitHub

1. Go to GitHub Actions → Runners
2. Click the three dots on your runner
3. Click "Remove"

---

## Security Notes

⚠️ **Self-Hosted Runner Security:**
- Only use on trusted networks (your local VM is safe)
- Runner has access to your secrets
- It can execute any code from your repo
- For production, use separate VM in isolated network

✅ **Best Practices:**
- Use environment variables for sensitive data
- Regularly update GitHub Actions
- Monitor runner logs
- Use `continue-on-error: true` for non-critical steps

---

## Next Steps

1. ✅ Create runner directory on VM
2. ✅ Download and configure runner
3. ✅ Install as Windows service
4. ✅ Verify in GitHub Actions → Runners
5. ✅ Update workflow to use `self-hosted`
6. ✅ Push code to trigger pipeline
7. ✅ Watch artifact upload to Nexus directly!

---

**Benefits of Self-Hosted Runner:**
- ✅ Access to local resources (Nexus)
- ✅ Faster builds (no cloud overhead)
- ✅ Can deploy directly to local XAMPP
- ✅ Perfect for demo/development environment
- ✅ Full control over build environment

---

**Last Updated**: November 18, 2025
