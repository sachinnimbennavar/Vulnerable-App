<?php
// VULNERABLE API Endpoint
// Security Issue #29: No rate limiting
// Security Issue #30: No authentication on API

header('Content-Type: application/json');

// VULNERABILITY: CORS misconfiguration
// Security Issue #31: Allowing all origins
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: *');

require_once '../config.php';
$db = getDBConnection();

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch($action) {
    case 'users':
        // VULNERABILITY: Exposing all user data without authentication
        $users = $db->query("SELECT * FROM users")->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'data' => $users]);
        break;
        
    case 'login':
        // VULNERABILITY: No rate limiting, SQL injection
        $username = $_POST['username'];
        $password = $_POST['password'];
        
        $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
        $user = $db->query($query)->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            // VULNERABILITY: Exposing sensitive data in API response
            echo json_encode(['success' => true, 'user' => $user]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
        }
        break;
        
    case 'delete-user':
        // VULNERABILITY: No authentication or authorization
        $id = $_POST['id'];
        $db->exec("DELETE FROM users WHERE id = $id");
        echo json_encode(['success' => true]);
        break;
        
    case 'update-profile':
        // VULNERABILITY: Mass assignment vulnerability
        $data = $_POST;
        $fields = [];
        foreach ($data as $key => $value) {
            $fields[] = "$key = '$value'";
        }
        $query = "UPDATE users SET " . implode(', ', $fields) . " WHERE id = " . $_POST['id'];
        $db->exec($query);
        echo json_encode(['success' => true]);
        break;
        
    default:
        // VULNERABILITY: Information disclosure
        echo json_encode([
            'success' => false, 
            'message' => 'Unknown action',
            'available_actions' => ['users', 'login', 'delete-user', 'update-profile'],
            'server_info' => $_SERVER
        ]);
}
?>
