<?php
// VULNERABLE Registration Handler
// Security Issue #10: No input validation

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];
    $email = $_POST['email'];
    
    // VULNERABILITY: No password strength validation
    // VULNERABILITY: Storing passwords in plain text
    // VULNERABILITY: SQL Injection via string concatenation
    $query = "INSERT INTO users (username, password, email) VALUES ('$username', '$password', '$email')";
    
    try {
        $db->exec($query);
        header('Location: login');
        exit;
    } catch (PDOException $e) {
        $error = "Registration failed: " . $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Vulnerable Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="home">Home</a></li>
                <li><a href="login">Login</a></li>
                <li><a href="register" aria-current="page">Register</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section class="register-container" aria-labelledby="register-heading">
            <h2 id="register-heading">Register New Account</h2>
            
            <?php if (isset($error)): ?>
                <div class="error" role="alert" aria-live="polite">
                    <?php echo $error; ?>
                </div>
            <?php endif; ?>
            
            <form method="POST" action="register" aria-labelledby="register-heading">
                <div class="form-group">
                    <label for="username">Username:</label>
                    <input type="text" id="username" name="username" required 
                           aria-required="true" autocomplete="username">
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" id="email" name="email" required 
                           aria-required="true" autocomplete="email">
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required 
                           aria-required="true" autocomplete="new-password">
                </div>
                
                <button type="submit" class="btn btn-primary">Register</button>
            </form>
            
            <p>Already have an account? <a href="login">Login here</a></p>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
</body>
</html>
