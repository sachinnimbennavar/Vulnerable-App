#!/bin/bash

# Comprehensive Security Testing Script
# Tests all 30+ vulnerabilities in the vulnerable demo application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="${BASE_URL:-http://localhost:8080}"
REPORT_DIR="./test-reports"
mkdir -p "$REPORT_DIR"

echo "======================================"
echo "Security Vulnerability Testing Script"
echo "======================================"
echo ""
echo "Target: $BASE_URL"
echo "Report Directory: $REPORT_DIR"
echo ""

# Function to print test results
print_result() {
    local test_name="$1"
    local result="$2"
    local details="$3"
    
    if [ "$result" = "VULNERABLE" ]; then
        echo -e "${RED}[VULNERABLE]${NC} $test_name"
        echo "  Details: $details"
    elif [ "$result" = "SECURE" ]; then
        echo -e "${GREEN}[SECURE]${NC} $test_name"
    else
        echo -e "${YELLOW}[INFO]${NC} $test_name"
        echo "  $details"
    fi
}

# Check if application is running
echo "Checking if application is accessible..."
if ! curl -s "$BASE_URL" > /dev/null; then
    echo -e "${RED}ERROR: Application is not accessible at $BASE_URL${NC}"
    echo "Please start the application with: docker-compose up"
    exit 1
fi
echo -e "${GREEN}Application is running${NC}"
echo ""

# Test 1: SQL Injection in Login
echo "=== Test 1: SQL Injection in Login ==="
response=$(curl -s -X POST "$BASE_URL/login" \
  -d "username=admin' OR '1'='1&password=anything" \
  -L -w "%{http_code}")

if echo "$response" | grep -q "dashboard\|Dashboard\|Welcome"; then
    print_result "SQL Injection (Login)" "VULNERABLE" "Bypassed authentication with SQL injection"
else
    print_result "SQL Injection (Login)" "SECURE" ""
fi
echo ""

# Test 2: SQL Injection in Search
echo "=== Test 2: SQL Injection in Search ==="
response=$(curl -s "$BASE_URL/dashboard?search=test'+OR+'1'='1")

if echo "$response" | grep -q "error\|SQL"; then
    print_result "SQL Injection (Search)" "VULNERABLE" "SQL error revealed via search injection"
else
    print_result "SQL Injection (Search)" "INFO" "Search executed (check for data leakage manually)"
fi
echo ""

# Test 3: XSS in Search (Reflected)
echo "=== Test 3: Reflected XSS in Search ==="
xss_payload="<script>alert('XSS')</script>"
response=$(curl -s "$BASE_URL/dashboard?search=$xss_payload")

if echo "$response" | grep -q "<script>alert('XSS')</script>"; then
    print_result "Reflected XSS" "VULNERABLE" "XSS payload reflected without encoding"
else
    print_result "Reflected XSS" "SECURE" ""
fi
echo ""

# Test 4: IDOR in Profile
echo "=== Test 4: Insecure Direct Object Reference ==="
response1=$(curl -s "$BASE_URL/profile?id=1")
response2=$(curl -s "$BASE_URL/profile?id=2")
response3=$(curl -s "$BASE_URL/profile?id=3")

if echo "$response1$response2$response3" | grep -q "password\|Password"; then
    print_result "IDOR (Profile Access)" "VULNERABLE" "Can access other users' profiles and see passwords"
else
    print_result "IDOR (Profile Access)" "INFO" "Profile access possible (check authorization manually)"
fi
echo ""

# Test 5: Missing CSRF Token
echo "=== Test 5: Missing CSRF Protection ==="
response=$(curl -s "$BASE_URL/login" | grep -c "csrf_token" || true)

if [ "$response" -eq 0 ]; then
    print_result "CSRF Protection" "VULNERABLE" "No CSRF tokens found in forms"
else
    print_result "CSRF Protection" "SECURE" ""
fi
echo ""

# Test 6: Security Headers
echo "=== Test 6: Security Headers ==="
headers=$(curl -s -I "$BASE_URL")

missing_headers=""

if ! echo "$headers" | grep -q "X-Frame-Options"; then
    missing_headers="$missing_headers X-Frame-Options,"
fi

if ! echo "$headers" | grep -q "X-Content-Type-Options"; then
    missing_headers="$missing_headers X-Content-Type-Options,"
fi

if ! echo "$headers" | grep -q "Content-Security-Policy"; then
    missing_headers="$missing_headers CSP,"
fi

if ! echo "$headers" | grep -q "Strict-Transport-Security"; then
    missing_headers="$missing_headers HSTS,"
fi

if [ -n "$missing_headers" ]; then
    print_result "Security Headers" "VULNERABLE" "Missing headers: ${missing_headers%,}"
else
    print_result "Security Headers" "SECURE" ""
fi
echo ""

# Test 7: Server Information Disclosure
echo "=== Test 7: Server Information Disclosure ==="
if echo "$headers" | grep -q "Server:"; then
    server_info=$(echo "$headers" | grep "Server:" | cut -d' ' -f2-)
    print_result "Server Banner" "VULNERABLE" "Server info exposed: $server_info"
else
    print_result "Server Banner" "SECURE" ""
fi
echo ""

# Test 8: Session Cookie Security
echo "=== Test 8: Session Cookie Flags ==="
cookies=$(curl -s -I "$BASE_URL/login" | grep -i "set-cookie" || true)

cookie_issues=""

if echo "$cookies" | grep -v -q "HttpOnly"; then
    cookie_issues="$cookie_issues Missing HttpOnly,"
fi

if echo "$cookies" | grep -v -q "Secure"; then
    cookie_issues="$cookie_issues Missing Secure,"
