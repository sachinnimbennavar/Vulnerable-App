<?php
// VULNERABLE Profile Page
// Security Issue #16: IDOR vulnerability

session_start();
require_once '../config.php';

$db = getDBConnection();

$profile_id = isset($_GET['id']) ? $_GET['id'] : $_SESSION['user_id'];

// VULNERABILITY: No authorization check - anyone can view any profile
$query = "SELECT * FROM users WHERE id = $profile_id";
$user = $db->query($query)->fetch(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - Vulnerable Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="home">Home</a></li>
                <li><a href="dashboard">Dashboard</a></li>
                <li><a href="profile" aria-current="page">Profile</a></li>
                <li><a href="logout">Logout</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section aria-labelledby="profile-heading">
            <h2 id="profile-heading">User Profile</h2>
            
            <?php if ($user): ?>
                <div class="profile-info">
                    <p><strong>Username:</strong> <?php echo $user['username']; ?></p>
                    <p><strong>Email:</strong> <?php echo $user['email']; ?></p>
                    <p><strong>Role:</strong> <?php echo $user['role']; ?></p>
                    <!-- VULNERABILITY: Exposing password -->
                    <p><strong>Password:</strong> <?php echo $user['password']; ?></p>
                    <p><strong>Member since:</strong> <?php echo $user['created_at']; ?></p>
                </div>
            <?php else: ?>
                <p>User not found</p>
            <?php endif; ?>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
</body>
</html>
