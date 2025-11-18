<?php
// VULNERABLE: Configuration with hardcoded credentials and sensitive information
// Security Issue #1: Hard-coded credentials (detected by SonarQube, BlackDuck)

define('DB_HOST', 'localhost');
define('DB_NAME', 'vulnerable_app');
define('DB_USER', 'admin');
define('DB_PASSWORD', 'admin123'); // VULNERABILITY: Hardcoded password

// Security Issue #2: Hardcoded API keys
define('API_SECRET_KEY', 'sk_live_4eC39HqLyjWDarjtT1zdp7dc'); // VULNERABILITY: Exposed API key
define('JWT_SECRET', 'my_super_secret_jwt_key_12345'); // VULNERABILITY: Weak secret

// Security Issue #3: Debug mode enabled in production
define('DEBUG_MODE', true); // VULNERABILITY: Debug enabled
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Security Issue #4: Insecure session configuration
ini_set('session.cookie_httponly', '0'); // VULNERABILITY: Missing HttpOnly flag
ini_set('session.cookie_secure', '0'); // VULNERABILITY: Missing Secure flag
ini_set('session.use_strict_mode', '0'); // VULNERABILITY: Weak session security

// Database connection function with no security
function getDBConnection() {
    try {
        // VULNERABILITY: Using SQLite with no access controls
        $db = new PDO('sqlite:./database.db');
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $db;
    } catch(PDOException $e) {
        // VULNERABILITY: Exposing detailed error messages
        die("Connection failed: " . $e->getMessage());
    }
}

// Initialize database
function initDB() {
    $db = getDBConnection();
    
    // Create users table
    $db->exec("CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT,
        role TEXT DEFAULT 'user',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )");
    
    // Create posts table
    $db->exec("CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        content TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )");
    
    // VULNERABILITY: Creating default admin user with weak password
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM users WHERE username = 'admin'");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($result['count'] == 0) {
        // VULNERABILITY: Storing password in plain text
        $db->exec("INSERT INTO users (username, password, email, role) VALUES 
                   ('admin', 'admin123', 'admin@example.com', 'admin')");
    }
    
    return $db;
}

// Security Issue #5: No CSRF protection
// Security Issue #6: No input validation
// Security Issue #7: No output encoding
?>
