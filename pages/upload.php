<?php
// VULNERABLE File Upload Handler
// Security Issue #14: Unrestricted file upload
// Security Issue #15: Path traversal

if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['file'])) {
    $target_dir = "uploads/";
    
    // VULNERABILITY: No directory existence check or creation with proper permissions
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0777, true);
    }
    
    // VULNERABILITY: No file type validation
    // VULNERABILITY: Using user-supplied filename directly
    $filename = $_FILES['file']['name'];
    $target_file = $target_dir . $filename;
    
    // VULNERABILITY: No file size limit
    // VULNERABILITY: Allows executable files
    if (move_uploaded_file($_FILES['file']['tmp_name'], $target_file)) {
        $success = "File uploaded successfully: " . $filename;
    } else {
        $error = "Failed to upload file";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload - Vulnerable Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="home">Home</a></li>
                <li><a href="dashboard">Dashboard</a></li>
                <li><a href="upload" aria-current="page">Upload</a></li>
                <li><a href="logout">Logout</a></li>
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
                    <?php echo $error; ?>
                </div>
            <?php endif; ?>
            
            <form method="POST" enctype="multipart/form-data" aria-labelledby="upload-heading">
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
                        echo "<p><a href='uploads/$file'>$file</a></p>";
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
