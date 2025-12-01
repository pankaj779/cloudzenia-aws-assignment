# AWS Infrastructure Deployment - Terraform

This repository contains Terraform infrastructure as code for deploying multi-stack AWS infrastructure including ECS, RDS, EC2, ALB, and supporting services.

## Repository Structure

```
AWS/
├── terraform/
│   ├── modules/              # Reusable Terraform modules
│   │   ├── network/         # VPC, subnets, networking
│   │   ├── ecs-cluster/     # ECS cluster configuration
│   │   ├── ecs-service/     # ECS services and task definitions
│   │   ├── rds/             # RDS database
│   │   ├── alb/             # Application Load Balancer
│   │   ├── ec2-stack/       # EC2 instances
│   │   ├── secrets/         # AWS Secrets Manager
│   │   ├── iam/             # IAM roles and policies
│   │   └── cloudwatch/      # CloudWatch logs and metrics
│   └── environments/
│       └── prod/            # Production environment
├── services/
│   └── microservice/        # Node.js microservice application
├── .github/
│   └── workflows/           # GitHub Actions CI/CD
├── ecs-task-definitions/    # ECS task definition templates
└── SUBMISSION_DOCUMENT.md   # Complete deployment documentation
```

## Quick Start

1. **Configure Variables**
   ```bash
   cd terraform/environments/prod
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

2. **Initialize and Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Follow Manual Steps**
   - See `SUBMISSION_DOCUMENT.md` for complete deployment guide
   - Configure DNS records
   - Set up EC2 instances (Docker, NGINX, Let's Encrypt)
   - Configure GitHub Actions

## Requirements

- Terraform >= 1.5
- AWS CLI configured
- AWS Account with appropriate permissions
- FreeDNS account (for domain)

## Documentation

See `SUBMISSION_DOCUMENT.md` for:
- Complete infrastructure overview
- Terraform vs Manual configuration breakdown
- Step-by-step deployment instructions
- Endpoint URLs and testing procedures
- Cleanup instructions

## What's Included

### Terraform Modules (Infrastructure as Code)
- ✅ VPC and networking
- ✅ ECS cluster and services
- ✅ RDS database
- ✅ Application Load Balancers
- ✅ EC2 instances with Elastic IPs
- ✅ Secrets Manager
- ✅ IAM roles and policies
- ✅ Security Groups
- ✅ CloudWatch log groups

### Manual Configuration (Post-Deployment)
- 🔧 Domain DNS records (FreeDNS)
- 🔧 ACM certificate validation
- 🔧 EC2 software installation (Docker, NGINX)
- 🔧 Let's Encrypt SSL setup
- 🔧 CloudWatch agent configuration
- 🔧 GitHub Actions secrets

## Important Notes

- All AWS infrastructure MUST be created via Terraform
- Manual steps are for post-deployment configuration only
- Use free-tier eligible resources to minimize costs
- Region: `ap-south-1` (Mumbai)
