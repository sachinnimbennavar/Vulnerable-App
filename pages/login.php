<?php
session_start();
require_once __DIR__ . '/../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Vulnerable SQL query
    $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
    $stmt = $db->query($query);
    $user = $stmt->fetch();

    if ($user) {
        // Set session variables
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['username'] = $user['username'];
        header('Location: dashboard');
        exit;
    } else {
        $error = "Invalid credentials";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Secure Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Secure Demo Application</h1>
            <ul>
                <li><a href="home">Home</a></li>
                <li><a href="login" aria-current="page">Login</a></li>
                <li><a href="register">Register</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section class="login-container" aria-labelledby="login-heading">
            <h2 id="login-heading">Secure Login</h2>
            
            <?php if (isset($error)): ?>
                <div class="error" role="alert" aria-live="polite">
                    <?php echo $error; ?>
                </div>
            <?php endif; ?>
            
            <form method="POST" action="login" aria-labelledby="login-heading">
                
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
            
            <p>Don't have an account? <a href="register">Register here</a></p>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Secure Demo App - Security Best Practices Applied</p>
    </footer>
</body>
</html>