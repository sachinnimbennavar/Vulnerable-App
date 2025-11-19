<?php
// SECURE Login Handler
require_once '../secure/config_secure.php';

session_start();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Validate CSRF token
    if (!isset($_POST['csrf_token']) || !validateCSRFToken($_POST['csrf_token'])) {
        $error = "Invalid request";
        logSecurityEvent('csrf_failure', $_POST['username'] ?? 'unknown', 'CSRF token validation failed');
    } else {
        $username = sanitizeInput($_POST['username']);
        $password = $_POST['password'];
        
        // Validate input
        if (!validateUsername($username)) {
            $error = "Invalid username format";
        } elseif (isRateLimited($username)) {
            $error = "Account temporarily locked due to too many failed attempts";
            logSecurityEvent('rate_limit', $username, 'Account locked');
        } else {
            // Prepared statement to prevent SQL injection
            $query = "SELECT * FROM users WHERE username = :username LIMIT 1";
            
            try {
                $stmt = $db->prepare($query);
                $stmt->bindParam(':username', $username, PDO::PARAM_STR);
                $stmt->execute();
                $user = $stmt->fetch();
                
                if ($user && password_verify($password, $user['password'])) {
                    // Regenerate session ID to prevent session fixation
                    session_regenerate_id(true);
                    
                    // Set session variables
                    $_SESSION['user_id'] = $user['id'];
                    $_SESSION['username'] = $user['username'];
                    $_SESSION['role'] = $user['role'];
                    $_SESSION['last_activity'] = time();
                    
                    // Reset failed attempts
                    resetFailedAttempts($username);
                    
                    // Log successful login
                    logSecurityEvent('login_success', $username, 'User logged in successfully');
                    
                    header('Location: ../dashboard');
                    exit;
                } else {
                    // Increment failed attempts
                    incrementFailedAttempts($username);
                    
                    // Log failed attempt
                    logSecurityEvent('login_failed', $username, 'Invalid credentials');
                    
                    $error = "Invalid credentials";
                }
            } catch (PDOException $e) {
                error_log("Login error: " . $e->getMessage());
                $error = "An error occurred. Please try again later.";
            }
        }
    }
}

// Generate CSRF token
$csrf_token = generateCSRFToken();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Secure Demo App</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Secure Demo Application</h1>
            <ul>
                <li><a href="../home">Home</a></li>
                <li><a href="login_secure.php" aria-current="page">Login</a></li>
                <li><a href="register_secure.php">Register</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section class="login-container" aria-labelledby="login-heading">
            <h2 id="login-heading">Secure Login</h2>
            
            <?php if (isset($error)): ?>
                <div class="error" role="alert" aria-live="polite">
                    <?php echo escapeOutput($error); ?>
                </div>
            <?php endif; ?>
            
            <form method="POST" action="login_secure.php" aria-labelledby="login-heading">
                <input type="hidden" name="csrf_token" value="<?php echo escapeOutput($csrf_token); ?>">
                
                <div class="form-group">
                    <label for="username">Username:</label>
                    <input type="text" id="username" name="username" required 
                           aria-required="true" autocomplete="username"
                           pattern="[a-zA-Z0-9_]{3,20}"
                           title="Username must be 3-20 characters, letters, numbers, and underscores only">
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required 
                           aria-required="true" autocomplete="current-password">
                </div>
                
                <button type="submit" class="btn btn-primary">Login</button>
            </form>
            
            <p>Don't have an account? <a href="register_secure.php">Register here</a></p>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Secure Demo App - Security Best Practices Applied</p>
    </footer>
</body>
</html>
