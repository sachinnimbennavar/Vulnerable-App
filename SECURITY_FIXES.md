# Security Fixes and Remediation Guide

## Overview
This document provides detailed remediation steps for all vulnerabilities found in the demo application.

## Critical Vulnerabilities - Fixes

### 1. SQL Injection

**Vulnerable Code** (`pages/login.php`):
```php
$query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
$stmt = $db->query($query);
```

**Fixed Code**:
```php
$query = "SELECT * FROM users WHERE username = :username AND password = :password";
$stmt = $db->prepare($query);
$stmt->bindParam(':username', $username, PDO::PARAM_STR);
$stmt->bindParam(':password', $hashedPassword, PDO::PARAM_STR);
$stmt->execute();
```

**Remediation Steps**:
- Use prepared statements with parameter binding
- Never concatenate user input into SQL queries
- Validate and sanitize all inputs
- Use ORM frameworks when possible

### 2. Cross-Site Scripting (XSS)

**Vulnerable Code** (`pages/dashboard.php`):
```php
<h3><?php echo $post['title']; ?></h3>
<div><?php echo $post['content']; ?></div>
```

**Fixed Code**:
```php
<h3><?php echo htmlspecialchars($post['title'], ENT_QUOTES, 'UTF-8'); ?></h3>
<div><?php echo htmlspecialchars($post['content'], ENT_QUOTES, 'UTF-8'); ?></div>
```

**Remediation Steps**:
- Use `htmlspecialchars()` or `htmlentities()` for output encoding
- Implement Content Security Policy (CSP) headers
- Validate input on server-side
- Use templating engines with auto-escaping

### 3. Hardcoded Credentials

**Vulnerable Code** (`config.php`):
```php
define('DB_PASSWORD', 'admin123');
define('API_SECRET_KEY', 'sk_live_4eC39HqLyjWDarjtT1zdp7dc');
```

**Fixed Code**:
```php
define('DB_PASSWORD', getenv('DB_PASSWORD'));
define('API_SECRET_KEY', getenv('API_SECRET_KEY'));

// .env file (not committed to git)
DB_PASSWORD=strong_random_password_here
API_SECRET_KEY=secure_api_key_here
```

**Remediation Steps**:
- Use environment variables for sensitive data
- Store credentials in secure vaults (e.g., HashiCorp Vault)
- Never commit secrets to version control
- Use `.env` files (add to `.gitignore`)
- Rotate credentials regularly

### 4. Plain Text Password Storage

**Vulnerable Code** (`pages/register.php`):
```php
$query = "INSERT INTO users (username, password, email) VALUES ('$username', '$password', '$email')";
```

**Fixed Code**:
```php
$hashedPassword = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
$query = "INSERT INTO users (username, password, email) VALUES (:username, :password, :email)";
$stmt = $db->prepare($query);
$stmt->bindParam(':username', $username);
$stmt->bindParam(':password', $hashedPassword);
$stmt->bindParam(':email', $email);
$stmt->execute();
```

**Remediation Steps**:
- Use `password_hash()` with bcrypt or Argon2
- Never store passwords in plain text
- Use strong hashing algorithms
- Implement password strength requirements
- Add salt automatically (password_hash does this)

### 5. Unrestricted File Upload

**Vulnerable Code** (`pages/upload.php`):
```php
$filename = $_FILES['file']['name'];
$target_file = $target_dir . $filename;
move_uploaded_file($_FILES['file']['tmp_name'], $target_file);
```

