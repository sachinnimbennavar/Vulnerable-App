# Nexus Repository Setup (Optional)

## Quick Setup Guide for Nexus OSS

This guide helps you set up Nexus for artifact management with the CI/CD pipeline.

### Prerequisites
- Docker or local Nexus installation
- Network access to Nexus instance

---

## Option 1: Docker Setup (Recommended)

### Start Nexus Container
```bash
docker run -d \
  -p 8081:8081 \
  --name nexus3 \
  -v nexus-data:/nexus-data \
  sonatype/nexus3:latest
```

### Access Nexus
1. Open browser: `http://localhost:8081`
2. Initial login: `admin` / `admin123`
3. Reset password when prompted

### Wait for Startup
- Nexus takes 2-3 minutes to fully start
- Check status: `docker logs nexus3`

---

## Step 1: Create Maven2 Hosted Repository

### Via Web UI
1. Login to Nexus
2. Go to **Administration → Repositories**
3. Click **Create repository**
4. Select **maven2 (hosted)**
5. Configure:
   - **Name**: `maven2-hosted`
   - **Repository realms**: Keep default
   - **Version policy**: `Mixed`
   - **Layout policy**: `Permissive`
6. Click **Create repository**

### Repository Details
```
Repository Name: maven2-hosted
Type: Hosted
URL: http://localhost:8081/repository/maven2-hosted
```

---

## Step 2: Create Deployment User

### Create User Account
1. Go to **Administration → Users**
2. Click **Create user**
3. Fill in:
   - **ID**: `deployment-user`
   - **First Name**: `Deployment`
   - **Email**: `deploy@example.com`
   - **Password**: `YourSecurePassword123!`
   - **Status**: Active
4. Click **Create user**

### Assign Repository Privileges
1. Go to **Administration → Security → Roles**
2. Create a new role: `deployment-role`
3. Add privileges:
   - `nx-repository-admin-maven2-maven2-hosted-add`
   - `nx-repository-admin-maven2-maven2-hosted-edit`
   - `nx-repository-admin-maven2-maven2-hosted-read`
4. Assign role to `deployment-user`

---

## Step 3: Configure GitHub Secrets

### Add to GitHub Repository

1. Go to **Repository Settings → Secrets and variables → Actions**

2. Add these secrets:

```
Name: NEXUS_URL
Value: http://your-nexus-domain:8081
(or http://localhost:8081 if testing locally)

Name: NEXUS_USERNAME
Value: deployment-user

Name: NEXUS_PASSWORD
Value: YourSecurePassword123!
```

---

## Step 4: Test Upload

### Manual Test with curl
```bash
# Upload file to Nexus
curl -v --upload-file vulnerable-app-123.zip \
  -u deployment-user:YourSecurePassword123! \
  http://localhost:8081/repository/maven2-hosted/vulnerable-app/123/vulnerable-app-123.zip

# Response should be 201 Created
```

### Using PowerShell
```powershell
$zipFile = "vulnerable-app-123.zip"
$nexusUrl = "http://localhost:8081/repository/maven2-hosted/vulnerable-app/123/vulnerable-app-123.zip"
$username = "deployment-user"
$password = "YourSecurePassword123!"
$base64Creds = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$username:$password"))

$headers = @{
    "Authorization" = "Basic $base64Creds"
    "Content-Type" = "application/zip"
}

Invoke-WebRequest -Uri $nexusUrl -Method PUT -InFile $zipFile -Headers $headers
```

---

## Step 5: Download Artifact

### Using Browser
1. Navigate to Nexus UI
2. Browse → `maven2-hosted`
3. Find your artifact
4. Click to download

### Using curl
```bash
curl -u deployment-user:YourSecurePassword123! \
  -O http://localhost:8081/repository/maven2-hosted/vulnerable-app/123/vulnerable-app-123.zip
```

### Using PowerShell
```powershell
$url = "http://localhost:8081/repository/maven2-hosted/vulnerable-app/123/vulnerable-app-123.zip"
$output = "vulnerable-app-123.zip"
$username = "deployment-user"
$password = "YourSecurePassword123!"

$base64Creds = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$username:$password"))
$headers = @{ "Authorization" = "Basic $base64Creds" }

Invoke-WebRequest -Uri $url -OutFile $output -Headers $headers
```