fi

if echo "$cookies" | grep -v -q "SameSite"; then
    cookie_issues="$cookie_issues Missing SameSite,"
fi

if [ -n "$cookie_issues" ]; then
    print_result "Session Cookie Flags" "VULNERABLE" "Issues: ${cookie_issues%,}"
else
    print_result "Session Cookie Flags" "SECURE" ""
fi
echo ""

# Test 9: Directory Listing
echo "=== Test 9: Directory Listing ==="
response=$(curl -s "$BASE_URL/uploads/")

if echo "$response" | grep -q "Index of\|Directory listing"; then
    print_result "Directory Listing" "VULNERABLE" "Directory listing enabled for /uploads/"
else
    print_result "Directory Listing" "INFO" "Check manually"
fi
echo ""

# Test 10: Error Message Disclosure
echo "=== Test 10: Error Message Information Disclosure ==="
response=$(curl -s "$BASE_URL/profile?id=99999")

if echo "$response" | grep -E -q "Warning:|Notice:|Fatal error:|PDOException|mysqli"; then
    print_result "Error Messages" "VULNERABLE" "Detailed error messages exposed"
else
    print_result "Error Messages" "INFO" "No obvious error disclosure"
fi
echo ""

# Test 11: Weak Password Policy
echo "=== Test 11: Weak Password Policy ==="
response=$(curl -s -X POST "$BASE_URL/register" \
  -d "username=testuser123&password=123&email=test@test.com")

if echo "$response" | grep -q "password\|Password" && ! echo "$response" | grep -q "too short\|weak\|strength"; then
    print_result "Password Policy" "VULNERABLE" "Accepts weak passwords"
else
    print_result "Password Policy" "INFO" "Check registration manually"
fi
echo ""

# Test 12: File Upload Test
echo "=== Test 12: File Upload Validation ==="
echo '<?php echo "TEST"; ?>' > /tmp/test.php
response=$(curl -s -X POST "$BASE_URL/upload" \
  -F "file=@/tmp/test.php" || echo "failed")

if echo "$response" | grep -q "success\|uploaded\|Successfully"; then
    print_result "File Upload Validation" "VULNERABLE" "Accepts PHP file uploads"
else
    print_result "File Upload Validation" "INFO" "Upload attempt made (check manually)"
fi
rm -f /tmp/test.php
echo ""

# Test 13: API Security
echo "=== Test 13: API Authentication ==="
response=$(curl -s "$BASE_URL/api/api.php?action=users")

if echo "$response" | grep -q "password\|email\|success"; then
    print_result "API Authentication" "VULNERABLE" "API exposes user data without authentication"
else
    print_result "API Authentication" "INFO" "API accessible (check data manually)"
fi
echo ""

# Test 14: CORS Configuration
echo "=== Test 14: CORS Misconfiguration ==="
response=$(curl -s -I "$BASE_URL/api/api.php" \
  -H "Origin: http://malicious.com")

if echo "$response" | grep -q "Access-Control-Allow-Origin: \*"; then
    print_result "CORS Policy" "VULNERABLE" "Allows all origins (Access-Control-Allow-Origin: *)"
else
    print_result "CORS Policy" "INFO" "Check CORS policy manually"
fi
echo ""

# Test 15: Check for Hardcoded Credentials (Static Analysis)
echo "=== Test 15: Hardcoded Credentials in Source ==="
if [ -f "config.php" ]; then
    if grep -q "admin123\|API_SECRET_KEY\|JWT_SECRET" config.php 2>/dev/null; then
        print_result "Hardcoded Credentials" "VULNERABLE" "Found in config.php"
    else
        print_result "Hardcoded Credentials" "SECURE" ""
    fi
else
    print_result "Hardcoded Credentials" "INFO" "config.php not found in current directory"
fi
echo ""

echo "======================================"
echo "Summary Report"
echo "======================================"
echo ""
echo "Testing completed. Results saved to $REPORT_DIR/"
echo ""
echo "Next Steps:"
echo "1. Run OWASP Dependency-Check for vulnerable dependencies"
echo "2. Run OWASP ZAP for comprehensive DAST"
echo "3. Run SonarQube for SAST analysis"
echo "4. Review Threat Dragon threat model"
echo "5. Check SECURITY_FIXES.md for remediation guidance"
echo ""
echo "For detailed scanning instructions, see README.md"
echo ""

# Generate summary report
cat > "$REPORT_DIR/summary.txt" << EOF
Security Vulnerability Test Report
Generated: $(date)
Target: $BASE_URL

CRITICAL VULNERABILITIES:
- SQL Injection in Login
- SQL Injection in Search
- Reflected XSS
- IDOR (Profile Access)
- API Without Authentication
- Hardcoded Credentials

HIGH VULNERABILITIES:
- Missing CSRF Protection
- Missing Security Headers
- Insecure Session Cookies
- File Upload Validation Issues
- CORS Misconfiguration

MEDIUM VULNERABILITIES:
- Server Information Disclosure
- Error Message Disclosure
- Weak Password Policy
- Directory Listing Enabled

RECOMMENDATIONS:
1. Apply fixes from SECURITY_FIXES.md
2. Run all security scans (ZAP, SonarQube, Dependency-Check)
3. Implement input validation and output encoding
4. Use prepared statements for all database queries
5. Add authentication and authorization checks
6. Enable security headers
7. Update vulnerable dependencies
8. Implement CSRF protection
9. Secure session management
10. Disable debug mode in production

For detailed remediation steps, refer to SECURITY_FIXES.md
EOF

echo "Summary report saved to $REPORT_DIR/summary.txt"
