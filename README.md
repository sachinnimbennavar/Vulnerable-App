# Vulnerable Demo Application

## ⚠️ Security Warning
**This application contains INTENTIONAL security vulnerabilities for educational purposes. DO NOT deploy in production!**

## Overview
This is a monolithic web application built with Apache/PHP that contains multiple security vulnerabilities designed to be detected by various SSDLC security scanning tools.

## Application Features
- **Accessible UI**: Built with ARIA labels and semantic HTML for screen reader compatibility
- **User Authentication**: Login and registration system (vulnerable)
- **Content Management**: Create and view posts
- **File Upload**: Upload files to server (vulnerable)
- **User Profiles**: View user information
- **Admin Panel**: Administrative functions

## Architecture
- **Web Server**: Apache HTTP Server
- **Backend**: PHP 8.0
- **Database**: SQLite
- **Frontend**: HTML5, CSS3, JavaScript (jQuery 1.9.1)
- **Deployment**: Docker containers

## Intentional Vulnerabilities (30+ Issues)

### Critical Vulnerabilities
1. **SQL Injection** (Multiple locations)
   - Login form (`pages/login.php`)
   - Registration form (`pages/register.php`)
   - Search functionality (`pages/dashboard.php`)
   - Post creation (`pages/post.php`)
   - API endpoints (`api/api.php`)

2. **Cross-Site Scripting (XSS)**
   - Stored XSS in posts
   - Reflected XSS in search
   - DOM-based XSS in JavaScript (`assets/js/app.js`)
   - Error messages display

3. **Hardcoded Credentials**
   - Database password in `config.php`
   - API keys in `config.php`
   - JWT secret in `config.php`
   - Environment variables in `docker-compose.yml`

4. **Insecure Authentication**
   - Plain text password storage
   - No password hashing
   - Weak default credentials (admin/admin123)
   - Missing authentication checks

5. **Unrestricted File Upload**
   - No file type validation
   - No size limits
   - Executable file uploads allowed
   - Path traversal vulnerability

### High Severity Vulnerabilities
6. **Insecure Direct Object Reference (IDOR)**
   - Profile access without authorization
   - User data exposure

7. **Missing Access Control**
   - Admin panel accessible without proper checks
   - API endpoints without authentication

8. **Session Management**
   - No HttpOnly flag on cookies
   - No Secure flag on cookies
   - No session regeneration after login

9. **CSRF Vulnerabilities**
   - No CSRF tokens on forms
   - State-changing operations unprotected

10. **Information Disclosure**
    - Debug mode enabled
    - Detailed error messages
    - Server signature exposed
    - Password exposure in profile

### Medium Severity Vulnerabilities
11. **Insecure Dependencies**
    - jQuery 1.9.1 (CVE-2015-9251, CVE-2019-11358)
    - Composer 1.10.22 (outdated, vulnerable)
    - Outdated Composer packages

12. **Security Misconfiguration**
    - Directory listing enabled
    - Excessive file permissions (777)
    - CORS misconfiguration
    - Missing security headers

13. **Sensitive Data Exposure**
    - Passwords in plain text
    - API keys in source code
    - Session tokens in cookies
    - Database credentials exposed

14. **JavaScript Vulnerabilities**
    - Use of `eval()`
    - Prototype pollution
    - Insecure cookie handling
    - Global namespace pollution

15. **Missing Encryption**
    - No HTTPS enforcement
    - Plain text data transmission
    - Unencrypted localStorage usage

## Setup Instructions

### Prerequisites
- Docker and Docker Compose
- (Optional) OWASP ZAP
- (Optional) SonarQube
- (Optional) OWASP Dependency-Check
- (Optional) OWASP Threat Dragon
- (Optional) BlackDuck/Synopsys

### Running the Application

1. **Clone or navigate to the project directory**
```bash
cd /Users/santhosh/Mukana/SSDLC/Demo-Code
```

2. **Build and start the Docker container**
```bash
docker-compose up --build
```

