<?php
// SECURE Profile Page

$db = getDBConnection();

// Ensure user is logged in
if (!isset($_SESSION['user_id'])) {
    header('Location: ' . BASE_URL . 'login');
    exit;
}

// Determine the profile ID to view. Default to the logged-in user.
$profile_id = isset($_GET['id']) ? (int)$_GET['id'] : $_SESSION['user_id'];
$user = null;
$error = null;

// Authorization check: Allow if it's the user's own profile or if the user is an admin.
if ($profile_id !== $_SESSION['user_id'] && (!isset($_SESSION['role']) || $_SESSION['role'] !== 'admin')) {
    // Use a generic message to avoid disclosing user existence
    $error = "Profile not found or you don't have permission to view it.";
} else {
    // Fetch profile data using a prepared statement to prevent SQLi.
    // Exclude the password field for security.
    $query = "SELECT id, username, email, role, created_at FROM users WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $profile_id, PDO::PARAM_INT);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        $error = "Profile not found.";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - Vulnerable Demo App</title>
    <link rel="stylesheet" href="<?php echo BASE_URL; ?>assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="<?php echo BASE_URL; ?>home">Home</a></li>
                <li><a href="<?php echo BASE_URL; ?>dashboard">Dashboard</a></li>
                <li><a href="<?php echo BASE_URL; ?>profile" aria-current="page">Profile</a></li>
                <li><a href="<?php echo BASE_URL; ?>logout">Logout</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section aria-labelledby="profile-heading">
            <h2 id="profile-heading">User Profile</h2>
            
            <?php if ($user): ?>
                <div class="profile-info">
                    <p><strong>Username:</strong> <?php echo htmlspecialchars($user['username'], ENT_QUOTES, 'UTF-8'); ?></p>
                    <p><strong>Email:</strong> <?php echo htmlspecialchars($user['email'], ENT_QUOTES, 'UTF-8'); ?></p>
                    <p><strong>Role:</strong> <?php echo htmlspecialchars($user['role'], ENT_QUOTES, 'UTF-8'); ?></p>
                    <p><strong>Member since:</strong> <?php echo htmlspecialchars($user['created_at'], ENT_QUOTES, 'UTF-8'); ?></p>
                </div>
            <?php else: ?>
                <div class="error" role="alert"><?php echo $error ?? 'User not found'; ?></div>
            <?php endif; ?>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
</body>
</html>