**Fixed Code**:
```php
// Whitelist allowed extensions
$allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf'];
$file_extension = strtolower(pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION));

if (!in_array($file_extension, $allowed_extensions)) {
    die("Invalid file type");
}

// Check file size (5MB max)
if ($_FILES['file']['size'] > 5 * 1024 * 1024) {
    die("File too large");
}

// Generate random filename
$filename = bin2hex(random_bytes(16)) . '.' . $file_extension;
$target_file = $target_dir . $filename;

// Verify MIME type
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime = finfo_file($finfo, $_FILES['file']['tmp_name']);
$allowed_mimes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];

if (!in_array($mime, $allowed_mimes)) {
    die("Invalid MIME type");
}

// Move file with restricted permissions
move_uploaded_file($_FILES['file']['tmp_name'], $target_file);
chmod($target_file, 0644);
```

**Remediation Steps**:
- Validate file extensions (whitelist)
- Check MIME types
- Limit file sizes
- Generate random filenames
- Store uploads outside web root
- Scan for malware
- Set proper file permissions

## High Severity Vulnerabilities - Fixes

### 6. Insecure Direct Object Reference (IDOR)

**Vulnerable Code** (`pages/profile.php`):
```php
$profile_id = isset($_GET['id']) ? $_GET['id'] : $_SESSION['user_id'];
$query = "SELECT * FROM users WHERE id = $profile_id";
```

**Fixed Code**:
```php
// Only allow users to view their own profile
$profile_id = $_SESSION['user_id'];

// Or implement proper authorization check
if ($_GET['id'] != $_SESSION['user_id'] && $_SESSION['role'] != 'admin') {
    die("Access denied");
}

$query = "SELECT * FROM users WHERE id = :id";
$stmt = $db->prepare($query);
$stmt->bindParam(':id', $profile_id, PDO::PARAM_INT);
$stmt->execute();
```

**Remediation Steps**:
- Implement access control checks
- Verify user authorization before data access
- Use indirect references (tokens instead of IDs)
- Log access attempts
- Never expose database IDs directly

### 7. Missing CSRF Protection

**Vulnerable Code** (all forms):
```html
<form method="POST" action="login">
    <!-- No CSRF token -->
</form>
```

**Fixed Code**:
```php
// Generate CSRF token
if (!isset($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// In form
<form method="POST" action="login">
    <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
    <!-- other fields -->
</form>

// Validate on submission
if ($_POST['csrf_token'] !== $_SESSION['csrf_token']) {
    die("CSRF token validation failed");
}
```

**Remediation Steps**:
- Generate unique CSRF tokens per session
- Include tokens in all state-changing forms
- Validate tokens on server-side
- Use SameSite cookie attribute
- Implement double-submit cookie pattern

### 8. Session Management Issues

**Vulnerable Code** (`config.php`):
```php
ini_set('session.cookie_httponly', '0');
ini_set('session.cookie_secure', '0');
```

**Fixed Code**:
```php
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_secure', '1');
ini_set('session.cookie_samesite', 'Strict');
ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
ini_set('session.cookie_lifetime', 0);

session_start();

// Regenerate session ID on login
if (isset($_POST['login'])) {
    session_regenerate_id(true);
}

// Implement session timeout
if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity'] > 1800)) {
    session_unset();
    session_destroy();
    header('Location: login');
    exit;
}
$_SESSION['last_activity'] = time();
```

**Remediation Steps**:
- Set HttpOnly flag on cookies
- Set Secure flag (HTTPS only)
- Use SameSite attribute
- Regenerate session IDs after login
- Implement session timeout
- Use secure session storage

## Medium Severity Vulnerabilities - Fixes

### 9. Vulnerable Dependencies

**Current Dependencies** (`composer.json`):
```json
{
  "monolog/monolog": "1.23.0",
  "symfony/yaml": "3.4.0",
  "twig/twig": "1.42.0"
}
```

**Fixed Dependencies**:
```json
{
  "monolog/monolog": "^3.5",
  "symfony/yaml": "^6.4",
  "twig/twig": "^3.8"
}
```

**Remediation Steps**:
```bash
# Update dependencies
composer update

# Audit for vulnerabilities
composer audit

# Keep dependencies updated regularly
# Use Dependabot or Renovate for automation
```

