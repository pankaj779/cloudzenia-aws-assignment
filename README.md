# CloudZenia AWS Infrastructure - Terraform

This repository contains complete Infrastructure as Code (IaC) using Terraform for deploying a multi-stack AWS infrastructure including ECS, RDS, EC2, ALB, and CI/CD with GitHub Actions.

## 📋 What's Implemented

### ✅ Challenge 1: ECS with ALB, RDS and SecretsManager
- ECS Cluster running in Private Subnets
- WordPress and custom Node.js Microservice
- Auto scaling based on CPU and Memory
- RDS MySQL in Private Subnets with automated backups
- Secrets Manager for RDS credentials
- Application Load Balancer with host-based routing
- Least privilege Security Groups

### ✅ Challenge 2: EC2 Instance with NGINX
- 2 EC2 Instances in Private Subnets
- Elastic IPs attached
- Application Load Balancer for EC2
- IAM roles for CloudWatch

### ✅ Challenge 3: Observability
- CloudWatch Log Groups for NGINX
- IAM policies for CloudWatch agent

### ✅ Challenge 4: GitHub Actions
- CI/CD pipeline for Microservice
- Builds Docker image → Pushes to ECR → Deploys to ECS
- OIDC authentication (no access keys stored)

### ❌ Not Implemented
- SSL/TLS certificates and domain mapping
- S3 Static Website with CloudFront (Optional)

---

## 🏗️ Repository Structure

```
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   ├── providers.tf            # AWS provider configuration
│   └── modules/
│       ├── network/            # VPC, Subnets, Gateways
│       ├── security/           # Security Groups
│       ├── iam/                # IAM Roles and Policies
│       ├── secrets/            # Secrets Manager
│       ├── rds/                # RDS MySQL Database
│       ├── ecs-cluster/        # ECS Cluster
│       ├── ecs-service/        # ECS Services (reusable)
│       ├── alb/                # Application Load Balancer
│       ├── alb-ec2/            # ALB for EC2 instances
│       ├── ecr/                # ECR Repository
│       └── ec2-stack/          # EC2 Instances
├── services/
│   └── microservice/           # Node.js Microservice
│       ├── Dockerfile
│       ├── package.json
│       └── src/index.js
├── ecs-task-definitions/
│   └── microservice.json       # ECS Task Definition
├── .github/
│   └── workflows/
│       └── deploy-microservice.yml  # GitHub Actions CI/CD
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.5
- AWS CLI configured
- AWS Account with appropriate permissions

### Deploy Infrastructure

```bash
cd terraform

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Set: db_password, project_name, etc.

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### GitHub Actions Setup

1. Add these secrets to your GitHub repository:
   - `AWS_ROLE_TO_ASSUME`: IAM role ARN for GitHub Actions
   - `ECR_REPOSITORY`: ECR repository name
   - `ECS_CLUSTER_NAME`: ECS cluster name

2. Push changes to trigger the workflow

---

## 📊 Infrastructure Details

### Network
- VPC CIDR: `10.0.0.0/16`
- 2 Public Subnets (ALB, NAT Gateway)
- 2 Private Subnets (ECS, RDS, EC2)
- NAT Gateway for private subnet internet access

### ECS Services
| Service | Image | CPU | Memory | Port |
|---------|-------|-----|--------|------|
| WordPress | wordpress:latest | 512 | 1024 MB | 80 |
| Microservice | Custom Node.js | 256 | 512 MB | 3000 |

### RDS
- Engine: MySQL 8.0
- Instance: db.t3.micro (Free Tier)
- Storage: 20 GB
- Backup Retention: 1 day

### EC2
- 2x t3.micro instances (Free Tier)
- Amazon Linux 2023
- Elastic IPs attached

---

## 🔗 Running Endpoints

| Service | URL |
|---------|-----|
| WordPress | `http://<alb-dns-name>/` |
| Microservice | `http://<alb-dns-name>/microservice` |

Get actual DNS names:
```bash
cd terraform
terraform output alb_dns_name
terraform output ec2_alb_dns_name
```

---

## 🧹 Cleanup

To destroy all resources and avoid charges:

```bash
cd terraform
terraform destroy
```

---

## 📝 Notes

- All infrastructure created via Terraform (IaC)
- Free Tier eligible resources used where possible
- Region: `ap-south-1` (Mumbai)
- Security Groups follow least privilege principle
- RDS credentials stored in Secrets Manager (non-rotating)

---

**Author**: Pankaj  
**Repository**: https://github.com/pankaj779/cloudzenia-aws-assignment
