<?php
// Main application entry point
require_once 'config.php';

// Security Issue #4: Insecure session configuration
if (session_status() === PHP_SESSION_NONE) {
    ini_set('session.cookie_httponly', '0'); // VULNERABILITY: Missing HttpOnly flag
    ini_set('session.cookie_secure', '0'); // VULNERABILITY: Missing Secure flag
    ini_set('session.use_strict_mode', '0'); // VULNERABILITY: Weak session security
    session_start();
}

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
