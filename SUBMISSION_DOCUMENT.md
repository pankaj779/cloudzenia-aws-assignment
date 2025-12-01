# Infrastructure Deployment Documentation

## Overview

This document details the complete infrastructure setup for the multi-stack AWS deployment, including ECS with ALB/RDS, EC2 instances with NGINX, and supporting services. All infrastructure is provisioned using Terraform (Infrastructure as Code), with post-deployment configuration performed manually where specified.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Infrastructure Components](#infrastructure-components)
3. [Terraform vs Manual Configuration](#terraform-vs-manual-configuration)
4. [Deployment Steps](#deployment-steps)
5. [Configuration Details](#configuration-details)
6. [Endpoint URLs](#endpoint-urls)
7. [Testing & Validation](#testing--validation)
8. [Cleanup Instructions](#cleanup-instructions)

---

## Architecture Overview

### Stack 1: ECS with ALB, RDS, and Secrets Manager

- **ECS Cluster**: Deployed in private subnets
- **Services**: WordPress and custom Node.js microservice
- **RDS**: MySQL database in private subnets with automated backups
- **ALB**: Application Load Balancer in public subnets with SSL/TLS
- **Secrets Manager**: Stores RDS credentials securely
- **Auto Scaling**: Configured based on CPU and Memory metrics

### Stack 2: EC2 with NGINX and Docker

- **EC2 Instances**: 2 instances in private subnets with Elastic IPs
- **NGINX**: Reverse proxy with domain-based routing
- **Docker**: Container serving custom content
- **ALB**: Application Load Balancer for EC2 instances
- **Let's Encrypt**: SSL certificates for NGINX
- **CloudWatch**: Metrics and logs monitoring

### Optional: S3 Static Website with CloudFront

- **S3 Bucket**: Static website hosting
- **CloudFront**: CDN distribution with geo-restrictions
- **Lambda@Edge**: HTTP header modifications for SEO

---

## Infrastructure Components

### Network Infrastructure (Terraform)

- VPC with CIDR: `10.0.0.0/16`
- Public Subnets: 2 (for ALB, NAT Gateway)
- Private Subnets: 4 (for ECS, RDS, EC2)
- Internet Gateway
- NAT Gateway (for private subnet internet access)
- Route Tables and Associations

### ECS Infrastructure (Terraform)

- ECS Cluster
- ECS Task Definitions (WordPress, Microservice)
- ECS Services with auto-scaling
- Application Load Balancer
- Target Groups
- Security Groups (least privilege)

### RDS Infrastructure (Terraform)

- RDS MySQL Instance (db.t3.micro - free tier eligible)
- Subnet Group (private subnets)
- Parameter Group
- Automated Backups (7-day retention)
- Security Group

### Secrets Manager (Terraform)

- Secret for RDS credentials (username, password, endpoint)
- IAM role for ECS tasks to access secrets

### EC2 Infrastructure (Terraform)

- 2 EC2 Instances (t2.micro - free tier)
- Elastic IPs attached
- Security Groups
- IAM Role for CloudWatch agent

### CloudWatch (Terraform)

- Log Groups for NGINX access logs
- IAM policies for CloudWatch agent

### GitHub Actions (Manual Setup)

- Workflow file: `.github/workflows/deploy-microservice.yml`
- Builds Docker image
- Pushes to ECR
- Deploys to ECS

---

## Terraform vs Manual Configuration

### ✅ Terraform (Infrastructure as Code)

All AWS infrastructure MUST be created via Terraform:

1. **Network Layer**
   - VPC, Subnets, Internet Gateway, NAT Gateway
   - Route Tables, Security Groups

2. **ECS Stack**
   - ECS Cluster, Task Definitions, Services
   - Application Load Balancer, Target Groups, Listeners
   - Auto Scaling Policies

3. **RDS**
   - RDS Instance, Subnet Group, Parameter Group
   - Automated Backups Configuration

4. **Secrets Manager**
   - Secret creation with RDS credentials

5. **IAM**
   - Roles for ECS tasks, EC2 instances
   - Policies for Secrets Manager access, CloudWatch logging

6. **EC2 Infrastructure**
   - EC2 Instances, Elastic IPs, Security Groups
   - IAM roles for CloudWatch

7. **CloudWatch**
   - Log Groups
   - Metric filters (if needed)

8. **ACM Certificates**
   - Certificate requests (validation done manually)

9. **S3 & CloudFront (Optional)**
   - S3 bucket, CloudFront distribution, Lambda@Edge

### 🔧 Manual Configuration (Post-Deployment)

These are done AFTER Terraform deployment:

1. **Domain Setup**
   - Register free subdomain with FreeDNS (afraid.org)
   - Create DNS records (A, CNAME) pointing to AWS resources

2. **ACM Certificate Validation**
   - Add DNS validation records to FreeDNS
   - Wait for certificate issuance

3. **EC2 Instance Configuration**
   - SSH into instances
   - Install Docker, NGINX
   - Configure NGINX virtual hosts
   - Set up Let's Encrypt certificates
   - Configure CloudWatch agent for metrics and logs
   - Start Docker container

4. **GitHub Actions Setup**
   - Create GitHub repository
   - Add AWS credentials as secrets
   - Push microservice code
   - Configure workflow triggers

5. **WordPress Initial Setup**
   - Access WordPress via ALB endpoint
   - Complete WordPress installation wizard
   - Configure database connection (uses Secrets Manager)

---

## Deployment Steps

### Phase 1: Prerequisites

1. **Domain Setup** (Manual - 10 minutes)
   - Register at [freedns.afraid.org](https://freedns.afraid.org)
   - Get free subdomain (e.g., `aws-cloudzenia.mooo.com`)
   - Note your domain name

2. **AWS Account Setup**
   - Ensure AWS CLI is configured
   - Set default region to `ap-south-1`
   - Verify IAM permissions

3. **Terraform Setup**
   - Install Terraform (v1.5+)
   - Clone repository
   - Navigate to `terraform/environments/prod`

### Phase 2: Terraform Deployment

1. **Configure Variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your domain name and settings
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Plan Deployment**
   ```bash
   terraform plan
   ```

4. **Apply Infrastructure**
   ```bash
   terraform apply
   ```

5. **Note Outputs**
   - ALB DNS names
   - Elastic IP addresses
   - RDS endpoint
   - ECS cluster name
   - ECR repository URL

### Phase 3: DNS Configuration (Manual)

1. **Add DNS Records in FreeDNS**
   - `wordpress.<domain>` → CNAME → ALB DNS name
   - `microservice.<domain>` → CNAME → ALB DNS name
   - `ec2-instance1.<domain>` → A → Elastic IP 1
   - `ec2-docker1.<domain>` → A → Elastic IP 1
   - `ec2-instance2.<domain>` → A → Elastic IP 2
   - `ec2-docker2.<domain>` → A → Elastic IP 2
   - `ec2-alb-instance.<domain>` → CNAME → EC2 ALB DNS name
   - `ec2-alb-docker.<domain>` → CNAME → EC2 ALB DNS name

2. **ACM Certificate Validation**
   - Go to AWS Certificate Manager
   - Copy DNS validation CNAME records
   - Add to FreeDNS
   - Wait for validation (5-10 minutes)

### Phase 4: EC2 Configuration (Manual)

1. **SSH into EC2 Instances**
   ```bash
   ssh -i your-key.pem ec2-user@<elastic-ip>
   ```

2. **Install Docker**
   ```bash
   sudo yum update -y
   sudo yum install docker -y
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker ec2-user
   ```

3. **Create Docker Container**
   ```bash
   # Create simple container
   docker run -d -p 8080:8080 --name namaste-container \
     -e MESSAGE="Namaste from Container" \
     your-custom-image:latest
   ```

4. **Install NGINX**
   ```bash
   sudo yum install nginx -y
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```

5. **Configure NGINX**
   - Edit `/etc/nginx/nginx.conf` or create virtual host configs
   - Set up domain-based routing
   - Configure proxy for Docker container

6. **Install Let's Encrypt**
   ```bash
   sudo yum install certbot python3-certbot-nginx -y
   sudo certbot --nginx -d ec2-instance1.<domain> -d ec2-docker1.<domain>
   ```

7. **Configure CloudWatch Agent**
   ```bash
   wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
   sudo rpm -U ./amazon-cloudwatch-agent.rpm
   # Configure agent for metrics and logs
   ```

### Phase 5: GitHub Actions Setup (Manual)

1. **Create GitHub Repository**
   - Push microservice code to GitHub
   - Make repository public or grant access

2. **Configure GitHub Secrets**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (ap-south-1)
   - `ECR_REPOSITORY`
   - `ECS_CLUSTER`
   - `ECS_SERVICE`

3. **Trigger Workflow**
   - Push to main branch or create PR
   - Workflow will build and deploy automatically

---

## Configuration Details

### ECS Task Definition - WordPress

- **Image**: `wordpress:latest`
- **CPU**: 256 (0.25 vCPU)
- **Memory**: 512 MB
- **Environment Variables**: From Secrets Manager
  - `WORDPRESS_DB_HOST`: RDS endpoint
  - `WORDPRESS_DB_USER`: From Secrets Manager
  - `WORDPRESS_DB_PASSWORD`: From Secrets Manager
  - `WORDPRESS_DB_NAME`: `wordpress`

### ECS Task Definition - Microservice

- **Image**: Custom Node.js application
- **CPU**: 256 (0.25 vCPU)
- **Memory**: 512 MB
- **Port**: 3000
- **Response**: "Hello from Microservice"

### RDS Configuration

- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro
- **Storage**: 20 GB (gp2)
- **Backup Retention**: 7 days
- **Multi-AZ**: No (to save costs)
- **Publicly Accessible**: No
- **Custom Credentials**: Created via Terraform, stored in Secrets Manager

### ALB Configuration

- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Listeners**:
  - Port 80: Redirect to HTTPS
  - Port 443: Forward to target groups (SSL certificate from ACM)
- **Target Groups**:
  - WordPress (port 80)
  - Microservice (port 3000)

### Security Groups

- **ALB Security Group**: Allow 80, 443 from 0.0.0.0/0
- **ECS Security Group**: Allow from ALB security group only
- **RDS Security Group**: Allow 3306 from ECS security group only
- **EC2 Security Group**: Allow 22 (SSH), 80, 443 from ALB/0.0.0.0/0

### Auto Scaling

- **ECS Service Auto Scaling**:
  - Min: 1 task
  - Max: 4 tasks
  - Target CPU: 70%
  - Target Memory: 80%

---

## Endpoint URLs

After deployment, the following endpoints will be accessible:

### ECS Stack

- **WordPress**: `https://wordpress.<your-domain>`
- **Microservice**: `https://microservice.<your-domain>`

### EC2 Stack

- **EC2 Instance 1 Direct**: `https://ec2-instance1.<your-domain>`
- **EC2 Docker 1 Direct**: `https://ec2-docker1.<your-domain>`
- **EC2 Instance 2 Direct**: `https://ec2-instance2.<your-domain>`
- **EC2 Docker 2 Direct**: `https://ec2-docker2.<your-domain>`
- **EC2 ALB Instance**: `https://ec2-alb-instance.<your-domain>`
- **EC2 ALB Docker**: `https://ec2-alb-docker.<your-domain>`

### Optional S3 Stack

- **Static Website**: `https://static-s3.<your-domain>`

**Note**: Replace `<your-domain>` with your actual FreeDNS subdomain (e.g., `aws-cloudzenia.mooo.com`)

---

## Testing & Validation

### Pre-Deployment Checks

- [ ] Terraform plan shows no errors
- [ ] All variables are set correctly
- [ ] Domain DNS records are configured
- [ ] ACM certificates are validated

### Post-Deployment Checks

- [ ] WordPress is accessible via HTTPS
- [ ] Microservice returns "Hello from Microservice"
- [ ] EC2 instances serve correct content
- [ ] Docker container responds with "Namaste from Container"
- [ ] HTTP redirects to HTTPS
- [ ] CloudWatch shows RAM metrics
- [ ] CloudWatch shows NGINX access logs
- [ ] GitHub Actions workflow completes successfully
- [ ] Auto scaling triggers correctly

### Test Commands

```bash
# Test WordPress
curl -I https://wordpress.<your-domain>

# Test Microservice
curl https://microservice.<your-domain>

# Test EC2 Instance
curl https://ec2-instance1.<your-domain>

# Test Docker Container
curl https://ec2-docker1.<your-domain>

# Verify HTTPS only
curl http://wordpress.<your-domain>  # Should redirect to HTTPS
```

---

## Cleanup Instructions

To avoid unnecessary AWS charges, destroy all resources after evaluation:

1. **Destroy Terraform Infrastructure**
   ```bash
   cd terraform/environments/prod
   terraform destroy
   ```

2. **Delete DNS Records**
   - Remove all DNS records from FreeDNS
   - Delete ACM certificates (if not auto-deleted)

3. **Clean Up GitHub**
   - Delete GitHub repository (optional)
   - Remove GitHub Actions secrets

4. **Verify Cleanup**
   - Check AWS Console for any remaining resources
   - Verify no charges in AWS Cost Explorer

---

## Repository Structure

```
AWS/
├── terraform/
│   ├── modules/          # Reusable Terraform modules
│   │   ├── network/
│   │   ├── ecs-cluster/
│   │   ├── ecs-service/
│   │   ├── rds/
│   │   ├── alb/
│   │   ├── ec2-stack/
│   │   ├── secrets/
│   │   ├── iam/
│   │   └── cloudwatch/
│   └── environments/
│       └── prod/         # Production environment
├── services/
│   └── microservice/    # Node.js microservice code
├── .github/
│   └── workflows/       # GitHub Actions workflow
└── SUBMISSION_DOCUMENT.md  # This document
```

---

## Additional Notes

- All infrastructure uses free-tier eligible resources where possible
- Region: `ap-south-1` (Mumbai)
- Terraform state can be stored in S3 backend (configure in `backend.tf`)
- Secrets Manager credentials do NOT auto-rotate (as per requirements)
- Security groups follow least privilege principle
- All HTTP traffic redirects to HTTPS
- CloudWatch agent configured for RAM metrics and NGINX logs

---

**Document Version**: 1.0  
**Last Updated**: [Date]  
**Author**: [Your Name]

