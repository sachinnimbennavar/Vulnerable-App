// VULNERABLE JavaScript Code
// Security Issue #18: Using outdated jQuery version (loaded from CDN in pages)

$(document).ready(function() {
    console.log('Vulnerable Demo App loaded');
    
    // VULNERABILITY: DOM-based XSS
    // Security Issue #19: Unsafe DOM manipulation
    var urlParams = new URLSearchParams(window.location.search);
    var message = urlParams.get('message');
    if (message) {
        // VULNERABLE: Directly inserting user input into DOM
        $('.message-container').html(message);
    }
    
    // VULNERABILITY: Eval usage
    // Security Issue #20: Using eval() with user input
    var customCode = urlParams.get('code');
    if (customCode) {
        try {
            eval(customCode); // DANGEROUS!
        } catch(e) {
            console.error('Error executing code:', e);
        }
    }
    
    // VULNERABILITY: Insecure cookie handling
    // Security Issue #21: Storing sensitive data in cookies without security flags
    function setCookie(name, value, days) {
        var expires = "";
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = "; expires=" + date.toUTCString();
        }
        // VULNERABLE: No Secure, HttpOnly, or SameSite flags
        document.cookie = name + "=" + (value || "") + expires + "; path=/";
    }
    
    // Store session token insecurely
    var sessionToken = urlParams.get('token');
    if (sessionToken) {
        setCookie('session_token', sessionToken, 7);
    }
    
    // VULNERABILITY: CORS misconfiguration simulation
    // Security Issue #22: Making requests without proper validation
    function makeAPICall(endpoint, data) {
        $.ajax({
            url: 'api/' + endpoint,
            method: 'POST',
            data: data,
            // VULNERABLE: No CSRF token
            success: function(response) {
                console.log('API Response:', response);
            },
            error: function(xhr, status, error) {
                // VULNERABILITY: Exposing error details
                console.error('API Error:', error, xhr.responseText);
            }
        });
    }
    
    // VULNERABILITY: Client-side validation only
    // Security Issue #23: Relying on client-side validation
    $('form').on('submit', function(e) {
        var username = $('#username').val();
        var password = $('#password').val();
        
        // Only client-side validation - easily bypassed
        if (username.length < 3) {
            alert('Username too short');
            e.preventDefault();
            return false;
        }
        
        // VULNERABLE: Checking password strength only on client side
        if (password.length < 6) {
            alert('Password too short');
            e.preventDefault();
            return false;
        }
    });
    
    // VULNERABILITY: Sensitive data in console
    // Security Issue #24: Logging sensitive information
    console.log('User session:', document.cookie);
    console.log('Current URL params:', window.location.search);
});

// VULNERABILITY: Global namespace pollution
// Security Issue #25: Exposing functions globally
function deleteUser(userId) {
    // VULNERABLE: No confirmation, no CSRF protection
    makeAPICall('delete-user', { id: userId });
}

function updateProfile(data) {
    // VULNERABLE: No input validation
    makeAPICall('update-profile', data);
}

// VULNERABILITY: Prototype pollution
// Security Issue #26: Unsafe object manipulation
function merge(target, source) {
    for (var key in source) {
        // VULNERABLE: No hasOwnProperty check
        target[key] = source[key];
    }
    return target;
}

// VULNERABILITY: localStorage usage without encryption
// Security Issue #27: Storing sensitive data in localStorage
function saveUserPreferences(prefs) {
    localStorage.setItem('userPrefs', JSON.stringify(prefs));
    localStorage.setItem('apiKey', prefs.apiKey); // DANGEROUS!
}

// VULNERABILITY: Insufficient input sanitization
// Security Issue #28: No HTML encoding
function displayMessage(msg) {
    $('#notification').html(msg); // XSS vulnerability
}
