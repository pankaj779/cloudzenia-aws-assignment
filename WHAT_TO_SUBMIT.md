# What to Submit - Checklist

Based on the assignment requirements, here's exactly what needs to be submitted:

## 1. Code Submission ✅

### Required Files:

- [x] **All Terraform scripts** (`terraform/` directory)
  - Reusable modules in `terraform/modules/`
  - Environment configuration in `terraform/environments/prod/`
  
- [x] **Relevant configuration files**
  - `services/microservice/` - Node.js code and Dockerfile
  - `.github/workflows/deploy-microservice.yml` - GitHub Actions workflow
  - `ecs-task-definitions/` - ECS task definition templates

## 2. GitHub Repository ✅

- [x] **GitHub Actions Workflow file**
  - Location: `.github/workflows/deploy-microservice.yml`
  - Must build Docker image, push to ECR, deploy to ECS
  
- [x] **Repository Access**
  - Make repository public, OR
  - Grant access to CloudZenia evaluators

## 3. Documentation ✅

- [x] **Comprehensive Document** (`.md` or `.pdf`)
  - File: `SUBMISSION_DOCUMENT.md`
  - Must include:
    - Infrastructure setup details
    - Configuration details
    - **All endpoint URLs** (this is critical!)

## 4. Running Endpoints ✅

- [x] **All endpoints must be live and accessible**
  - WordPress: `https://wordpress.<domain>`
  - Microservice: `https://microservice.<domain>`
  - EC2 instances: `https://ec2-instance1.<domain>`, etc.
  - EC2 ALB: `https://ec2-alb-instance.<domain>`, etc.
  - Optional S3: `https://static-s3.<domain>`

- [x] **Endpoints must remain accessible for 48 hours after submission**

## 5. Optional: Video Demonstration

- [ ] **Video (optional, < 3 minutes)**
  - Demonstrate entire challenge
  - Show Terraform deployment
  - Show manual configuration
  - Show working endpoints

---

## What's NOT Required

❌ Multiple separate documentation files  
❌ Domain setup guides (just use free subdomain)  
❌ Implementation plans  
❌ Detailed runbooks  
❌ Architecture diagrams (unless helpful)  

**Keep it simple**: One main document (`SUBMISSION_DOCUMENT.md`) with everything.

---

## Folder Structure for Submission

```
AWS/
├── terraform/                    # ✅ REQUIRED - All Terraform code
│   ├── modules/                 # ✅ REQUIRED - Reusable modules
│   └── environments/prod/       # ✅ REQUIRED - Main configuration
├── services/                    # ✅ REQUIRED - Microservice code
│   └── microservice/
│       ├── src/index.js         # ✅ REQUIRED - Node.js code
│       ├── Dockerfile           # ✅ REQUIRED - Dockerfile
│       └── package.json         # ✅ REQUIRED - Dependencies
├── .github/                     # ✅ REQUIRED - GitHub Actions
│   └── workflows/
│       └── deploy-microservice.yml
├── ecs-task-definitions/        # ✅ HELPFUL - Task definitions
├── README.md                    # ✅ HELPFUL - Quick reference
├── SUBMISSION_DOCUMENT.md       # ✅ REQUIRED - Main documentation
├── TERRAFORM_VS_MANUAL.md       # ✅ HELPFUL - Clear breakdown
└── WHAT_TO_SUBMIT.md            # ✅ HELPFUL - This file
```

---

## Submission Checklist

Before submitting, verify:

- [ ] All Terraform code is complete and tested
- [ ] Terraform modules are reusable
- [ ] GitHub Actions workflow is functional
- [ ] Microservice code is in repository
- [ ] `SUBMISSION_DOCUMENT.md` is complete with:
  - [ ] Infrastructure setup
  - [ ] Configuration details
  - [ ] **All endpoint URLs listed**
- [ ] All endpoints are live and accessible
- [ ] HTTPS is working (HTTP redirects)
- [ ] Auto scaling is configured
- [ ] CloudWatch metrics/logs are visible
- [ ] Repository is public or access granted

---

## Key Points

1. **Terraform is the core requirement** - All AWS infrastructure must be in Terraform
2. **One comprehensive document** - Not multiple files
3. **Endpoint URLs are critical** - Must be listed in documentation
4. **Keep it clean** - Only submit what's required
5. **Test everything** - Endpoints must work for 48 hours after submission

---

## Timeline

- **48 hours** to complete from start
- **48 hours** endpoints must remain accessible after submission
- **Total**: ~96 hours of availability needed

---

Good luck! 🚀

