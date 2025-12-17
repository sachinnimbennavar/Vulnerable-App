if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['file'])) {
    // CSRF token validation
    if (!isset($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die('CSRF token validation failed');
    }

    $target_dir = "uploads/";
    
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0755, true); // Use secure permissions
    }
    
    // --- BEGIN SECURE UPLOAD LOGIC ---

    // Whitelist allowed extensions
    $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf'];
    $file_extension = strtolower(pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION));

    if (!in_array($file_extension, $allowed_extensions)) {
        $error = "Upload failed: Invalid file type. Only JPG, PNG, GIF, and PDF are allowed.";
    }
    // Check file size (5MB max)
    elseif ($_FILES['file']['size'] > 5 * 1024 * 1024) {
        $error = "Upload failed: File is too large (Max 5MB).";
    } else {
        // Verify MIME type
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $_FILES['file']['tmp_name']);
        finfo_close($finfo);
        
        $allowed_mimes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];

        if (!in_array($mime, $allowed_mimes)) {
            $error = "Upload failed: Invalid MIME type detected.";
        } else {
            // Generate random, sanitized filename
            $new_filename = bin2hex(random_bytes(16)) . '.' . $file_extension;
            $target_file = $target_dir . $new_filename;

            // Move the file
            if (move_uploaded_file($_FILES['file']['tmp_name'], $target_file)) {
                chmod($target_file, 0644); // Set secure permissions
                $success = "File uploaded successfully: " . htmlspecialchars($new_filename);
            } else {
                $error = "Failed to move uploaded file.";
            }
        }
    }
    // --- END SECURE UPLOAD LOGIC ---
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload - Vulnerable Demo App</title>
    <link rel="stylesheet" href="<?php echo BASE_URL; ?>assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="<?php echo BASE_URL; ?>home">Home</a></li>
                <li><a href="<?php echo BASE_URL; ?>dashboard">Dashboard</a></li>
                <li><a href="<?php echo BASE_URL; ?>upload" aria-current="page">Upload</a></li>
                <li><a href="<?php echo BASE_URL; ?>logout">Logout</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section aria-labelledby="upload-heading">
            <h2 id="upload-heading">File Upload</h2>
            
            <?php if (isset($success)): ?>
                <div class="success" role="alert" aria-live="polite">
                    <?php echo $success; ?>
                </div>
            <?php endif; ?>
            
            <?php if (isset($error)): ?>
                <div class="error" role="alert" aria-live="polite">
                    <?php echo htmlspecialchars($error, ENT_QUOTES, 'UTF-8'); ?>
                </div>
            <?php endif; ?>
            
            <form method="POST" enctype="multipart/form-data" aria-labelledby="upload-heading">
                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                <div class="form-group">
                    <label for="file">Choose file:</label>
                    <input type="file" id="file" name="file" required aria-required="true">
                </div>
                <button type="submit" class="btn btn-primary">Upload</button>
            </form>
            
            <div class="upload-info">
                <h3>Uploaded Files</h3>
                <?php
                // VULNERABILITY: Directory traversal and information disclosure
                $files = scandir('uploads/');
                foreach ($files as $file) {
                    if ($file != '.' && $file != '..') {
                        // VULNERABILITY: Direct file access
                        echo "<p><a href='uploads/" . htmlspecialchars($file) . "'>" . htmlspecialchars($file) . "</a></p>";
                    }
                }
                ?>
            </div>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
</body>
</html>
