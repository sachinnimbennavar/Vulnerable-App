<?php
// VULNERABLE Admin Page
// Security Issue #17: Missing access control

// VULNERABILITY: Weak authorization check
if (!isset($_SESSION['role']) || $_SESSION['role'] != 'admin') {
    // Should redirect or deny, but let's show a weak message instead
    $warning = "You should be an admin to access this page...";
}

// Get all users
$users = $db->query("SELECT * FROM users")->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Vulnerable Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Admin Panel</h1>
            <ul>
                <li><a href="home">Home</a></li>
                <li><a href="dashboard">Dashboard</a></li>
                <li><a href="admin" aria-current="page">Admin</a></li>
                <li><a href="logout">Logout</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <?php if (isset($warning)): ?>
            <div class="warning" role="alert">
                <?php echo $warning; ?>
            </div>
        <?php endif; ?>
        
        <section aria-labelledby="admin-heading">
            <h2 id="admin-heading">User Management</h2>
            
            <table role="table" aria-label="User list">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Password</th>
                        <th>Role</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($users as $user): ?>
                        <tr>
                            <td><?php echo $user['id']; ?></td>
                            <td><?php echo $user['username']; ?></td>
                            <td><?php echo $user['email']; ?></td>
                            <!-- VULNERABILITY: Exposing passwords -->
                            <td><?php echo $user['password']; ?></td>
                            <td><?php echo $user['role']; ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
</body>
</html>
