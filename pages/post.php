<?php
// SECURE Post Handler

$db = getDBConnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // CSRF token validation
    if (!isset($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die('CSRF token validation failed');
    }
    
    // Ensure user is logged in
    if (!isset($_SESSION['user_id'])) {
        header('Location: ' . BASE_URL . 'login');
        exit;
    }

    $user_id = $_SESSION['user_id'];
    $title = $_POST['title'];
    $content = $_POST['content'];
    
    // Use prepared statements to prevent SQL Injection
    $query = "INSERT INTO posts (user_id, title, content) VALUES (:user_id, :title, :content)";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->bindParam(':title', $title, PDO::PARAM_STR);
        $stmt->bindParam(':content', $content, PDO::PARAM_STR);
        $stmt->execute();
        
        header('Location: ' . BASE_URL . 'dashboard');
        exit;
    } catch (PDOException $e) {
        // In a real app, log this error and show a generic message
        $error = "Failed to create post: " . $e->getMessage();
    }
} else {
    // Redirect if accessed directly via GET
    header('Location: ' . BASE_URL . 'dashboard');
    exit;
}
?>
