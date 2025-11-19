<?php
// VULNERABLE Post Handler
// Security Issue #13: XSS via stored content

session_start();
require_once '../config.php';

$db = getDBConnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : 0;
    $title = $_POST['title'];
    $content = $_POST['content'];
    
    // VULNERABILITY: SQL Injection and no input sanitization
    $query = "INSERT INTO posts (user_id, title, content) VALUES ($user_id, '$title', '$content')";
    
    try {
        $db->exec($query);
        header('Location: dashboard');
        exit;
    } catch (PDOException $e) {
        $error = "Failed to create post: " . $e->getMessage();
    }
}
?>
