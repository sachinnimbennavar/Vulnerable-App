<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - Vulnerable Demo App</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
            <h1>Vulnerable Demo Application</h1>
            <ul>
                <li><a href="home" aria-current="page">Home</a></li>
                <li><a href="login">Login</a></li>
                <li><a href="register">Register</a></li>
            </ul>
        </nav>
    </header>
    
    <main role="main" id="main-content">
        <section class="hero" aria-labelledby="hero-heading">
            <h2 id="hero-heading">Welcome to the Vulnerable Demo Application</h2>
            <p class="lead">
                This application is intentionally vulnerable for Security Development Lifecycle (SSDLC) demonstration purposes.
            </p>
            
            <div class="features" role="list">
                <article class="feature" role="listitem">
                    <h3>Accessible UI</h3>
                    <p>Built with ARIA labels and semantic HTML for screen reader compatibility.</p>
                </article>
                
                <article class="feature" role="listitem">
                    <h3>Security Testing</h3>
                    <p>Contains intentional vulnerabilities detectable by OWASP tools.</p>
                </article>
                
                <article class="feature" role="listitem">
                    <h3>Learning Platform</h3>
                    <p>Perfect for learning about security scanning and remediation.</p>
                </article>
            </div>
            
            <div class="cta">
                <a href="login" class="btn btn-primary">Get Started</a>
                <a href="register" class="btn btn-secondary">Create Account</a>
            </div>
        </section>
        
        <section class="warning" role="alert">
            <h3>⚠️ Security Notice</h3>
            <p><strong>WARNING:</strong> This application contains intentional security vulnerabilities. 
               Do NOT deploy in production. For educational purposes only.</p>
        </section>
    </main>
    
    <footer role="contentinfo">
        <p>&copy; 2025 Vulnerable Demo App - For Security Testing Only</p>
    </footer>
</body>
</html>
