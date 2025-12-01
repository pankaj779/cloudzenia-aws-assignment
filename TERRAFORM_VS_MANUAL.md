# Terraform vs Manual Configuration Breakdown

This document clearly outlines what MUST be done via Terraform (Infrastructure as Code) and what is done manually (post-deployment configuration).

## ✅ TERRAFORM (Infrastructure as Code) - REQUIRED

All AWS infrastructure resources MUST be created using Terraform. This demonstrates Infrastructure as Code skills.

### Network Infrastructure
- [x] VPC creation
- [x] Public subnets (for ALB, NAT Gateway)
- [x] Private subnets (for ECS, RDS, EC2)
- [x] Internet Gateway
- [x] NAT Gateway
- [x] Route Tables
- [x] Security Groups (with least privilege rules)

### ECS Infrastructure
- [x] ECS Cluster
- [x] ECS Task Definitions (WordPress, Microservice)
- [x] ECS Services
- [x] Auto Scaling Policies (CPU and Memory based)
- [x] Application Load Balancer
- [x] Target Groups
- [x] ALB Listeners (HTTP redirect, HTTPS)
- [x] ALB Listener Rules (domain-based routing)

### RDS Infrastructure
- [x] RDS MySQL Instance (appropriate instance type)
- [x] DB Subnet Group (private subnets)
- [x] DB Parameter Group
- [x] Automated Backups (7-day retention)
- [x] Custom database user and password (non-rotating)

### Secrets Manager
- [x] Secret creation for RDS credentials
- [x] Secret values (username, password, endpoint)

### IAM Configuration
- [x] ECS Task Execution Role
- [x] ECS Task Role (for Secrets Manager access)
- [x] EC2 Instance Role (for CloudWatch)
- [x] IAM Policies (Secrets Manager read, CloudWatch write)

### EC2 Infrastructure
- [x] EC2 Instances (2 instances)
- [x] Elastic IPs
- [x] Elastic IP associations
- [x] Security Groups for EC2

### CloudWatch
- [x] Log Groups for NGINX access logs
- [x] IAM policies for CloudWatch agent

### ACM Certificates
- [x] Certificate requests (via Terraform)
- [x] Certificate domain validation setup

### Optional: S3 & CloudFront
- [x] S3 bucket for static website
- [x] CloudFront distribution
- [x] Lambda@Edge function
- [x] Geo-restriction configuration

---

## 🔧 MANUAL (Post-Deployment Configuration)

These steps are performed AFTER Terraform deployment. They involve external services or instance-level configuration.

### Domain & DNS (External Service)
- [ ] Register free subdomain with FreeDNS (afraid.org)
- [ ] Create DNS A records pointing to Elastic IPs
- [ ] Create DNS CNAME records pointing to ALB DNS names
- [ ] Add ACM certificate validation CNAME records

### ACM Certificate Validation
- [ ] Copy DNS validation records from AWS Console
- [ ] Add validation records to FreeDNS
- [ ] Wait for certificate issuance (5-10 minutes)

### EC2 Instance Configuration
- [ ] SSH into EC2 instances
- [ ] Install Docker
  ```bash
  sudo yum install docker -y
  sudo systemctl start docker
  sudo usermod -aG docker ec2-user
  ```
- [ ] Run Docker container
  ```bash
  docker run -d -p 8080:8080 --name namaste-container <image>
  ```
- [ ] Install NGINX
  ```bash
  sudo yum install nginx -y
  sudo systemctl start nginx
  ```
- [ ] Configure NGINX virtual hosts
  - Edit `/etc/nginx/conf.d/default.conf`
  - Set up domain-based routing
  - Configure proxy for Docker container
- [ ] Install and configure Let's Encrypt
  ```bash
  sudo yum install certbot python3-certbot-nginx -y
  sudo certbot --nginx -d ec2-instance1.<domain> -d ec2-docker1.<domain>
  ```
- [ ] Configure CloudWatch Agent
  - Install agent
  - Configure for RAM metrics
  - Configure for NGINX log collection

### GitHub Actions Setup
- [ ] Create GitHub repository
- [ ] Push microservice code
- [ ] Add AWS credentials as GitHub Secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
  - `ECR_REPOSITORY`
  - `ECS_CLUSTER`
  - `ECS_SERVICE`
- [ ] Trigger workflow (push to main branch)

### WordPress Initial Setup
- [ ] Access WordPress via ALB endpoint
- [ ] Complete WordPress installation wizard
- [ ] Verify database connection (uses Secrets Manager)

---

## Summary

| Component | Method | Reason |
|-----------|--------|--------|
| AWS Infrastructure | Terraform | Required - demonstrates IaC skills |
| Domain Registration | Manual | External service (FreeDNS) |
| DNS Records | Manual | External service configuration |
| ACM Validation | Manual | Requires DNS record addition |
| EC2 Software Install | Manual | Instance-level configuration |
| NGINX Config | Manual | Application configuration |
| Let's Encrypt | Manual | Certificate installation on instance |
| CloudWatch Agent | Manual | Agent installation and configuration |
| GitHub Actions | Manual | External service setup |
| WordPress Setup | Manual | Application initialization |

---

## Key Points

1. **Terraform is MANDATORY** for all AWS resources - this is the core requirement
2. **Manual steps** are for:
   - External services (FreeDNS, GitHub)
   - Instance-level software installation
   - Application configuration
   - Certificate installation
3. **Documentation** should clearly show what was done via Terraform vs manual
4. **Video demonstration** (optional) should show both Terraform deployment and manual configuration

---

## Verification Checklist

Before submission, verify:

- [ ] All AWS resources created via Terraform (check `terraform state list`)
- [ ] Terraform modules are reusable
- [ ] All manual steps documented in `SUBMISSION_DOCUMENT.md`
- [ ] All endpoints are accessible and working
- [ ] HTTPS is enforced (HTTP redirects)
- [ ] CloudWatch shows metrics and logs
- [ ] GitHub Actions workflow is functional
- [ ] Auto scaling is configured and working

