# GitHub Actions Testing Guide

## Prerequisites

1. ✅ Terraform infrastructure deployed
2. ✅ GitHub Actions IAM role created (`terraform apply`)
3. ✅ GitHub repository created and code pushed

## Step 1: Get Required Values

Run these commands in the `terraform` directory:

```bash
cd terraform

# Get GitHub Actions role ARN
terraform output github_actions_role_arn

# Get ECR repository URL (extract repository name from this)
terraform output ecr_repository_url
# Example output: 785825525397.dkr.ecr.ap-south-1.amazonaws.com/cloudzenia-hands-on-prod-microservice
# Repository name: cloudzenia-hands-on-prod-microservice

# Get ECS cluster name
terraform output ecs_cluster_name
# Example output: cloudzenia-hands-on-prod-cluster
```

## Step 2: Configure GitHub Secrets

Go to your GitHub repository:
1. **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**

Add these 3 secrets:

### Secret 1: AWS_ROLE_TO_ASSUME
- **Name**: `AWS_ROLE_TO_ASSUME`
- **Value**: From `terraform output github_actions_role_arn`
- Example: `arn:aws:iam::785825525397:role/cloudzenia-hands-on-prod-github-actions-role`

### Secret 2: ECR_REPOSITORY
- **Name**: `ECR_REPOSITORY`
- **Value**: Just the repository name (not the full URL)
- Example: `cloudzenia-hands-on-prod-microservice`
- **How to get**: From `terraform output ecr_repository_url`, take the part after the last `/`

### Secret 3: ECS_CLUSTER_NAME
- **Name**: `ECS_CLUSTER_NAME`
- **Value**: From `terraform output ecs_cluster_name`
- Example: `cloudzenia-hands-on-prod-cluster`

## Step 3: Verify Terraform Variables

Make sure `terraform.tfvars` has:

```hcl
github_actions_enabled = true
github_repository_subject = "repo:YOUR_USERNAME/YOUR_REPO_NAME:*"
```

Replace:
- `YOUR_USERNAME`: Your GitHub username
- `YOUR_REPO_NAME`: Your repository name

Then run:
```bash
cd terraform
terraform apply
```

## Step 4: Test the Workflow

### Option A: Trigger via Code Change

1. Make a small change to the microservice:
   ```bash
   # Edit services/microservice/src/index.js
   # Change the message or add a comment
   ```

2. Commit and push:
   ```bash
   git add services/microservice/src/index.js
   git commit -m "Test GitHub Actions deployment"
   git push origin main
   ```

### Option B: Manual Trigger

1. Go to GitHub → **Actions** tab
2. Select **Deploy Microservice** workflow
3. Click **Run workflow** → **Run workflow**

## Step 5: Monitor the Workflow

1. Go to **Actions** tab in GitHub
2. Click on the running workflow
3. Watch each step:
   - ✅ Checkout
   - ✅ Configure AWS credentials
   - ✅ Login to Amazon ECR
   - ✅ Build and push image
   - ✅ Render task definition
   - ✅ Deploy ECS service

## Step 6: Verify Deployment

### Check ECR for New Image

```bash
aws ecr describe-images \
  --repository-name cloudzenia-hands-on-prod-microservice \
  --region ap-south-1 \
  --query 'imageDetails[*].[imageTags[0], imagePushedAt]' \
  --output table
```

You should see the new image with the commit SHA as the tag.

### Check ECS Service

```bash
aws ecs describe-services \
  --cluster cloudzenia-hands-on-prod-cluster \
  --services cloudzenia-hands-on-prod-microservice \
  --region ap-south-1 \
  --query 'services[0].[serviceName, runningCount, desiredCount, deployments[0].status]' \
  --output table
```

### Test the Endpoint

```bash
# Get ALB DNS name
terraform output alb_dns_name

# Test microservice endpoint
curl http://YOUR_ALB_DNS_NAME/microservice
```

Expected response:
```json
{
  "message": "Hello from Microservice",
  "timestamp": "2025-11-30T...",
  "hostname": "..."
}
```

## Troubleshooting

### Workflow fails with "AccessDenied"
- ✅ Check `AWS_ROLE_TO_ASSUME` secret is correct
- ✅ Verify IAM role trust policy includes your GitHub repo
- ✅ Check `github_repository_subject` in `terraform.tfvars` matches your repo

### ECR push fails
- ✅ Check `ECR_REPOSITORY` secret contains only repository name (not full URL)
- ✅ Verify IAM role has ECR permissions
- ✅ Check repository exists: `aws ecr describe-repositories --region ap-south-1`

### ECS deployment fails
- ✅ Check `ECS_CLUSTER_NAME` secret matches actual cluster name
- ✅ Verify service name is correct: `cloudzenia-hands-on-prod-microservice`
- ✅ Check IAM role can pass ECS task execution role
- ✅ Verify task definition JSON has correct role ARNs

### "OIDC provider not found"
- ✅ Run `terraform apply` to create the OIDC provider
- ✅ Wait 2-3 minutes after creating OIDC provider before testing

### Task definition render fails
- ✅ Check `ecs-task-definitions/microservice.json` has correct:
  - `executionRoleArn`
  - `taskRoleArn`
  - `logConfiguration.awslogs-group`

### Service deployment times out
- ✅ Check ECS service logs in CloudWatch
- ✅ Verify target group health checks are passing
- ✅ Check security groups allow traffic from ALB

## Expected Workflow Duration

- Build and push: ~2-3 minutes
- Deploy to ECS: ~3-5 minutes
- **Total**: ~5-8 minutes

## Next Steps

After GitHub Actions is working:
1. ✅ Test automatic deployment
2. ⏳ Set up SSL/TLS certificates (Stage 14)
3. ⏳ Final testing and documentation (Stage 15-16)