3. **Access the application**
```
http://localhost:8080
```

4. **Default credentials**
```
Username: admin
Password: admin123
```

### Without Docker (Local Apache)

1. **Install dependencies**
```bash
# On macOS with Homebrew
brew install php@7.2 apache2 composer

# Install PHP dependencies
composer install
```

2. **Configure Apache**
```bash
# Copy httpd.conf to Apache configuration directory
sudo cp httpd.conf /etc/apache2/sites-available/vulnerable-demo.conf
sudo a2ensite vulnerable-demo
sudo systemctl restart apache2
```

3. **Set permissions**
```bash
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

## Security Scanning Instructions

### 1. OWASP Threat Dragon

**Purpose**: Threat modeling and architecture analysis

**Steps**:
```bash
# Install OWASP Threat Dragon
npm install -g owasp-threat-dragon-desktop

# Open the threat model
threat-dragon threat-model.json
```

**What it will find**:
- SQL Injection threats
- XSS vulnerabilities
- Missing authentication
- IDOR issues
- Insecure data storage
- CSRF vulnerabilities
- Man-in-the-middle risks

### 2. OWASP Dependency-Check

**Purpose**: Identify known vulnerabilities in dependencies

**Steps**:
```bash
# Download Dependency-Check
wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
unzip dependency-check-8.4.0-release.zip

# Run scan
./dependency-check/bin/dependency-check.sh \
  --project "Vulnerable-Demo-App" \
  --scan . \
  --format HTML \
  --format JSON \
  --out ./dependency-check-report
```

**What it will find**:
- jQuery 1.9.1 vulnerabilities (CVE-2015-9251, CVE-2019-11358)
- Composer vulnerabilities
- Outdated Composer packages (Twig, Symfony, Monolog)
- Known CVEs in dependencies

**Expected Findings**:
- 10+ high severity vulnerabilities
- Multiple medium severity issues
- CVE references for each vulnerable component

### 3. OWASP ZAP (Zed Attack Proxy)

**Purpose**: Dynamic application security testing (DAST)

**Steps**:
```bash
# Using Docker
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://host.docker.internal:8080 \
  -r zap-report.html

# Or using ZAP GUI
# 1. Launch ZAP
# 2. Set target: http://localhost:8080
# 3. Run Active Scan
# 4. Spider the application
# 5. Generate report
```

**Manual Test Cases**:
```bash
# SQL Injection Test
curl -X POST http://localhost:8080/login \
  -d "username=admin' OR '1'='1&password=anything"

# XSS Test
curl -X POST http://localhost:8080/post \
  -d "title=Test&content=<script>alert('XSS')</script>"

# IDOR Test
curl http://localhost:8080/profile?id=2
```

**What it will find**:
- SQL Injection (High)
- Cross-Site Scripting (High)
- Missing Anti-CSRF Tokens (Medium)
- Cookie Without Secure Flag (Medium)
- Cookie Without HttpOnly Flag (Medium)
- Missing Security Headers (Low)
- Directory Browsing (Medium)
- Information Disclosure (Low)

**Expected Findings**:
- 15+ high severity alerts
- 20+ medium severity alerts
- Multiple low severity issues

### 4. SonarQube

**Purpose**: Static application security testing (SAST) and code quality

**Steps**:
```bash
# Start SonarQube (Docker)
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest

# Wait for SonarQube to start (check http://localhost:9000)
# Default credentials: admin/admin

# Install SonarScanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.zip
unzip sonar-scanner-cli-5.0.1.zip

# Create sonar-project.properties file (see below)

