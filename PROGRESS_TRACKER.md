# Progress Tracker - CloudZenia Assignment

## Current Status: Stage 3 - IAM Roles (In Progress)

### ✅ Completed
- [x] **Stage 1: Networking** - COMPLETE ✅
  - [x] Project structure setup
  - [x] Network module created (VPC, Subnets, Gateways, Routes)
  - [x] Fixed duplicate variable declarations
  - [x] Fixed default_tags syntax error
  - [x] Fixed subnet count mismatch (using 2 AZs instead of 3)
  - [x] Network deployed and tested ✅

- [x] **Stage 2: Security Groups** - COMPLETE ✅
  - [x] Security module created
  - [x] ALB security group (ports 80, 443)
  - [x] ECS security group (from ALB only)
  - [x] RDS security group (from ECS only, port 3306)
  - [x] EC2 security group (SSH, HTTP, HTTPS)
  - [x] Security groups deployed and tested ✅

- [x] **Stage 3: IAM Roles** - COMPLETE ✅
  - [x] IAM module created
  - [x] ECS task execution role (for pulling images, CloudWatch logs)
  - [x] ECS task role (for Secrets Manager access)
  - [x] EC2 instance role (for CloudWatch agent)
  - [x] IAM policies attached
  - [x] IAM roles deployed and tested ✅

- [x] **Stage 4: Secrets Manager** - COMPLETE ✅
  - [x] Secrets module created
  - [x] Secret for RDS credentials (non-rotating)
  - [x] Secret value with username, password, endpoint
  - [x] Secrets deployed and tested ✅

- [x] **Stage 5: RDS** - COMPLETE ✅
  - [x] RDS module created
  - [x] MySQL 8.0 instance (db.t3.micro - free tier)
  - [x] DB subnet group (private subnets)
  - [x] Security group attachment
  - [x] Automated backups (1 day - free tier limit)
  - [x] Custom user/password (non-rotating)
  - [x] RDS deployed and tested ✅

- [x] **Stage 6: ECS Cluster** - COMPLETE ✅
  - [x] ECS cluster module created
  - [x] Container Insights enabled
  - [x] ECS cluster deployed and tested ✅

- [x] **Stage 8: ALB for ECS** - COMPLETE ✅
  - [x] ALB module created
  - [x] Application Load Balancer in public subnets
  - [x] Target groups (WordPress, Microservice)
  - [x] HTTPS listener (conditional - creates when certificate added)
  - [x] HTTP to HTTPS redirect
  - [x] Host-based routing rules
  - [x] ALB deployed and tested ✅
  - [ ] ACM certificate can be added later (manual step)

- [x] **Stage 9: ECR Repository** - COMPLETE ✅
  - [x] ECR module created
  - [x] Repository for microservice
  - [x] Lifecycle policy (keep last 5 images)
  - [x] Image scanning enabled
  - [x] ECR deployed and tested ✅

- [x] **Stage 7: ECS Services** - COMPLETE ✅
  - [x] ECS service module created (reusable)
  - [x] WordPress task definition with Secrets Manager integration
  - [x] Microservice task definition
  - [x] ECS services (WordPress, Microservice)
  - [x] Auto scaling (CPU & Memory based)
  - [x] CloudWatch log groups
  - [x] Fixed IAM execution role Secrets Manager permissions
  - [x] WordPress service running and healthy ✅
  - [ ] Microservice waiting for Docker image to be pushed to ECR

### 🔧 Current Issue
- **Subnet Count Mismatch**: Fixed - Changed from 3 AZs to 2 AZs to match 2 subnets

### 📋 Issues Encountered & Fixed
1. **Duplicate Variable Declarations** (Network & Security modules)
   - Problem: Variables declared in both `main.tf` and `variables.tf`
   - Fix: Removed from `main.tf`, kept only in `variables.tf`
   - Lesson: Variables go ONLY in `variables.tf` - ALWAYS check this!

2. **default_tags Syntax Error**
   - Problem: `default_tags` syntax not supported in provider block
   - Fix: Removed `default_tags`, tags applied directly to resources
   - Lesson: Use tags directly on resources, not in provider

3. **Subnet Count Mismatch**
   - Problem: 3 AZs but only 2 subnet CIDRs created
   - Fix: Changed to 2 AZs to match subnet count
   - Lesson: Ensure `count = length(var.azs)` matches available CIDR blocks

4. **IAM Policy Empty Resources Error**
   - Problem: IAM policy requires Resource field, but secrets_manager_arns is empty initially
   - Fix: Made policy conditional with `count` - only create if ARNs exist
   - Lesson: IAM policies must have Resource field - use conditional creation for optional policies

