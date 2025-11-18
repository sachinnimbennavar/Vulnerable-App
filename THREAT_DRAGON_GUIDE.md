# OWASP Threat Dragon User Guide

## Overview
This guide walks you through using OWASP Threat Dragon to analyze the vulnerable demo application, create threat models, and generate security reports.

## Prerequisites
- OWASP Threat Dragon installed on Windows VM
- Vulnerable Demo App running (accessible from your Windows VM)
- The `threat-model.json` file from this project

## Table of Contents
1. [Opening Threat Dragon](#opening-threat-dragon)
2. [Loading the Threat Model](#loading-the-threat-model)
3. [Understanding the Threat Model](#understanding-the-threat-model)
4. [Analyzing Threats](#analyzing-threats)
5. [Generating Reports](#generating-reports)
6. [Creating Your Own Threat Model](#creating-your-own-threat-model)

---

## Opening Threat Dragon

### Method 1: Desktop Application (Recommended)

1. **Launch Threat Dragon**
   - Navigate to Start Menu → OWASP Threat Dragon
   - Or locate the installation directory (usually `C:\Program Files\OWASP Threat Dragon\`)
   - Double-click `OWASP-Threat-Dragon.exe`

2. **Verify Installation**
   - The application should open with the welcome screen
   - You'll see options to create a new threat model or open an existing one

### Method 2: Web Version

1. **Access Online Version**
   - Open browser and go to: https://www.threatdragon.com
   - Click "Try It Now" or "Web App"

2. **Note**: Web version has limited features compared to desktop

---

## Loading the Threat Model

### Step 1: Transfer the Threat Model File

**Option A: Using Shared Folder (Recommended)**
```bash
# From macOS (where the code is)
# Copy threat-model.json to a shared folder accessible by Windows VM
cp threat-model.json /path/to/shared/folder/

# From Windows VM, access the shared folder
# Usually: \\MACBOOKNAME\SharedFolder\threat-model.json
```

**Option B: Using Network Transfer**
```bash
# From macOS - Start a simple HTTP server
cd /Users/santhosh/Mukana/SSDLC/Demo-Code
python3 -m http.server 8000

# From Windows VM browser:
# Navigate to: http://<MAC_IP_ADDRESS>:8000
# Download threat-model.json
```

**Option C: Using Git/Cloud**
```bash
# Commit to Git repository
git add threat-model.json
git commit -m "Add threat model"
git push

# From Windows VM, pull the repository
git pull
```

### Step 2: Open the Threat Model in Threat Dragon

1. **Launch OWASP Threat Dragon**

2. **Open Existing Model**
   - Click **"Open an existing model"**
   - Or go to: **File → Open**

3. **Select the File**
   - Navigate to where you saved `threat-model.json`
   - Select the file and click **"Open"**

4. **Verify Loading**
   - You should see the threat model load with:
     - Project name: "Vulnerable Demo Application - Threat Model"
     - Diagram: "Application Architecture"

---

## Understanding the Threat Model

### Architecture Overview

The threat model shows 4 main components:

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│ Web Browser │────────▶│ Apache/PHP   │────────▶│  SQLite DB  │
│   (User)    │         │  Web Server  │         │             │
└─────────────┘         └──────┬───────┘         └─────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ File System  │
                        │  (Uploads)   │
                        └──────────────┘
```

### Components Explained

1. **Web Browser (Actor)**
   - Represents the end user
   - Entry point for attacks
   - Threats: Malicious input, session hijacking

2. **Apache Web Server (Process)**
   - Main application logic
   - Most vulnerable component
   - Threats: SQL injection, XSS, file upload, authentication bypass

3. **SQLite Database (Data Store)**
   - Stores user data and application data
   - Threats: Data exposure, SQL injection, plain text passwords

4. **File System (Data Store)**
   - Upload directory
   - Threats: Path traversal, malicious file execution

### STRIDE Analysis

The model uses **STRIDE** threat modeling:

- **S**poofing - Impersonating users/systems
- **T**ampering - Modifying data/code
- **R**epudiation - Denying actions
- **I**nformation Disclosure - Exposing sensitive data
- **D**enial of Service - Making system unavailable
- **E**levation of Privilege - Gaining unauthorized access

---

## Analyzing Threats

### Viewing Threats

1. **Navigate the Diagram**
   - Click on any component (Web Browser, Web Server, Database, File System)
   - Right panel shows details

2. **View Threat Details**
   - Click on a component with threats (has warning icon)
   - Click **"Edit"** or double-click the component
   - Scroll to **"Threats"** section

### Critical Threats Identified

#### Threat #1: SQL Injection
- **Component**: Apache Web Server
- **Type**: Tampering
- **Severity**: Critical
- **Description**: Application vulnerable to SQL injection in login, search, and post creation
- **Mitigation**: Use prepared statements and parameterized queries
- **Status**: Open

#### Threat #2: Cross-Site Scripting (XSS)
- **Component**: Apache Web Server
- **Type**: Information Disclosure
- **Severity**: High
- **Description**: Stored and reflected XSS in posts and search
- **Mitigation**: Implement proper output encoding and CSP
- **Status**: Open

#### Threat #3: Missing Authentication
- **Component**: Apache Web Server
- **Type**: Elevation of Privilege
- **Severity**: Critical
- **Description**: Weak or missing authentication on sensitive pages
- **Mitigation**: Implement proper session management and auth checks
- **Status**: Open

#### Threat #4: Hardcoded Credentials
- **Component**: Apache Web Server
- **Type**: Information Disclosure
- **Severity**: Critical
- **Description**: Database credentials and API keys in source code
- **Mitigation**: Use environment variables and secure storage
- **Status**: Open

#### Threat #5: Unrestricted File Upload
- **Component**: Apache Web Server
- **Type**: Tampering
- **Severity**: Critical
- **Description**: No validation on file uploads
- **Mitigation**: Implement file type validation and virus scanning
- **Status**: Open

### Analyzing Each Threat

For each threat, review:

1. **Threat Title** - What is the threat?
2. **Status** - Is it open, mitigated, or N/A?
3. **Severity** - Critical, High, Medium, Low
4. **Type** - Which STRIDE category?
5. **Description** - Detailed explanation
6. **Mitigation** - How to fix it
7. **Score** - Risk score (if calculated)

---

## Generating Reports

### Method 1: HTML Report (Desktop App)

1. **Generate Report**
   - Go to: **Report → Generate Report**
   - Or press: **Ctrl + R**

2. **Select Report Type**
   - Choose: **HTML Report**
   - Click **"Generate"**

3. **Save Report**
   - Choose save location (e.g., `C:\Users\YourName\Desktop\threat-report.html`)
   - Click **"Save"**

4. **Open Report**
   - Navigate to saved location
   - Double-click the HTML file to open in browser

### Method 2: PDF Report

1. **Generate HTML First**
   - Follow Method 1 to create HTML report

2. **Convert to PDF**
   - Open HTML report in browser
   - Press **Ctrl + P** (Print)
   - Select **"Save as PDF"** as destination
   - Click **"Save"**

3. **Alternative: Use Print to PDF**
   - In Threat Dragon: **File → Print**
   - Select PDF printer
   - Save as desired

### Method 3: JSON Export

1. **Export Model**
   - Go to: **File → Save As**
   - Choose location
   - Save as: `threat-model-report.json`

2. **Use for Integration**
   - Can be imported into other tools
   - Can be versioned in Git
   - Can be parsed programmatically

### Method 4: Screenshot/Image Export

1. **Capture Diagram**
   - Click on the diagram
   - Go to: **File → Export Diagram**
   - Or use Windows Snipping Tool: **Win + Shift + S**

2. **Save Image**
   - Choose format: PNG, JPG, SVG
   - Include in reports or presentations

---

## Report Contents

### Standard Report Includes:

1. **Executive Summary**
   - Project overview
   - Total number of threats
   - Severity breakdown

2. **Architecture Diagram**
   - Visual representation of system
   - Components and data flows
   - Trust boundaries

3. **Threat Details**
   - Each threat listed with:
     - ID and Title
     - Severity and Type
     - Description
     - Mitigation recommendations
     - Current status

4. **STRIDE Analysis**
   - Threats categorized by STRIDE type
   - Count per category

5. **Recommendations**
   - Priority fixes
   - Security improvements

---

## Creating Your Own Threat Model

### Step 1: Create New Model

1. **Start New**
   - Click **"Create a new model"**
   - Or: **File → New**

2. **Enter Project Details**
   - **Title**: "My Vulnerable App Analysis"
   - **Owner**: Your name
   - **Description**: Brief description
   - Click **"Create"**

### Step 2: Create Diagram

1. **Add New Diagram**
   - Click **"+ Add Diagram"**
   - **Title**: "System Architecture"
   - **Type**: Choose **"STRIDE"**
   - Click **"Add"**

2. **Open Diagram Editor**
   - Click on the diagram you just created
   - Enter diagram editing mode

### Step 3: Add Components

1. **Add Actor (User)**
   - Click **"Actor"** icon in toolbar
   - Click on canvas to place
   - Double-click to edit properties
   - **Name**: "End User"
   - **Description**: "Application user accessing via browser"

2. **Add Process (Server)**
   - Click **"Process"** icon
   - Place on canvas
   - **Name**: "Web Application"
   - **Description**: "Apache/PHP application server"

3. **Add Data Store (Database)**
   - Click **"Store"** icon
   - Place on canvas
   - **Name**: "Database"
   - **Description**: "SQLite database"

4. **Add Data Flow**
   - Click **"Flow"** icon
   - Click on Actor, drag to Process
   - **Name**: "HTTP Request"
   - **Description**: "User requests"

### Step 4: Add Threats

1. **Select Component**
   - Click on the component (e.g., Web Application)
   - Click **"Edit"** in right panel

2. **Add Threat**
   - Scroll to **"Threats"** section
   - Click **"+ Add Threat"**

3. **Fill Threat Details**
   - **Title**: "SQL Injection in Login"
   - **Status**: "Open"
   - **Severity**: "High"
   - **Type**: "Tampering"
   - **Description**: "Login form vulnerable to SQL injection..."
   - **Mitigation**: "Use prepared statements..."

4. **Save Threat**
   - Click **"Save"** or **"OK"**

### Step 5: Review and Refine

1. **Review All Components**
   - Ensure all have threats identified
   - Check severity ratings
   - Verify mitigations

2. **Add Missing Elements**
   - Trust boundaries
   - Additional data flows
   - External systems

3. **Save Model**
   - **File → Save**
   - Save as: `my-threat-model.json`

---

## Best Practices

### 1. Regular Updates
- Update threat model when code changes
- Review quarterly or after major releases
- Track mitigation progress

### 2. Collaborative Review
- Share with security team
- Get developer input
- Review with stakeholders

### 3. Integration with SDLC
- Create threat model in design phase
- Update during development
- Verify mitigations during testing

### 4. Documentation
- Export reports regularly
- Version control threat models
- Link to tickets/issues

### 5. Prioritization
- Focus on Critical and High severity first
- Consider exploit likelihood
- Assess business impact

---

## Comparison with Security Scan Results

### Cross-Reference with Other Tools

After generating Threat Dragon report, compare with:

1. **OWASP ZAP Results**
   - ZAP confirms SQL injection (Threat #2)
   - XSS validated (Threat #3)
   - Missing headers detected

2. **SonarQube Results**
   - Hardcoded credentials confirmed (Threat #5)
   - Code quality issues align with threats

3. **Dependency-Check Results**
   - Vulnerable dependencies (Threat #19)
   - jQuery CVEs match threat model

### Create Consolidated Report

Combine findings from all tools:

```
THREAT ID | Threat Dragon | ZAP | SonarQube | Dep-Check | Status
----------|---------------|-----|-----------|-----------|--------
TH-001    | SQL Injection | ✓   | ✓         | -         | Open
TH-002    | XSS           | ✓   | ✓         | -         | Open
TH-003    | Missing Auth  | ✓   | ✓         | -         | Open
TH-004    | Hard Creds    | -   | ✓         | -         | Open
TH-005    | File Upload   | ✓   | ✓         | -         | Open
```

---

## Troubleshooting

### Issue 1: Cannot Open JSON File

**Error**: "Invalid threat model file"

**Solution**:
1. Verify file is valid JSON
2. Check file encoding (should be UTF-8)
3. Validate JSON syntax: https://jsonlint.com
4. Ensure file extension is `.json`

### Issue 2: Diagram Not Displaying

**Solution**:
1. Check if diagram was created
2. Click on diagram name in left panel
3. Refresh application
4. Check browser console for errors (web version)

### Issue 3: Cannot Generate Report

**Solution**:
1. Ensure model is saved
2. Check write permissions to output folder
3. Try different output location
4. Update Threat Dragon to latest version

### Issue 4: Missing Threats

**Solution**:
1. Click on component
2. Check "Threats" section
3. Ensure model loaded completely
4. Re-import threat-model.json

---

## Advanced Features

### 1. Custom Threat Templates

Create reusable threat patterns:
- Common web vulnerabilities
- API security threats
- Mobile app threats

### 2. STRIDE Per Element

Automatically generate threats based on:
- Component type
- Data flow sensitivity
- Trust boundaries

### 3. Integration with GitHub

- Store models in repository
- Version control
- Collaborative editing
- CI/CD integration

### 4. Custom Severity Scoring

Define your own risk matrix:
- Impact vs. Likelihood
- CVSS scoring
- Business risk factors

---

## Sample Report Structure

When presenting findings, use this structure:

### Executive Summary
```
Project: Vulnerable Demo Application
Date: November 11, 2025
Analyst: [Your Name]

Total Threats Identified: 13
- Critical: 5
- High: 6
- Medium: 2
- Low: 0

Status:
- Open: 13
- Mitigated: 0
- Not Applicable: 0
```

### Key Findings

**1. Critical Vulnerabilities Require Immediate Action**
- SQL Injection across multiple endpoints
- Hardcoded credentials in source code
- Missing authentication on sensitive pages

**2. Recommendations**
- Implement prepared statements for all database queries
- Move credentials to environment variables
- Add authentication middleware
- Enable CSRF protection
- Validate and sanitize file uploads

### Next Steps

1. Prioritize critical threats
2. Create remediation plan
3. Assign to development team
4. Re-scan after fixes
5. Update threat model

---

## Resources

### OWASP Threat Dragon Links
- Official Website: https://owasp.org/www-project-threat-dragon/
- Documentation: https://docs.threatdragon.org/
- GitHub: https://github.com/OWASP/threat-dragon
- Tutorial Videos: https://www.youtube.com/OWASP

### Threat Modeling Resources
- OWASP Threat Modeling: https://owasp.org/www-community/Threat_Modeling
- STRIDE Framework: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
- Threat Modeling Manifesto: https://www.threatmodelingmanifesto.org/

### Related Tools
- Microsoft Threat Modeling Tool
- IriusRisk
- ThreatModeler
- CAIRIS

---

## Quick Reference Commands

### Keyboard Shortcuts (Desktop App)

| Action | Shortcut |
|--------|----------|
| New Model | Ctrl + N |
| Open Model | Ctrl + O |
| Save Model | Ctrl + S |
| Generate Report | Ctrl + R |
| Add Diagram | Ctrl + D |
| Undo | Ctrl + Z |
| Redo | Ctrl + Y |
| Zoom In | Ctrl + Plus |
| Zoom Out | Ctrl + Minus |
| Fit to Screen | Ctrl + 0 |

---

## Conclusion

OWASP Threat Dragon helps you:
✅ Visualize system architecture  
✅ Identify security threats systematically  
✅ Apply STRIDE framework  
✅ Generate professional reports  
✅ Track mitigation progress  
✅ Integrate with SDLC  

For questions or issues, refer to the official documentation or OWASP community forums.

---

**Next Steps**: After completing threat modeling, proceed to run OWASP ZAP, SonarQube, and Dependency-Check to validate the threats identified in this model.
