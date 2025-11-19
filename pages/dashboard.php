<?php
// VULNERABLE Dashboard
// Security Issue #11: No authentication check
// Security Issue #12: Insecure direct object reference (IDOR)

// VULNERABILITY: Missing authentication
// Should check if user is logged in, but doesn't

$user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;
$username = isset($_SESSION['username']) ? $_SESSION['username'] : 'Guest';

// VULNERABILITY: SQL Injection in search functionality
$search = isset($_GET['search']) ? $_GET['search'] : '';
if ($search) {
    $query = "SELECT * FROM posts WHERE title LIKE '%$search%' OR content LIKE '%$search%'";
} else {
    $query = "SELECT * FROM posts ORDER BY created_at DESC LIMIT 10";
}

$posts = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Vulnerable Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="home">Home</a></li>
                <li><a href="dashboard" aria-current="page">Dashboard</a></li>
                <li><a href="profile">Profile</a></li>
                <li><a href="upload">Upload</a></li>
                <?php if ($user_id): ?>
                    <li><a href="logout">Logout (<?php echo $username; ?>)</a></li>
                <?php else: ?>
                    <li><a href="login">Login</a></li>
                <?php endif; ?>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section aria-labelledby="dashboard-heading">
            <h2 id="dashboard-heading">Dashboard</h2>
            
            <!-- VULNERABILITY: XSS in search -->
            <form method="GET" action="dashboard" class="search-form" role="search">
                <label for="search">Search Posts:</label>
                <input type="text" id="search" name="search" 
                       value="<?php echo $search; ?>" 
                       placeholder="Search...">
                <button type="submit">Search</button>
            </form>
            
            <div class="posts-container" role="list">
                <?php foreach ($posts as $post): ?>
                    <article class="post" role="listitem">
                        <!-- VULNERABILITY: XSS - No output encoding -->
                        <h3><?php echo $post['title']; ?></h3>
                        <div class="post-content">
                            <?php echo $post['content']; ?>
                        </div>
                        <p class="post-meta">
                            Posted on <?php echo $post['created_at']; ?>
                        </p>
                    </article>
                <?php endforeach; ?>
            </div>
            
            <?php if ($user_id): ?>
                <section class="new-post" aria-labelledby="new-post-heading">
                    <h3 id="new-post-heading">Create New Post</h3>
                    <form method="POST" action="post">
                        <div class="form-group">
                            <label for="title">Title:</label>
                            <input type="text" id="title" name="title" required aria-required="true">
                        </div>
                        <div class="form-group">
                            <label for="content">Content:</label>
                            <textarea id="content" name="content" rows="5" required aria-required="true"></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">Post</button>
                    </form>
                </section>
            <?php endif; ?>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
    
    <!-- VULNERABILITY: Loading vulnerable JavaScript library -->
    <script src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="assets/js/app.js"></script>
</body>
</html>
