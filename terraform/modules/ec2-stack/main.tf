# EC2 Stack Module - 2 EC2 Instances with Docker and NGINX

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script for EC2 instances
# Instance 1: Shows "Hello from Instance" and proxies to Docker container
# Instance 2: Shows "Hello from Instance" and proxies to Docker container
locals {
  user_data = <<-EOF
#!/bin/bash
# Don't exit on error - we want to complete as much as possible
set +e

# Log everything
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== Starting user data script ==="

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
sleep 5

# Run Docker container (use Amazon ECR Public to avoid Docker Hub rate limits)
docker run -d --name namaste-container --restart unless-stopped -p 8080:80 public.ecr.aws/docker/library/nginx:alpine
sleep 5

# Wait for container to be ready
for i in {1..10}; do
  if docker ps | grep -q namaste-container; then
    echo "Docker container is running"
    break
  fi
  sleep 2
done

# Update container content
for i in {1..10}; do
  if docker exec namaste-container sh -c 'echo "Namaste from Container" > /usr/share/nginx/html/index.html' 2>/dev/null; then
    echo "Container content updated"
    break
  fi
  sleep 2
done

# Verify container is listening on port 8080
for i in {1..10}; do
  if netstat -tlnp 2>/dev/null | grep -q :8080 || ss -tlnp 2>/dev/null | grep -q :8080; then
    echo "Container is listening on port 8080"
    break
  fi
  sleep 2
done

# Install NGINX
yum install -y nginx

# Disable default server block in nginx.conf (it conflicts with our config)
sed -i '/^    server {/,/^    }$/s/^/#/' /etc/nginx/nginx.conf

# Remove default config
rm -f /etc/nginx/conf.d/default.conf

# Create NGINX config
cat > /etc/nginx/conf.d/default.conf <<'NGINX_EOF'
server {
    listen 80 default_server;
    server_name _;
    
    location = / {
        add_header Content-Type text/plain;
        return 200 "Hello from Instance\n";
    }
    
    location /docker {
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location / {
        add_header Content-Type text/plain;
        return 200 "Hello from Instance\n";
    }
}
NGINX_EOF

# Test NGINX config
if nginx -t; then
  echo "NGINX config is valid"
else
  echo "NGINX config test failed - using default"
  rm -f /etc/nginx/conf.d/default.conf
fi

# Start NGINX
systemctl enable nginx
systemctl start nginx
sleep 5

# Verify NGINX is running
if systemctl is-active --quiet nginx; then
  echo "✅ NGINX is running"
  # Test local response
  curl -s http://localhost/ && echo "✅ Local HTTP test passed"
else
  echo "❌ NGINX failed to start - checking status"
  systemctl status nginx
  # Try starting again
  systemctl start nginx
  sleep 3
fi

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Get instance ID for log stream name
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
LOG_GROUP="${var.cloudwatch_log_group_name}"

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CW_EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "namespace": "EC2/Instance",
    "metrics_collected": {
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "RAMUtilization",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "totalcpu": false,
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "$LOG_GROUP",
            "log_stream_name": "$INSTANCE_ID-nginx-access",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "$LOG_GROUP",
            "log_stream_name": "$INSTANCE_ID-nginx-error",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CW_EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

echo "=== User data script completed ==="
EOF
}

# EC2 Instance 1
resource "aws_instance" "ec2_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"  # Free tier eligible (t2.micro not available)
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name
  user_data              = base64encode(local.user_data)
  
  # Force recreation when user_data changes
  user_data_replace_on_change = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-instance-1"
    }
  )
}

# Elastic IP for EC2 Instance 1
resource "aws_eip" "ec2_1" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-1-eip"
    }
  )
}

# Associate Elastic IP with EC2 Instance 1
resource "aws_eip_association" "ec2_1" {
  instance_id   = aws_instance.ec2_1.id
  allocation_id = aws_eip.ec2_1.id
}

# EC2 Instance 2
resource "aws_instance" "ec2_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"  # Free tier eligible (t2.micro not available)
  subnet_id              = var.private_subnet_ids[1]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name
  user_data              = base64encode(local.user_data)
  
  # Force recreation when user_data changes
  user_data_replace_on_change = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-instance-2"
    }
  )
}

# Elastic IP for EC2 Instance 2
resource "aws_eip" "ec2_2" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-2-eip"
    }
  )
}

# Associate Elastic IP with EC2 Instance 2
resource "aws_eip_association" "ec2_2" {
  instance_id   = aws_instance.ec2_2.id
  allocation_id = aws_eip.ec2_2.id
}