# Run scan
./sonar-scanner-5.0.1/bin/sonar-scanner
```

**sonar-project.properties**:
```properties
sonar.projectKey=vulnerable-demo-app
sonar.projectName=Vulnerable Demo Application
sonar.projectVersion=1.0
sonar.sources=.
sonar.sourceEncoding=UTF-8
sonar.php.version=8.0
sonar.exclusions=vendor/**,uploads/**,*.db
```

**What it will find**:
- Hardcoded credentials (Blocker)
- SQL Injection (Blocker)
- XSS vulnerabilities (Blocker)
- Use of eval() (Blocker)
- Insecure random number generation (Critical)
- Weak cryptography (Critical)
- Path traversal (Critical)
- Code smells and technical debt
- Duplicated code
- Complexity issues

**Expected Findings**:
- 20+ blocker issues
- 30+ critical issues
- 50+ major issues
- Security hotspots: 25+

### 5. BlackDuck / Synopsys

**Purpose**: Software composition analysis and license compliance

**Steps**:
```bash
# Using Synopsys Detect
bash <(curl -s -L https://detect.synopsys.com/detect.sh) \
  --blackduck.url=<YOUR_BLACKDUCK_URL> \
  --blackduck.api.token=<YOUR_API_TOKEN> \
  --detect.project.name="Vulnerable-Demo-App" \
  --detect.project.version.name="1.0"
```

**What it will find**:
- All vulnerable dependencies
- License compliance issues
- Component vulnerabilities
- Operational risk assessment
- Policy violations
- Security risk scores

**Expected Findings**:
- High risk components: 5+
- Critical vulnerabilities: 10+
- License risks
- Outdated components

## Vulnerability Summary

### Detectable by Tool

| Vulnerability | Threat Dragon | Dep-Check | ZAP | SonarQube | BlackDuck |
|--------------|---------------|-----------|-----|-----------|-----------|
| SQL Injection | ✅ | ❌ | ✅ | ✅ | ❌ |
| XSS | ✅ | ❌ | ✅ | ✅ | ❌ |
| Hardcoded Credentials | ✅ | ❌ | ❌ | ✅ | ❌ |
| Vulnerable Dependencies | ❌ | ✅ | ❌ | ✅ | ✅ |
| CSRF | ✅ | ❌ | ✅ | ✅ | ❌ |
| Insecure File Upload | ✅ | ❌ | ✅ | ✅ | ❌ |
| IDOR | ✅ | ❌ | ✅ | ❌ | ❌ |
| Missing Auth | ✅ | ❌ | ✅ | ✅ | ❌ |
| Weak Crypto | ✅ | ❌ | ❌ | ✅ | ❌ |
| Info Disclosure | ✅ | ❌ | ✅ | ✅ | ❌ |

## Testing the Application

### Test Scenarios

1. **SQL Injection in Login**
```
Username: admin' OR '1'='1
Password: anything
```

2. **XSS in Posts**
```
Title: Test Post
Content: <script>alert('XSS')</script>
```

3. **IDOR in Profile**
```
Access: http://localhost:8080/profile?id=1
Change to: http://localhost:8080/profile?id=2
```

4. **File Upload Attack**
```
Upload: malicious.php containing <?php system($_GET['cmd']); ?>
Access: http://localhost:8080/uploads/malicious.php?cmd=ls
```

5. **Missing Auth on Admin**
```
Logout, then access: http://localhost:8080/admin
(Should be denied but isn't)
```

## Next Steps

After running all scans and documenting issues, proceed to the fixed version:
- See `SECURITY_FIXES.md` for remediation details
- Check `secure/` directory for fixed code examples
- Compare vulnerable vs. secure implementations

## Learning Objectives

1. Understand common web application vulnerabilities
2. Learn how to use SSDLC security tools
3. Practice vulnerability detection and analysis
4. Understand remediation strategies
5. Implement secure coding practices

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [SANS Top 25](https://www.sans.org/top25-software-errors/)

## Support

This is an educational tool. For questions or issues, refer to the documentation or security best practices guides.
# Test self-hosted runner
# Test self-hosted runner
# Test with Nexus password
# Trigger new deployment
# Deploy to IIS - 19.45.39
# Deploy with permissions fixed - 19.52.10
# CI/CD Pipeline with SonarQube Integration - Last updated: 2025-11-19 17.13.31
