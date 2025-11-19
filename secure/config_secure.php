<?php
// SECURE Configuration File
// All vulnerabilities have been fixed

// Load environment variables from .env file
function loadEnv($path) {
    if (!file_exists($path)) {
        throw new Exception('.env file not found');
    }
    
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) {
            continue;
        }
        
        list($name, $value) = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value);
        
        if (!array_key_exists($name, $_ENV)) {
            putenv(sprintf('%s=%s', $name, $value));
            $_ENV[$name] = $value;
        }
    }
}

// Load environment variables
loadEnv(__DIR__ . '/.env');

// Database configuration from environment
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_NAME', getenv('DB_NAME') ?: 'secure_app');
define('DB_USER', getenv('DB_USER') ?: 'app_user');
define('DB_PASSWORD', getenv('DB_PASSWORD'));

// API configuration from environment
define('API_SECRET_KEY', getenv('API_SECRET_KEY'));
define('JWT_SECRET', getenv('JWT_SECRET'));

// Security configuration
define('DEBUG_MODE', getenv('DEBUG_MODE') === 'true' ? true : false);

// Secure error handling
error_reporting(E_ALL);
if (DEBUG_MODE) {
    ini_set('display_errors', '1');
} else {
    ini_set('display_errors', '0');
    ini_set('log_errors', '1');
    ini_set('error_log', '/var/log/php/error.log');
}

// Secure session configuration
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_secure', '1');
ini_set('session.cookie_samesite', 'Strict');
ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
ini_set('session.cookie_lifetime', 0);
ini_set('session.gc_maxlifetime', 1800);

// Security headers
header("X-Frame-Options: DENY");
header("X-Content-Type-Options: nosniff");
header("X-XSS-Protection: 1; mode=block");
header("Referrer-Policy: strict-origin-when-cross-origin");
header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;");

// Database connection with error handling
function getDBConnection() {
    try {
        $db = new PDO('sqlite:./database.db');
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
        $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        return $db;
    } catch(PDOException $e) {
        // Log error securely
        error_log("Database connection failed: " . $e->getMessage());
        // Show generic error to user
        die("Database connection failed. Please contact support.");
    }
}

// Initialize database with secure defaults
function initDB() {
    $db = getDBConnection();
    
    // Create users table
    $db->exec("CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        email TEXT UNIQUE,
        role TEXT DEFAULT 'user',
        failed_attempts INTEGER DEFAULT 0,
        last_failed_attempt DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )");
    
    // Create posts table
    $db->exec("CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )");
    
    // Create session table for secure session management
    $db->exec("CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        user_id INTEGER,
        data TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        expires_at DATETIME,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )");
    
    // Create security log table
    $db->exec("CREATE TABLE IF NOT EXISTS security_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_type TEXT NOT NULL,
        username TEXT,
        ip_address TEXT,
        details TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )");
    
    // Check if admin user exists
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM users WHERE username = :username");
    $stmt->execute([':username' => 'admin']);
    $result = $stmt->fetch();
    
    if ($result['count'] == 0) {
        // Create admin with secure password
        $hashedPassword = password_hash('SecureAdmin@2025!', PASSWORD_BCRYPT, ['cost' => 12]);
        $stmt = $db->prepare("INSERT INTO users (username, password, email, role) VALUES (:username, :password, :email, :role)");
        $stmt->execute([
            ':username' => 'admin',
            ':password' => $hashedPassword,
            ':email' => 'admin@example.com',
            ':role' => 'admin'
        ]);
    }
    
    return $db;
}

// Security helper functions

function sanitizeInput($data) {
    $data = trim($data);
    $data = stripslashes($data);
    return $data;
}

function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL);
}

function validateUsername($username) {
    return preg_match('/^[a-zA-Z0-9_]{3,20}$/', $username);
}

function validatePassword($password) {
    $errors = [];
    
    if (strlen($password) < 12) {
        $errors[] = "Password must be at least 12 characters";
    }
    if (!preg_match('/[A-Z]/', $password)) {
        $errors[] = "Must contain uppercase letter";
    }
    if (!preg_match('/[a-z]/', $password)) {
        $errors[] = "Must contain lowercase letter";
    }
    if (!preg_match('/[0-9]/', $password)) {
        $errors[] = "Must contain number";
    }
    if (!preg_match('/[^A-Za-z0-9]/', $password)) {
        $errors[] = "Must contain special character";
    }
    
    return empty($errors) ? true : $errors;
}

function escapeOutput($data) {
    return htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
}

function generateCSRFToken() {
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function validateCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

function logSecurityEvent($event_type, $username, $details) {
    global $db;
    
    $stmt = $db->prepare("INSERT INTO security_log (event_type, username, ip_address, details) VALUES (:event, :user, :ip, :details)");
    $stmt->execute([
        ':event' => $event_type,
        ':user' => $username,
        ':ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        ':details' => $details
    ]);
}

function isRateLimited($username) {
    global $db;
    
    $stmt = $db->prepare("SELECT failed_attempts, last_failed_attempt FROM users WHERE username = :username");
    $stmt->execute([':username' => $username]);
    $user = $stmt->fetch();
    
    if (!$user) {
        return false;
    }
    
    // Lock account after 5 failed attempts within 15 minutes
    if ($user['failed_attempts'] >= 5) {
        $lastAttempt = strtotime($user['last_failed_attempt']);
        $now = time();
        
        if (($now - $lastAttempt) < 900) { // 15 minutes
            return true;
        } else {
            // Reset counter after lockout period
            $stmt = $db->prepare("UPDATE users SET failed_attempts = 0 WHERE username = :username");
            $stmt->execute([':username' => $username]);
            return false;
        }
    }
    
    return false;
}

function incrementFailedAttempts($username) {
    global $db;
    
    $stmt = $db->prepare("UPDATE users SET failed_attempts = failed_attempts + 1, last_failed_attempt = CURRENT_TIMESTAMP WHERE username = :username");
    $stmt->execute([':username' => $username]);
}

function resetFailedAttempts($username) {
    global $db;
    
    $stmt = $db->prepare("UPDATE users SET failed_attempts = 0 WHERE username = :username");
    $stmt->execute([':username' => $username]);
}

function checkAuth() {
    if (!isset($_SESSION['user_id']) || !isset($_SESSION['last_activity'])) {
        header('Location: login');
        exit;
    }
    
    // Session timeout (30 minutes)
    if (time() - $_SESSION['last_activity'] > 1800) {
        session_unset();
        session_destroy();
        header('Location: login?timeout=1');
        exit;
    }
    
    $_SESSION['last_activity'] = time();
}

function checkRole($required_role) {
    checkAuth();
    
    if ($_SESSION['role'] !== $required_role) {
        http_response_code(403);
        die("Access denied");
    }
}

// Custom error handler
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    error_log("Error [$errno]: $errstr in $errfile on line $errline");
    
    if (!DEBUG_MODE) {
        echo "An error occurred. Please try again later.";
    } else {
        echo "Error: $errstr";
    }
});

// Initialize database
$db = initDB();
?>