5. **RDS CloudWatch Logs Export Error**
   - Problem: Used "slow_query" but AWS expects "slowquery" (no underscore)
   - Fix: Changed to "slowquery" in enabled_cloudwatch_logs_exports
   - Lesson: Always check exact AWS API values - underscores vs no underscores matter

6. **RDS Backup Retention Free Tier Limit**
   - Problem: Free tier allows max 1 day backup retention, but we set 7 days
   - Fix: Changed to 1 day for free tier compatibility
   - Lesson: Free tier has limitations - backup retention max is 1 day, not 7

7. **RDS Invalid Password Error**
   - Problem: Password doesn't meet RDS requirements or is empty
   - Requirements: 8-41 chars, uppercase, lowercase, number, special char (no /, ", ', \, @, spaces)
   - Fix: 
     * Make sure you're editing `terraform.tfvars` (not terraform.tfvars.example)
     * Use password like "MySecurePass123!" that meets all requirements
     * Added validation to variables.tf to catch issues early
   - Lesson: RDS has strict password validation - always set password in terraform.tfvars file

8. **ALB Target Group Name Too Long**
   - Problem: Target group names exceed 32 character limit (AWS restriction)
   - Fix: Used `substr()` to shorten project name to 10 chars: "cloudzenia-" becomes "cloudzenia"
   - Lesson: AWS target group names max 32 chars - use abbreviations or truncate with substr()

9. **ALB HTTPS Listener Certificate Required**
   - Problem: HTTPS listener requires certificate ARN, but certificate not created yet
   - Fix: Made HTTPS listener conditional - only creates if certificate_arn is provided
   - Lesson: Can create ALB first, then add HTTPS listener after certificate is ready
   - Next Step: Create ACM certificate in AWS Console, validate via FreeDNS, then add ARN to terraform.tfvars

10. **ECS Task Definition Environment Variables Format Error**
    - Problem: ECS expects `environment` as array of `{name, value}` objects, but we passed a map
    - Error: "cannot unmarshal object into Go struct field ContainerDefinition.Environment of type []types.KeyValuePair"
    - Fix: Converted map to array using `for` expression: `[for key, value in var.environment_variables : {name = key, value = value}]`
    - Lesson: ECS task definitions require specific JSON structure - environment must be array, not map

11. **ECS Service Launch Type and Capacity Provider Conflict**
    - Problem: Cannot specify both `launch_type` and `capacity_provider_strategy` in ECS service
    - Error: "Specifying both a launch type and capacity provider strategy is not supported"
    - Fix: Removed `capacity_provider_strategy` block - auto scaling works with `launch_type = "FARGATE"` via Application Auto Scaling resources
    - Lesson: For Fargate, use `launch_type` and handle auto scaling with `aws_appautoscaling_target`/`aws_appautoscaling_policy`, not capacity provider strategy

12. **ALB Target Group Target Type Mismatch**
    - Problem: Target groups created with default `target_type = "instance"` (for EC2), but ECS Fargate with `awsvpc` requires `target_type = "ip"`
    - Error: "target type instance, which is incompatible with the awsvpc network mode"
    - Fix: Added `target_type = "ip"` to both WordPress and Microservice target groups in ALB module
    - Lesson: ECS Fargate with awsvpc network mode requires IP-based target groups, not instance-based
    - Note: Terraform will recreate the target groups (brief interruption expected)

13. **Target Groups Not Attached to Load Balancer**
    - Problem: Target groups exist but aren't attached to any listener (HTTPS listener is conditional, HTTP only redirects)
    - Error: "The target group ... does not have an associated load balancer"
    - Fix: 
      * Simplified to single HTTP listener that always forwards to WordPress (ensures target group attached)
      * Created HTTP listener rules for both WordPress and Microservice (path-based for microservice)
      * Microservice rule uses path condition `/microservice*` to ensure target group is always attached
    - Lesson: Target groups must be attached to ALB listeners before ECS services can use them

14. **ECS Task Execution Role Missing Secrets Manager Permissions**
    - Problem: ECS tasks failing to start - execution role can't pull secrets from Secrets Manager
    - Error: "User: ...ecs-task-execution-role... is not authorized to perform: secretsmanager:GetSecretValue"
    - Fix: Added Secrets Manager permissions to ECS task execution role (not just task role)
    - Lesson: Execution role pulls secrets during container startup, task role is for running containers
    - Note: Both roles need Secrets Manager access, but execution role is critical for startup

15. **EC2 Instance Type Not Free Tier Eligible**
    - Problem: t2.micro instance type not eligible for Free Tier in this account/region
    - Error: "The specified instance type is not eligible for Free Tier"
    - Fix: Changed from t2.micro to t3.micro (free tier eligible, x86_64 compatible)
    - Lesson: Free tier eligibility varies by account and region - check available instance types
    - Note: t3.micro is also free tier eligible and works with Amazon Linux 2023

---

## Remaining Stages

### Stage 2: Security Groups ✅
- [x] Create security module
- [x] ALB security group (ports 80, 443)
- [x] ECS security group (from ALB only)
- [x] RDS security group (from ECS only, port 3306)
- [x] EC2 security group (SSH, HTTP, HTTPS)
- [x] Tested and deployed ✅

### Stage 3: IAM Roles ✅
- [x] Create IAM module
- [x] ECS task execution role
- [x] ECS task role (Secrets Manager access)
- [x] EC2 instance role (CloudWatch access)
- [x] IAM policies attached
- [ ] Ready to test

### Stage 4: Secrets Manager ✅
- [x] Create secret for RDS credentials
- [x] Store username, password, endpoint (placeholder for now)
- [ ] Ready to test

### Stage 5: RDS ✅
- [x] MySQL instance (db.t3.micro)
- [x] Subnet group (private subnets)
- [x] Security group attachment
- [x] Automated backups (7 days)
- [x] Custom user/password (non-rotating)
- [ ] Ready to test

### Stage 6: ECS Cluster ✅
- [x] ECS cluster creation
- [x] Cluster configuration (Container Insights enabled)
- [ ] Ready to test

### Stage 7: ECS Services ✅
- [x] WordPress task definition
- [x] Microservice task definition
- [x] ECS services
- [x] Auto scaling (CPU & Memory)
- [x] Secrets Manager integration
- [ ] Ready to test

### Stage 8: ALB for ECS ✅
- [x] Application Load Balancer
- [x] Target groups (WordPress, Microservice)
- [x] HTTPS listener (port 443)
- [x] HTTP to HTTPS redirect
- [x] Host-based routing rules
- [ ] ACM certificate attachment (manual - need to create in AWS Console first)

### Stage 9: ECR Repository ✅
- [x] ECR repository for microservice
- [x] Lifecycle policies (keep last 5 images)
- [x] Image scanning enabled
- [ ] Ready to test

### Stage 10: EC2 Stack ⏳
- [ ] 2 EC2 instances (t2.micro)
- [ ] Elastic IPs
- [ ] Security group attachment
- [ ] IAM role attachment

### Stage 11: ALB for EC2 ⏳
- [ ] Second ALB for EC2 instances
- [ ] Target groups
- [ ] HTTPS listener
- [ ] HTTP redirect
- [ ] Host-based routing

### Stage 12: CloudWatch ⏳
- [ ] Log groups for NGINX
- [ ] IAM policies for CloudWatch agent
- [ ] Metric configuration

### Stage 13: GitHub Actions ✅
- [x] IAM role for GitHub Actions OIDC
- [x] OIDC provider for GitHub
- [x] IAM policy for ECR push and ECS deploy
- [x] Terraform variables and outputs
- [x] Setup guide created (GITHUB_ACTIONS_SETUP.md)
- [x] Workflow file ready (.github/workflows/deploy-microservice.yml)
- [ ] GitHub Secrets configuration (manual step - see GITHUB_ACTIONS_SETUP.md)
- [ ] Workflow testing (after secrets configured)

### Stage 14: Testing & Validation ⏳
- [ ] Test all endpoints
- [ ] Verify HTTPS redirects
- [ ] Check auto scaling
- [ ] Verify CloudWatch logs/metrics

### Stage 15: Documentation ⏳
- [ ] Update SUBMISSION_DOCUMENT.md with endpoints
- [ ] Final review

---

## Quick Reference

### File Structure
```
terraform/
├── main.tf              # Main configuration (calls modules)
├── variables.tf          # Root variables
├── providers.tf         # AWS provider
├── versions.tf          # Terraform version
├── outputs.tf           # Root outputs
├── terraform.tfvars     # Your values (create from example)
└── modules/
    ├── network/         ✅ DONE
    ├── security/        ⏳ NEXT
    ├── iam/             ⏳
    ├── secrets/         ⏳
    ├── rds/             ⏳
    ├── ecs-cluster/     ⏳
    ├── ecs-service/     ⏳
    ├── alb/             ⏳
    ├── ec2-stack/       ⏳
    └── cloudwatch/      ⏳
```

### Best Practices Learned
1. Variables ONLY in `variables.tf`
2. Resources in `main.tf`
3. Outputs in `outputs.tf`
4. Match `count` with available resources
5. Test incrementally after each stage

---

**Last Updated**: Stage 7 - ECS Services (ready to test)

