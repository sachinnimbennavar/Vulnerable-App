# Running Vulnerable Demo App on Windows

## Overview
This guide provides step-by-step instructions for running the vulnerable demo application on Windows using multiple methods.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Method 1: Using Docker Desktop (Recommended)](#method-1-using-docker-desktop-recommended)
3. [Method 2: Using XAMPP](#method-2-using-xampp)
4. [Method 3: Using WSL2 (Windows Subsystem for Linux)](#method-3-using-wsl2)
5. [Method 4: Native Windows with PHP](#method-4-native-windows-with-php)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software (Choose based on method)

**For Docker Method:**
- Windows 10/11 (64-bit, Pro/Enterprise/Education) or Windows Server
- Docker Desktop for Windows
- 8GB RAM minimum
- Virtualization enabled in BIOS

**For XAMPP Method:**
- Windows 7 or later
- XAMPP (Apache + PHP + MySQL)
- 4GB RAM minimum

**For WSL2 Method:**
- Windows 10 version 2004+ or Windows 11
- WSL2 enabled
- Ubuntu or Debian from Microsoft Store

---

## Method 1: Using Docker Desktop (Recommended)

### Step 1: Install Docker Desktop

1. **Download Docker Desktop**
   - Visit: https://www.docker.com/products/docker-desktop/
   - Click "Download for Windows"
   - Save the installer: `Docker Desktop Installer.exe`

2. **Enable Virtualization**
   - Press `Windows + X` → Select "Task Manager"
   - Go to "Performance" tab → CPU
   - Check if "Virtualization" is "Enabled"
   - If disabled, enable in BIOS:
     - Restart computer
     - Press F2/F10/Del (varies by manufacturer)
     - Find "Virtualization" or "Intel VT-x" or "AMD-V"
     - Enable it and save

3. **Install Docker Desktop**
   - Run `Docker Desktop Installer.exe` as Administrator
   - Follow installation wizard
   - Check "Use WSL 2 instead of Hyper-V" (recommended)
   - Click "Install"
   - Restart computer when prompted

4. **Verify Installation**
   - Open PowerShell or Command Prompt
   - Run:
   ```powershell
   docker --version
   docker-compose --version
   ```
   - Should show version numbers

### Step 2: Get the Code

**Option A: Using Git**

1. **Install Git for Windows**
   - Download from: https://git-scm.com/download/win
   - Install with default settings

2. **Clone Repository**
   ```powershell
   # Open PowerShell
   cd C:\Users\YourUsername\Documents
   
   # If you have the code in a Git repository
   git clone <your-repository-url>
   cd Demo-Code
   ```

**Option B: Transfer from Mac**

1. **Create Shared Folder**
   - On Mac: System Settings → Sharing → File Sharing
   - Enable File Sharing
   - Note the Mac's IP address

2. **Access from Windows**
   - Open File Explorer
   - In address bar: `\\<MAC-IP-ADDRESS>\SharedFolder`
   - Copy the entire `Demo-Code` folder to `C:\Users\YourUsername\Documents\`

**Option C: Using Cloud Storage**
   - Upload folder to OneDrive/Google Drive/Dropbox
   - Download to Windows

**Option D: Using USB Drive**
   - Copy entire project folder to USB
   - Copy from USB to `C:\Users\YourUsername\Documents\Demo-Code`

### Step 3: Run the Application

1. **Open PowerShell in Project Directory**
   ```powershell
   # Navigate to project
   cd C:\Users\YourUsername\Documents\Demo-Code
   
   # Verify files exist
   dir
   ```
   - You should see: `docker-compose.yml`, `Dockerfile`, `config.php`, etc.

2. **Start Docker Desktop**
   - Launch Docker Desktop from Start Menu
   - Wait for it to fully start (green icon in system tray)

3. **Build and Run**
   ```powershell
   # Build and start containers
   docker-compose up --build
   ```
   - First time will take 5-10 minutes
   - You'll see logs scrolling

4. **Verify Running**
   - Open browser: http://localhost:8080
   - You should see the vulnerable demo app home page

5. **Stop the Application**
   - Press `Ctrl + C` in PowerShell
   - Or run:
   ```powershell
   docker-compose down
   ```

### Step 4: Run in Background (Optional)

```powershell
# Run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

---

## Method 2: Using XAMPP

### Step 1: Install XAMPP

1. **Download XAMPP**
   - Visit: https://www.apachefriends.org/
   - Download XAMPP for Windows (with PHP 8.0+)
   - Run installer: `xampp-windows-x64-8.0.x-installer.exe`

2. **Installation**
   - Install to: `C:\xampp`
   - Select components: Apache, PHP, MySQL (optional)
   - Complete installation

3. **Start XAMPP Control Panel**
   - Launch from Start Menu: "XAMPP Control Panel"
   - Click "Start" for Apache

### Step 2: Deploy Application

1. **Copy Project Files**
   ```powershell
   # Copy project to XAMPP directory
   xcopy /E /I C:\Users\YourUsername\Documents\Demo-Code C:\xampp\htdocs\vulnerable-app
   ```

2. **Or Manually:**
   - Open File Explorer
   - Navigate to your project folder
   - Copy all files (config.php, pages/, assets/, etc.)
   - Paste into: `C:\xampp\htdocs\vulnerable-app\`

### Step 3: Configure Apache

1. **Edit httpd.conf** (Optional - for custom settings)
   - Open: `C:\xampp\apache\conf\httpd.conf`
   - Or use XAMPP Control Panel → Apache → Config → httpd.conf

2. **Create Virtual Host** (Optional)
   - Open: `C:\xampp\apache\conf\extra\httpd-vhost.conf`
   - Add:
   ```apache
   <VirtualHost *:80>
       DocumentRoot "C:/xampp/htdocs/vulnerable-app"
       ServerName vulnerable.local
       <Directory "C:/xampp/htdocs/vulnerable-app">
           Options Indexes FollowSymLinks
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```

3. **Edit Hosts File** (if using virtual host)
   - Open Notepad as Administrator
   - Open file: `C:\Windows\System32\drivers\etc\hosts`
   - Add line:
   ```
   127.0.0.1    vulnerable.local
   ```
   - Save and close

### Step 4: Access Application

1. **Start Apache**
   - In XAMPP Control Panel, click "Start" for Apache
   - Status should show green "Running"

2. **Open Browser**
   - Without virtual host: http://localhost/vulnerable-app
   - With virtual host: http://vulnerable.local

3. **Default Credentials**
   - Username: `admin`
   - Password: `admin123`

### Step 5: Install Composer Dependencies (Optional)

1. **Install Composer**
   - Download from: https://getcomposer.org/download/
   - Run installer: `Composer-Setup.exe`
   - Follow wizard

2. **Install Dependencies**
   ```powershell
   cd C:\xampp\htdocs\vulnerable-app
   composer install
   ```

---

## Method 3: Using WSL2

### Step 1: Enable WSL2

1. **Enable WSL**
   ```powershell
   # Run PowerShell as Administrator
   wsl --install
   ```

2. **Restart Computer**

3. **Install Ubuntu**
   - Open Microsoft Store
   - Search "Ubuntu"
   - Install "Ubuntu 22.04 LTS"
   - Launch and create user account

### Step 2: Install Docker in WSL2

```bash
# Update packages
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start Docker
sudo service docker start
```

### Step 3: Copy Files to WSL2

**Option A: Using Windows File Explorer**
```powershell
# In Windows, copy files to WSL2
# WSL2 is accessible at: \\wsl$\Ubuntu\home\username\

# Copy project folder
xcopy /E /I C:\Users\YourUsername\Documents\Demo-Code \\wsl$\Ubuntu\home\yourusername\Demo-Code
```

**Option B: From within WSL2**
```bash
# Access Windows files from WSL2
cd ~
cp -r /mnt/c/Users/YourUsername/Documents/Demo-Code ./
cd Demo-Code
```

### Step 4: Run Application

```bash
# In WSL2 terminal
cd ~/Demo-Code

# Build and run
docker-compose up --build
```

### Step 5: Access Application

- Open Windows browser
- Go to: http://localhost:8080

---

## Method 4: Native Windows with PHP

### Step 1: Install PHP

1. **Download PHP**
   - Visit: https://windows.php.net/download/
   - Download PHP 8.0+ (Thread Safe)
   - Extract to: `C:\php`

2. **Add to PATH**
   - Press `Windows + X` → System
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", find "Path"
   - Click "Edit" → "New"
   - Add: `C:\php`
   - Click OK

3. **Verify Installation**
   ```powershell
   php --version
   ```

### Step 2: Install Apache

1. **Download Apache**
   - Visit: https://www.apachelounge.com/download/
   - Download Apache 2.4 Win64
   - Extract to: `C:\Apache24`

2. **Configure Apache**
   - Edit: `C:\Apache24\conf\httpd.conf`
   - Find and modify:
   ```apache
   Define SRVROOT "C:/Apache24"
   ServerRoot "${SRVROOT}"
   DocumentRoot "C:/Apache24/htdocs"
   
   # Enable PHP
   LoadModule php_module "C:/php/php8apache2_4.dll"
   AddHandler application/x-httpd-php .php
   PHPIniDir "C:/php"
   ```

3. **Install Apache Service**
   ```powershell
   # Run as Administrator
   cd C:\Apache24\bin
   httpd.exe -k install
   httpd.exe -k start
   ```

### Step 3: Deploy Application

1. **Copy Files**
   ```powershell
   xcopy /E /I C:\Users\YourUsername\Documents\Demo-Code C:\Apache24\htdocs\vulnerable-app
   ```

2. **Configure PHP**
   - Copy: `C:\php\php.ini-development` to `C:\php\php.ini`
   - Edit `php.ini`:
   ```ini
   extension_dir = "C:/php/ext"
   extension=pdo_sqlite
   extension=sqlite3
   extension=gd
   ```

3. **Restart Apache**
   ```powershell
   httpd.exe -k restart
   ```

### Step 4: Access Application

- Open browser: http://localhost/vulnerable-app

---

## Troubleshooting

### Docker Issues

**Issue: Docker Desktop won't start**
```
Solution:
1. Enable Virtualization in BIOS
2. Enable WSL2: wsl --install
3. Restart computer
4. Check Docker Desktop settings → Resources
```

**Issue: Port 8080 already in use**
```powershell
# Find process using port
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
ports:
  - "8081:80"  # Use 8081 instead
```

**Issue: Cannot connect to localhost**
```
Solution:
1. Check if container is running: docker ps
2. Check Docker Desktop is running
3. Try: http://127.0.0.1:8080
4. Check firewall settings
```

### XAMPP Issues

**Issue: Apache won't start - Port 80 in use**
```
Solution:
1. Stop IIS: iisreset /stop
2. Or change Apache port:
   - Edit C:\xampp\apache\conf\httpd.conf
   - Change "Listen 80" to "Listen 8080"
   - Restart Apache
   - Access: http://localhost:8080
```

**Issue: Permission denied errors**
```
Solution:
1. Run XAMPP Control Panel as Administrator
2. Right-click → Run as administrator
3. Check folder permissions on htdocs
```

**Issue: PHP not working**
```
Solution:
1. Check if PHP module is loaded
2. Restart Apache
3. Check error logs: C:\xampp\apache\logs\error.log
```

### WSL2 Issues

**Issue: WSL2 not starting**
```powershell
# Update WSL2
wsl --update

# Set WSL2 as default
wsl --set-default-version 2

# Check status
wsl --status
```

**Issue: Cannot access localhost from Windows**
```bash
# In WSL2, get IP address
ip addr show eth0

# Use that IP in Windows browser
http://<WSL2-IP>:8080
```

### General Issues

**Issue: Database file not writable**
```powershell
# In PowerShell (in project directory)
# Give write permissions
icacls database.db /grant Everyone:F
```

**Issue: Uploads folder not accessible**
```powershell
# Create uploads folder if missing
mkdir uploads

# Set permissions
icacls uploads /grant Everyone:F
```

**Issue: Page not found**
```
Solution:
1. Check .htaccess exists
2. Enable mod_rewrite in Apache
3. AllowOverride All in httpd.conf
4. Restart Apache
```

---

## Performance Tips

### For Docker Desktop

1. **Increase Resources**
   - Docker Desktop → Settings → Resources
   - CPU: 4+ cores
   - Memory: 4GB+
   - Swap: 2GB

2. **Enable WSL2 Backend**
   - Settings → General → Use WSL2
   - Much faster than Hyper-V

3. **File Sharing**
   - Settings → Resources → File Sharing
   - Add project directory

### For XAMPP

1. **Disable Unnecessary Modules**
   - Edit httpd.conf
   - Comment out unused LoadModule lines

2. **Adjust PHP Settings**
   - Edit php.ini:
   ```ini
   max_execution_time = 60
   memory_limit = 256M
   upload_max_filesize = 10M
   ```

---

## Security Note

⚠️ **IMPORTANT**: This application is intentionally vulnerable!

- **DO NOT** expose to the internet
- **DO NOT** use in production
- Run only on isolated/local network
- Use for educational purposes only

---

## Next Steps After Setup

1. **Verify Application Works**
   - Access home page
   - Login with admin/admin123
   - Test basic functionality

2. **Run Security Scans**
   - OWASP Threat Dragon (see THREAT_DRAGON_GUIDE.md)
   - OWASP ZAP
   - SonarQube
   - OWASP Dependency-Check

3. **Review Documentation**
   - README.md - Overview and scanning instructions
   - SECURITY_FIXES.md - How to fix vulnerabilities
   - QUICKSTART.md - Quick testing guide

---

## Quick Reference

### Docker Commands (PowerShell)

```powershell
# Start application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop application
docker-compose down

# Rebuild after changes
docker-compose up --build

# Remove all containers and volumes
docker-compose down -v

# Check running containers
docker ps

# Access container shell
docker exec -it vulnerable-demo-app bash
```

### XAMPP Commands

```
Start Apache:   Click "Start" in XAMPP Control Panel
Stop Apache:    Click "Stop" in XAMPP Control Panel
View Logs:      C:\xampp\apache\logs\error.log
Config:         C:\xampp\apache\conf\httpd.conf
```

### File Locations

```
Docker Method:
- Project: C:\Users\YourUsername\Documents\Demo-Code
- Access: http://localhost:8080

XAMPP Method:
- Project: C:\xampp\htdocs\vulnerable-app
- Access: http://localhost/vulnerable-app
- Logs: C:\xampp\apache\logs\

WSL2 Method:
- Project: \\wsl$\Ubuntu\home\username\Demo-Code
- Access: http://localhost:8080
```

---

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review README.md for detailed documentation
3. Check Docker Desktop/XAMPP documentation
4. Verify all prerequisites are met

---

**Recommended Method**: Docker Desktop - Most consistent across platforms and easiest to set up!
