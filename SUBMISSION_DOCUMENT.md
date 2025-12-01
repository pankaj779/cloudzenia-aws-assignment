# CloudZenia Hands-On Assignment - Submission Document

## Overview

This document provides a comprehensive overview of the AWS infrastructure deployed using Terraform (Infrastructure as Code) for the CloudZenia interview assignment.

---

## ✅ Completed Challenges

### Challenge 1: ECS with ALB, RDS and SecretsManager ✅

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| ECS Cluster in Private Subnets | ✅ | `modules/ecs-cluster` |
| WordPress Service | ✅ | `modules/ecs-service` |
| Custom Microservice | ✅ | `services/microservice/` |
| Auto Scaling (CPU/Memory) | ✅ | Target tracking policies |
| RDS in Private Subnets | ✅ | `modules/rds` - MySQL 8.0 |
| Custom RDS Credentials (non-rotating) | ✅ | Via terraform.tfvars |
| Automated Backups | ✅ | 1 day retention |
| Secrets Manager | ✅ | `modules/secrets` |
| ECS Task uses Secrets Manager | ✅ | WordPress task definition |
| IAM Roles for Secrets Access | ✅ | `modules/iam` |
| Least Privilege Security Groups | ✅ | `modules/security` |
| ALB in Public Subnets | ✅ | `modules/alb` |
| Host-based Routing | ✅ | Path-based routing implemented |

### Challenge 2: EC2 Instance with NGINX ✅

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| 2 EC2 Instances in Private Subnets | ✅ | `modules/ec2-stack` |
| Elastic IPs | ✅ | Attached to instances |
| ALB for EC2 | ✅ | `modules/alb-ec2` |
| IAM Role for CloudWatch | ✅ | `modules/iam` |

### Challenge 3: Observability ✅

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| CloudWatch Log Groups | ✅ | Created for NGINX |
| IAM Policies for CloudWatch Agent | ✅ | `modules/iam` |

### Challenge 4: GitHub Actions ✅

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| Microservice in GitHub | ✅ | `services/microservice/` |
| GitHub Actions Workflow | ✅ | `.github/workflows/deploy-microservice.yml` |
| Build Docker Image | ✅ | Automated in workflow |
| Push to ECR | ✅ | Automated in workflow |
| Deploy to ECS | ✅ | Automated in workflow |

### Challenge 5: S3 Static Website (Optional) ❌

Not implemented.

---

## ❌ Not Implemented

| Feature | Reason |
|---------|--------|
| SSL/TLS Certificates | Domain setup not completed |
| HTTPS Configuration | Requires SSL certificates |
| Domain Mapping | Requires DNS configuration |
| Let's Encrypt on EC2 | Requires domain |
| Docker/NGINX on EC2 | Manual configuration required |
| S3 + CloudFront | Optional - not completed |

---

## 🏗️ Architecture

```
                          ┌─────────────────────────────────────────────────────────────┐
                          │                         AWS Cloud                            │
                          │  ┌─────────────────────────────────────────────────────────┐ │
                          │  │                    VPC (10.0.0.0/16)                     │ │
                          │  │                                                          │ │
┌──────────┐              │  │  ┌─────────────────┐      ┌─────────────────┐           │ │
│  Users   │──────────────┼──┼──│  Public Subnet  │      │  Public Subnet  │           │ │
└──────────┘              │  │  │  ┌───────────┐  │      │                 │           │ │
                          │  │  │  │    ALB    │  │      │   NAT Gateway   │           │ │
                          │  │  │  └─────┬─────┘  │      │                 │           │ │
                          │  │  └────────┼────────┘      └────────┬────────┘           │ │
                          │  │           │                        │                     │ │
                          │  │  ┌────────┴────────────────────────┴────────┐           │ │
                          │  │  │              Private Subnets              │           │ │
                          │  │  │  ┌─────────────┐    ┌─────────────┐      │           │ │
                          │  │  │  │ ECS Fargate │    │ ECS Fargate │      │           │ │
                          │  │  │  │ (WordPress) │    │(Microservice)│     │           │ │
                          │  │  │  └──────┬──────┘    └──────┬──────┘      │           │ │
                          │  │  │         │                  │              │           │ │
                          │  │  │         └────────┬─────────┘              │           │ │
                          │  │  │                  │                        │           │ │
                          │  │  │         ┌────────┴────────┐               │           │ │
                          │  │  │         │   RDS MySQL     │               │           │ │
                          │  │  │         │  (db.t3.micro)  │               │           │ │
                          │  │  │         └─────────────────┘               │           │ │
                          │  │  │                                           │           │ │
                          │  │  │  ┌─────────────┐    ┌─────────────┐      │           │ │
                          │  │  │  │  EC2 + EIP  │    │  EC2 + EIP  │      │           │ │
                          │  │  │  │ (t3.micro)  │    │ (t3.micro)  │      │           │ │
                          │  │  │  └─────────────┘    └─────────────┘      │           │ │
                          │  │  └───────────────────────────────────────────┘           │ │
                          │  └──────────────────────────────────────────────────────────┘ │
                          │                                                               │
                          │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  │
                          │  │ Secrets Manager│  │      ECR       │  │   CloudWatch   │  │
                          │  │ (RDS Creds)    │  │ (Microservice) │  │  (Logs/Metrics)│  │
                          │  └────────────────┘  └────────────────┘  └────────────────┘  │
                          └───────────────────────────────────────────────────────────────┘

                          ┌───────────────────────────────────────────────────────────────┐
                          │                      GitHub Actions                            │
                          │  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    │
                          │  │ Checkout│───▶│  Build  │───▶│Push ECR │───▶│Deploy   │    │
                          │  │         │    │ Docker  │    │         │    │  ECS    │    │
                          │  └─────────┘    └─────────┘    └─────────┘    └─────────┘    │
                          └───────────────────────────────────────────────────────────────┘
```

