<?php
require_once 'setup_db.php';
// Main application entry point

// --- BEGIN SECURITY HEADERS ---
header("X-Frame-Options: DENY");
header("X-Content-Type-Options: nosniff");
header("X-XSS-Protection: 1; mode=block");
header("Strict-Transport-Security: max-age=31536000; includeSubDomains");
// A basic CSP. A real-world application would need a more detailed policy.
header("Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'");
header("Referrer-Policy: strict-origin-when-cross-origin");
header("Permissions-Policy: geolocation=(), microphone=(), camera=()");
// --- END SECURITY HEADERS ---

require_once 'config.php';

// --- SECURE SESSION MANAGEMENT ---
if (session_status() === PHP_SESSION_NONE) {
    // Set secure session cookie parameters
    ini_set('session.cookie_httponly', '1');
    ini_set('session.cookie_secure', '1'); // For production, ensure you're using HTTPS
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    ini_set('session.cookie_samesite', 'Strict');
    
    session_start();
}

// Session timeout logic (30 minutes)
if (isset($_SESSION['user_id']) && isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity'] > 1800)) {
    // Unset all session variables
    $_SESSION = array();
    // Destroy the session
    session_destroy();
    // Redirect to login page with a message
    header('Location: ' . BASE_URL . 'login?status=timeout');
    exit;
}
$_SESSION['last_activity'] = time(); // Update last activity time stamp

// Generate CSRF token if it doesn't exist for the session
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
// --- END SECURE SESSION MANAGEMENT ---

// Initialize database
$db = initDB();

// Get the requested URL
$url = isset($_GET['url']) ? $_GET['url'] : 'home';

// VULNERABILITY: No input sanitization on routing
// Security Issue #8: Path traversal vulnerability
$page = explode('/', $url)[0];

// Route handling
switch($page) {
    case 'login':
        include 'pages/login.php';
        break;
    case 'register':
        include 'pages/register.php';
        break;
    case 'dashboard':
        include 'pages/dashboard.php';
        break;
    case 'profile':
        include 'pages/profile.php';
        break;
    case 'post':
        include 'pages/post.php';
        break;
    case 'upload':
        include 'pages/upload.php';
        break;
    case 'logout':
        include 'pages/logout.php';
        break;
    case 'admin':
        include 'pages/admin.php';
        break;
    case 'api':
        include 'api/api.php';
        break;
    case 'home':
    default:
        include 'pages/home.php';
        break;
}
?>