---

## Cleanup & Maintenance

### View Artifacts in Nexus
1. Login to Nexus
2. Go to **Browse → Repositories → maven2-hosted**
3. Navigate through directory structure

### Delete Old Artifacts
1. Select artifact
2. Click **Delete** button
3. Confirm deletion

### Disk Space Management
1. Go to **Administration → Maintenance → Tasks**
2. Create task: **Delete components**
3. Set **Cleanup Policy** for old artifacts
4. Configure retention: e.g., keep last 5 builds

---

## Troubleshooting Nexus

### Nexus Container Won't Start
```bash
# Check logs
docker logs nexus3

# Increase memory if needed
docker run -d \
  -p 8081:8081 \
  -e INSTALL4J_ADD_VM_PARAMS="-Xms1200M -Xmx1200M" \
  --name nexus3 \
  sonatype/nexus3:latest
```

### Upload Fails with 401 Unauthorized
- Verify credentials in GitHub Secrets
- Check user permissions in Nexus
- Ensure user is assigned to deployment role

### Upload Fails with 403 Forbidden
- User doesn't have write permissions
- Assign correct repository privileges
- Check repository realm settings

### Can't Access Nexus URL
- Verify Nexus is running: `docker ps`
- Check firewall rules
- Verify port forwarding if behind NAT

---

## Integration with Pipeline

The CI/CD pipeline will automatically:

1. **Build** the application
2. **Create ZIP** artifact
3. **Upload to Nexus** on each push
4. **Store credentials** securely in GitHub Secrets
5. **Fail gracefully** if Nexus is unavailable

---

## Best Practices

✅ **Use Strong Passwords** - 12+ characters, mixed case, numbers, symbols
✅ **Limit User Permissions** - Only grant repository access needed
✅ **Rotate Credentials** - Update passwords regularly
✅ **Enable SSL/TLS** - Use HTTPS in production
✅ **Backup Nexus Data** - Regular backups of nexus-data volume
✅ **Monitor Disk Space** - Set cleanup policies for old artifacts
✅ **Use Separate Users** - Different accounts for different purposes

---

## Additional Resources

- **Nexus OSS Documentation**: https://help.sonatype.com/en/nexus-repository-oss.html
- **Nexus Docker Image**: https://hub.docker.com/r/sonatype/nexus3
- **Maven Repository Format**: https://help.sonatype.com/en/maven-repositories.html
- **Repository REST API**: https://help.sonatype.com/en/rest-api.html

---

## Production Considerations

For production deployments:

1. **Use Docker Compose** with persistent volumes
2. **Enable HTTPS** with valid certificates
3. **Set up Authentication/Authorization** with LDAP or OAuth
4. **Configure Backup & Restore** procedures
5. **Monitor Performance** and disk usage
6. **Use Private Docker Registry** for Nexus images
7. **Implement Rate Limiting** for API access
8. **Set up High Availability** with clustering

---

## Optional: Docker Compose Setup

```yaml
version: '3.8'

services:
  nexus:
    image: sonatype/nexus3:latest
    container_name: nexus3
    ports:
      - "8081:8081"
    environment:
      - INSTALL4J_ADD_VM_PARAMS=-Xms1200M -Xmx1200M -XX:MaxDirectMemorySize=2G
    volumes:
      - nexus-data:/nexus-data
    restart: unless-stopped
    networks:
      - nexus-network

  # Optional: Add reverse proxy (nginx)
  nginx:
    image: nginx:latest
    container_name: nexus-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - nexus
    networks:
      - nexus-network

volumes:
  nexus-data:

networks:
  nexus-network:
    driver: bridge
```

Save as `docker-compose.yml` and run:
```bash
docker-compose up -d
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Start Nexus | `docker run -d -p 8081:8081 --name nexus3 sonatype/nexus3:latest` |
| Access Nexus | `http://localhost:8081` |
| View Logs | `docker logs nexus3` |
| Stop Nexus | `docker stop nexus3` |
| Remove Container | `docker rm nexus3` |
| Test Upload | `curl -u user:pass --upload-file file.zip http://localhost:8081/...` |
| Test Download | `curl -u user:pass -O http://localhost:8081/...` |

---

This completes the Nexus setup. Your GitHub Actions pipeline will now automatically push artifacts to Nexus!
