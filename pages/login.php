<?php
// VULNERABLE Login Handler
// Security Issue #9: SQL Injection vulnerability

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];
    
    // VULNERABILITY: SQL Injection - direct string concatenation
    $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
    
    try {
        $stmt = $db->query($query);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            // VULNERABILITY: Storing sensitive data in session without encryption
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['username'] = $user['username'];
            $_SESSION['role'] = $user['role'];
            
            // VULNERABILITY: No session regeneration after login
            header('Location: dashboard');
            exit;
        } else {
            $error = "Invalid credentials";
        }
    } catch (PDOException $e) {
        // VULNERABILITY: Exposing database errors to users
        $error = "Database error: " . $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Vulnerable Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="home">Home</a></li>
                <li><a href="login" aria-current="page">Login</a></li>
                <li><a href="register">Register</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section class="login-container" aria-labelledby="login-heading">
            <h2 id="login-heading">Login</h2>
            
            <?php if (isset($error)): ?>
                <div class="error" role="alert" aria-live="polite">
                    <!-- VULNERABILITY: XSS - No output encoding -->
                    <?php echo $error; ?>
                </div>
            <?php endif; ?>
            
            <!-- VULNERABILITY: No CSRF protection -->
            <form method="POST" action="login" aria-labelledby="login-heading">
                <div class="form-group">
                    <label for="username">Username:</label>
                    <input type="text" id="username" name="username" required 
                           aria-required="true" autocomplete="username">
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required 
                           aria-required="true" autocomplete="current-password">
                </div>
                
                <button type="submit" class="btn btn-primary">Login</button>
            </form>
            
            <p>Don't have an account? <a href="register">Register here</a></p>
            
            <!-- VULNERABILITY: Information disclosure -->
            <div class="debug-info" style="margin-top: 20px; padding: 10px; background: #f0f0f0;">
                <small>Debug: Try username 'admin' with password 'admin123'</small>
            </div>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
</body>
</html>