### 10. Missing Security Headers

**Fixed Code** (add to `index.php` or `.htaccess`):
```php
header("X-Frame-Options: DENY");
header("X-Content-Type-Options: nosniff");
header("X-XSS-Protection: 1; mode=block");
header("Strict-Transport-Security: max-age=31536000; includeSubDomains");
header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'");
header("Referrer-Policy: strict-origin-when-cross-origin");
header("Permissions-Policy: geolocation=(), microphone=(), camera=()");
```

**Or in `.htaccess`**:
```apache
<IfModule mod_headers.c>
    Header always set X-Frame-Options "DENY"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set Content-Security-Policy "default-src 'self'"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>
```

### 11. Information Disclosure

**Vulnerable Code** (`config.php`):
```php
define('DEBUG_MODE', true);
error_reporting(E_ALL);
ini_set('display_errors', '1');
```

**Fixed Code**:
```php
define('DEBUG_MODE', false);
error_reporting(0);
ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', '/var/log/php/error.log');

// Custom error handler
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    error_log("Error [$errno]: $errstr in $errfile on line $errline");
    // Show generic error to user
    echo "An error occurred. Please try again later.";
});
```

**Remediation Steps**:
- Disable error display in production
- Log errors to secure location
- Use custom error pages
- Remove debug information
- Don't expose stack traces

### 12. Weak Authentication

**Fixed Authentication Flow**:
```php
// config_secure.php
function authenticateUser($username, $password) {
    global $db;
    
    // Rate limiting (prevent brute force)
    if (isRateLimited($username)) {
        return ['success' => false, 'message' => 'Too many attempts'];
    }
    
    $query = "SELECT * FROM users WHERE username = :username LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':username', $username);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user && password_verify($password, $user['password'])) {
        // Regenerate session
        session_regenerate_id(true);
        
        // Set session variables
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['username'] = $user['username'];
        $_SESSION['role'] = $user['role'];
        $_SESSION['last_activity'] = time();
        
        // Log successful login
        logSecurityEvent('login_success', $username);
        
        return ['success' => true];
    } else {
        // Log failed attempt
        logSecurityEvent('login_failed', $username);
        incrementFailedAttempts($username);
        
        return ['success' => false, 'message' => 'Invalid credentials'];
    }
}

function isRateLimited($username) {
    // Check failed attempts in last 15 minutes
    $attempts = getFailedAttempts($username);
    return $attempts > 5;
}
```

## JavaScript Vulnerabilities - Fixes

### 13. Remove eval() Usage

**Vulnerable Code** (`assets/js/app.js`):
```javascript
var customCode = urlParams.get('code');
if (customCode) {
    eval(customCode); // DANGEROUS!
}
```

**Fixed Code**:
```javascript
// Remove entirely or use safe alternatives
// If dynamic code execution is needed, use Function constructor with strict validation
// Better: Don't allow dynamic code execution at all
```

### 14. Prevent XSS in JavaScript

**Vulnerable Code**:
```javascript
$('.message-container').html(message);
```

**Fixed Code**:
```javascript
// Use text() instead of html()
$('.message-container').text(message);

// Or properly encode HTML
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
$('.message-container').html(escapeHtml(message));
```

### 15. Update jQuery

**Vulnerable Version**:
```html
<script src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
```

**Fixed Version**:
```html
<script src="https://code.jquery.com/jquery-3.7.1.min.js" 
        integrity="sha384-1H217gwSVyLSIfaLxHbE7dRb3v4mYCKbpQvzx0cegeju1MVsGrX5xXxAvs/HgeFs" 
        crossorigin="anonymous"></script>
```

## Configuration Hardening

### Apache Security Configuration

