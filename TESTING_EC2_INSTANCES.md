# Testing EC2 Instances - Quick Guide

## Step 1: Get Your EC2 Instance IPs

Run this in your terminal (from terraform directory):
```bash
cd terraform
terraform output ec2_instance_1_public_ip
terraform output ec2_instance_2_public_ip
```

Or check AWS Console:
- Go to EC2 → Instances
- Look for instances named: `cloudzenia-hands-on-prod-ec2-instance-1` and `cloudzenia-hands-on-prod-ec2-instance-2`
- Note their **Public IP** addresses

## Step 2: Test HTTP Endpoints

### Test 1: "Hello from Instance" (Default Route)
Open in browser or use curl:
```
http://<EC2_INSTANCE_1_IP>/
http://<EC2_INSTANCE_2_IP>/
```

**Expected Result:** Should show "Hello from Instance"

### Test 2: Docker Container (Namaste from Container)
```
http://<EC2_INSTANCE_1_IP>/docker
http://<EC2_INSTANCE_2_IP>/docker
```

**Expected Result:** Should show "Namaste from Container"

## Step 3: Verify Services (SSH into Instance)

### Connect via SSH:
```bash
# You'll need the key pair (.pem file) for the instance
# If you don't have it, you can use AWS Systems Manager Session Manager
ssh -i your-key.pem ec2-user@<EC2_INSTANCE_IP>
```

### Once connected, verify:

#### 1. Docker is running:
```bash
sudo systemctl status docker
docker ps
```

**Expected:** Should see `namaste-container` running

#### 2. Docker container content:
```bash
docker exec namaste-container cat /usr/share/nginx/html/index.html
```

**Expected:** Should show "Namaste from Container"

#### 3. NGINX is running:
```bash
sudo systemctl status nginx
curl http://localhost/
curl http://localhost/docker
```

**Expected:** 
- `/` → "Hello from Instance"
- `/docker` → "Namaste from Container"

#### 4. Check NGINX configuration:
```bash
sudo cat /etc/nginx/conf.d/default.conf
```

## Step 4: Test from Browser

1. Open browser
2. Go to: `http://<EC2_INSTANCE_1_IP>/`
   - Should see: "Hello from Instance"
3. Go to: `http://<EC2_INSTANCE_1_IP>/docker`
   - Should see: "Namaste from Container"
4. Repeat for Instance 2

## Troubleshooting

### If services aren't ready:
- Wait 2-3 minutes after instance creation (user data script needs time)
- Check instance status in AWS Console
- SSH and check logs:
  ```bash
  sudo tail -f /var/log/cloud-init-output.log
  ```

### If Docker container not running:
```bash
sudo docker ps -a
sudo docker start namaste-container
```

### If NGINX not working:
```bash
sudo systemctl restart nginx
sudo nginx -t  # Check configuration
```

## Next Steps (After Testing)

1. **Configure domain-based routing** (manual step):
   - Update NGINX config for specific domains
   - Set up Let's Encrypt SSL certificates

2. **Stage 11:** Create ALB for EC2 instances
3. **Stage 12:** Configure CloudWatch monitoring

