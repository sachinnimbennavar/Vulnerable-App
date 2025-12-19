<?php
// SECURE Dashboard

$db = getDBConnection();

// Enforce authentication
if (!isset($_SESSION['user_id'])) {
    header('Location: ' . BASE_URL . 'login');
    exit;
}

$user_id = $_SESSION['user_id'];
$username = $_SESSION['username'];

// Use prepared statements to prevent SQL Injection in search
$search = isset($_GET['search']) ? $_GET['search'] : '';
$posts = [];
if ($search) {
    $query = "SELECT * FROM posts WHERE title LIKE :search OR content LIKE :search ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindValue(':search', '%' . $search . '%');
    $stmt->execute();
    $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
} else {
    $query = "SELECT * FROM posts ORDER BY created_at DESC LIMIT 10";
    $posts = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Vulnerable Demo App</title>
    <link rel="stylesheet" href="<?php echo BASE_URL; ?>assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="<?php echo BASE_URL; ?>home">Home</a></li>
                <li><a href="<?php echo BASE_URL; ?>dashboard" aria-current="page">Dashboard</a></li>
                <li><a href="<?php echo BASE_URL; ?>profile">Profile</a></li>
                <li><a href="<?php echo BASE_URL; ?>upload">Upload</a></li>
                <li><a href="<?php echo BASE_URL; ?>logout">Logout (<?php echo htmlspecialchars($username, ENT_QUOTES, 'UTF-8'); ?>)</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section aria-labelledby="dashboard-heading">
            <h2 id="dashboard-heading">Dashboard</h2>
            
            <form method="GET" action="<?php echo BASE_URL; ?>dashboard" class="search-form" role="search">
                <label for="search">Search Posts:</label>
                <input type="text" id="search" name="search" 
                       value="<?php echo htmlspecialchars($search, ENT_QUOTES, 'UTF-8'); ?>" 
                       placeholder="Search...">
                <button type="submit">Search</button>
            </form>
            
            <div class="posts-container" role="list">
                <?php if (!empty($posts)): ?>
                    <?php foreach ($posts as $post): ?>
                        <article class="post" role="listitem">
                            <h3><?php echo htmlspecialchars($post['title'], ENT_QUOTES, 'UTF-8'); ?></h3>
                            <div class="post-content">
                                <?php echo htmlspecialchars($post['content'], ENT_QUOTES, 'UTF-8'); ?>
                            </div>
                            <p class="post-meta">
                                Posted on <?php echo $post['created_at']; ?>
                            </p>
                        </article>
                    <?php endforeach; ?>
                <?php else: ?>
                    <p>No posts found.</p>
                <?php endif; ?>
            </div>
            
            <section class="new-post" aria-labelledby="new-post-heading">
                <h3 id="new-post-heading">Create New Post</h3>
                <form method="POST" action="<?php echo BASE_URL; ?>post">
                    <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
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
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
    
    <!-- VULNERABILITY: Loading vulnerable JavaScript library -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" 
        integrity="sha384-1H217gwSVyLSIfaLxHbE7dRb3v4mYCKbpQvzx0cegeju1MVsGrX5xXxAvs/HgeFs" 
        crossorigin="anonymous"></script>
    <script src="assets/js/app.js"></script>
</body>
</html>