```apache
# httpd.conf (Secure Version)
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html
    
    # Enable SSL
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem
    
    <Directory /var/www/html>
        Options -Indexes -FollowSymLinks
        AllowOverride None
        Require all granted
        
        # Prevent access to sensitive files
        <FilesMatch "^\.">
            Require all denied
        </FilesMatch>
    </Directory>
    
    # Disable server signature
    ServerSignature Off
    ServerTokens Prod
    
    # Restrict upload directory
    <Directory /var/www/html/uploads>
        php_flag engine off
        Options -ExecCGI
        AddType text/plain .php .php3 .phtml
    </Directory>
</VirtualHost>
```

### Docker Security Configuration

```yaml
# docker-compose.yml (Secure Version)
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8443:443"
    volumes:
      - ./src:/var/www/html:ro  # Read-only
    environment:
      - APACHE_RUN_USER=www-data
      - APACHE_RUN_GROUP=www-data
    env_file:
      - .env  # Load from .env file
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
```

## Verification Steps

### After Applying Fixes

1. **Re-run OWASP Dependency-Check**
```bash
./dependency-check/bin/dependency-check.sh --project "Secure-App" --scan ./secure
```
Expected: 0 critical vulnerabilities

2. **Re-run OWASP ZAP**
```bash
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://localhost:8443
```
Expected: Significantly reduced alerts

3. **Re-run SonarQube**
```bash
./sonar-scanner --project-key=secure-app
```
Expected: No blocker/critical security issues

4. **Manual Testing**
- Try SQL injection: Should fail
- Try XSS: Should be encoded
- Try IDOR: Should be blocked
- Check security headers: Should be present

## Additional Security Measures

### 1. Input Validation
```php
function validateInput($data, $type) {
    switch($type) {
        case 'email':
            return filter_var($data, FILTER_VALIDATE_EMAIL);
        case 'username':
            return preg_match('/^[a-zA-Z0-9_]{3,20}$/', $data);
        case 'integer':
            return filter_var($data, FILTER_VALIDATE_INT);
        default:
            return false;
    }
}
```

### 2. Security Logging
```php
function logSecurityEvent($event, $details) {
    $log = sprintf(
        "[%s] %s: %s - IP: %s - User: %s\n",
        date('Y-m-d H:i:s'),
        $event,
        $details,
        $_SERVER['REMOTE_ADDR'],
        $_SESSION['username'] ?? 'anonymous'
    );
    error_log($log, 3, '/var/log/security.log');
}
```

### 3. Password Policy
```php
function validatePassword($password) {
    $errors = [];
    
    if (strlen($password) < 12) {
        $errors[] = "Password must be at least 12 characters";
    }
    if (!preg_match('/[A-Z]/', $password)) {
        $errors[] = "Password must contain uppercase letter";
    }
    if (!preg_match('/[a-z]/', $password)) {
        $errors[] = "Password must contain lowercase letter";
    }
    if (!preg_match('/[0-9]/', $password)) {
        $errors[] = "Password must contain number";
    }
    if (!preg_match('/[^A-Za-z0-9]/', $password)) {
        $errors[] = "Password must contain special character";
    }
    
    return empty($errors) ? true : $errors;
}
```

## Security Checklist

- [ ] All SQL queries use prepared statements
- [ ] All output is properly encoded
- [ ] No hardcoded credentials in code
- [ ] Passwords are hashed with bcrypt/Argon2
- [ ] File uploads are validated and restricted
- [ ] CSRF tokens on all forms
- [ ] Session cookies have Secure, HttpOnly, SameSite flags
- [ ] Security headers are set
- [ ] Error messages don't expose sensitive info
- [ ] Dependencies are up-to-date
- [ ] HTTPS is enforced
- [ ] Input validation on all user inputs
- [ ] Access control checks on all sensitive operations
- [ ] Security events are logged
- [ ] Rate limiting on authentication
- [ ] Principle of least privilege applied

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [PHP Security Best Practices](https://www.php.net/manual/en/security.php)
- [CWE/SANS Top 25](https://www.sans.org/top25-software-errors/)