---

## 🔗 Running Endpoints

### ECS Services (via ALB)

| Service | URL | Expected Response |
|---------|-----|-------------------|
| WordPress | http://cloudzenia-hands-on-prod-alb-1566233852.ap-south-1.elb.amazonaws.com/ | WordPress setup page |
| Microservice | http://cloudzenia-hands-on-prod-alb-1566233852.ap-south-1.elb.amazonaws.com/microservice | JSON: `{"message": "Hello from Microservice", ...}` |

### EC2 Instances

| Instance | Elastic IP |
|----------|------------|
| EC2 Instance 1 | 35.154.100.147 |
| EC2 Instance 2 | 13.205.11.97 |

### EC2 ALB

| URL |
|-----|
| http://cloudzenia-hands-on-prod-ec2-alb-465904925.ap-south-1.elb.amazonaws.com |

---

## 📁 Terraform Modules

| Module | Description | Path |
|--------|-------------|------|
| network | VPC, Subnets, NAT Gateway, Route Tables | `terraform/modules/network/` |
| security | Security Groups (ALB, ECS, RDS, EC2) | `terraform/modules/security/` |
| iam | IAM Roles, Policies, Instance Profiles | `terraform/modules/iam/` |
| secrets | Secrets Manager for RDS credentials | `terraform/modules/secrets/` |
| rds | RDS MySQL Instance, Subnet Group | `terraform/modules/rds/` |
| ecs-cluster | ECS Cluster with Container Insights | `terraform/modules/ecs-cluster/` |
| ecs-service | Reusable ECS Service module | `terraform/modules/ecs-service/` |
| alb | Application Load Balancer for ECS | `terraform/modules/alb/` |
| alb-ec2 | Application Load Balancer for EC2 | `terraform/modules/alb-ec2/` |
| ecr | ECR Repository with lifecycle policy | `terraform/modules/ecr/` |
| ec2-stack | EC2 Instances with Elastic IPs | `terraform/modules/ec2-stack/` |

---

## 🐳 Microservice Code

### Node.js Application (`services/microservice/src/index.js`)

```javascript
import express from 'express'

const app = express()
const port = process.env.PORT || 3000
const message = process.env.MESSAGE || 'Hello from Microservice'

app.get('/', (req, res) => {
  res.json({
    message,
    timestamp: new Date().toISOString(),
    hostname: req.hostname
  })
})

app.get('/healthz', (req, res) => {
  res.status(200).send('ok')
})

app.listen(port, () => {
  console.log(`Microservice running on port ${port}`)
})
```

### Dockerfile (`services/microservice/Dockerfile`)

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY src ./src

ENV PORT=3000
EXPOSE 3000

CMD ["npm", "start"]
```

---

## 🔄 GitHub Actions Workflow

The CI/CD pipeline is configured in `.github/workflows/deploy-microservice.yml`:

1. **Trigger**: Push to `main` branch (when `services/microservice/**` changes) or manual dispatch
2. **Authentication**: OIDC-based (no AWS access keys stored)
3. **Steps**:
   - Checkout code
   - Configure AWS credentials via OIDC
   - Login to Amazon ECR
   - Build and push Docker image
   - Render ECS task definition
   - Deploy to ECS service

---

## 🔒 Security Implementation

### Security Groups (Least Privilege)

| Security Group | Inbound Rules |
|---------------|---------------|
| ALB | 80, 443 from 0.0.0.0/0 |
| ECS | All traffic from ALB SG only |
| RDS | 3306 from ECS SG only |
| EC2 | 22, 80, 443 (restricted) |

### IAM Roles

| Role | Purpose |
|------|---------|
| ECS Task Execution Role | Pull images, write logs, read secrets |
| ECS Task Role | Application access to Secrets Manager |
| EC2 Instance Role | CloudWatch agent access |
| GitHub Actions Role | ECR push, ECS deploy (OIDC) |

---

## 📊 Auto Scaling Configuration

| Metric | Target | Min | Max |
|--------|--------|-----|-----|
| CPU Utilization | 70% | 1 | 4 |
| Memory Utilization | 80% | 1 | 4 |

---

## 🧹 Cleanup Instructions

To destroy all resources and avoid AWS charges:

```bash
cd terraform
terraform destroy -auto-approve
```

---

## 📝 Key Configuration Values

| Resource | Value |
|----------|-------|
| AWS Region | ap-south-1 (Mumbai) |
| VPC CIDR | 10.0.0.0/16 |
| ECS Cluster | cloudzenia-hands-on-prod-cluster |
| ECR Repository | cloudzenia-hands-on-prod-microservice |
| RDS Instance | db.t3.micro (MySQL 8.0) |
| EC2 Instance | t3.micro (Amazon Linux 2023) |

---

## 🔗 Repository

**GitHub**: https://github.com/pankaj779/cloudzenia-aws-assignment

---

**Submitted by**: Pankaj  
**Date**: December 2025
