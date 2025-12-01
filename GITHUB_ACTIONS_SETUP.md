# GitHub Actions Setup Guide

This guide will help you set up GitHub Actions to automatically build, push Docker images to ECR, and deploy to ECS.

## Prerequisites

1. GitHub repository created and code pushed
2. Terraform infrastructure deployed (ECS cluster, ECR repository)
3. AWS account with appropriate permissions

## Step 1: Get Required Values from Terraform

Run these commands to get the values you need:

```bash
cd terraform
terraform output ecr_repository_url
terraform output ecs_cluster_name
terraform output github_actions_role_arn
```

**Expected Output:**
- `ecr_repository_url`: `785825525397.dkr.ecr.ap-south-1.amazonaws.com/cloudzenia-hands-on-prod-microservice`
- `ecs_cluster_name`: `cloudzenia-hands-on-prod-cluster`
- `github_actions_role_arn`: `arn:aws:iam::785825525397:role/cloudzenia-hands-on-prod-github-actions-role`

## Step 2: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

### 1. AWS_ROLE_TO_ASSUME
- **Name**: `AWS_ROLE_TO_ASSUME`
- **Value**: The ARN from `terraform output github_actions_role_arn`
- Example: `arn:aws:iam::785825525397:role/cloudzenia-hands-on-prod-github-actions-role`

### 2. ECR_REPOSITORY
- **Name**: `ECR_REPOSITORY`
- **Value**: Just the repository name (extract from ECR URL)
- Example: `cloudzenia-hands-on-prod-microservice`
- **How to extract**: From `785825525397.dkr.ecr.ap-south-1.amazonaws.com/cloudzenia-hands-on-prod-microservice`, take the part after the last `/`

### 3. ECS_CLUSTER_NAME
- **Name**: `ECS_CLUSTER_NAME`
- **Value**: The cluster name from `terraform output ecs_cluster_name`
- Example: `cloudzenia-hands-on-prod-cluster`

## Step 3: Update Terraform Variables (if needed)

If you haven't enabled GitHub Actions in Terraform yet, update `terraform/main.tf`:

```hcl
module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  secrets_manager_arns = [module.secrets.secret_arn]
  
  # Add these for GitHub Actions
  github_actions_enabled = true
  github_repository_subject = "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:*"
}
```

Replace:
- `YOUR_GITHUB_USERNAME`: Your GitHub username
- `YOUR_REPO_NAME`: Your repository name

Then run:
```bash
cd terraform
terraform apply
```

## Step 4: Test the Workflow

1. Make a small change to `services/microservice/src/index.js`
2. Commit and push to `main` branch:
   ```bash
   git add services/microservice/src/index.js
   git commit -m "Test GitHub Actions deployment"
   git push origin main
   ```
3. Go to GitHub → **Actions** tab
4. Watch the workflow run
5. Check ECS service to verify new task is running

## Step 5: Verify Deployment

1. Check ECR for new image:
   ```bash
   aws ecr describe-images --repository-name cloudzenia-hands-on-prod-microservice --region ap-south-1
   ```

2. Check ECS service:
   ```bash
   aws ecs describe-services --cluster cloudzenia-hands-on-prod-cluster --services cloudzenia-hands-on-prod-microservice --region ap-south-1
   ```

3. Test the endpoint:
   ```bash
   curl http://YOUR_ALB_DNS_NAME/microservice
   ```

## Troubleshooting

### Workflow fails with "AccessDenied"
- Check that `AWS_ROLE_TO_ASSUME` secret is correct
- Verify the IAM role has the correct trust policy for your GitHub repo

### ECR push fails
- Check that `ECR_REPOSITORY` secret contains only the repository name (not the full URL)
- Verify the IAM role has ECR permissions

### ECS deployment fails
- Check that `ECS_CLUSTER_NAME` secret matches the actual cluster name
- Verify the IAM role has ECS permissions and can pass the ECS task execution role

### "OIDC provider not found"
- Run `terraform apply` to create the OIDC provider
- Wait a few minutes after creating the OIDC provider before testing

## Workflow File Location

The workflow file is at: `.github/workflows/deploy-microservice.yml`

It triggers on:
- Push to `main` branch when `services/microservice/**` files change
- Manual trigger via `workflow_dispatch`

## Next Steps

After GitHub Actions is working:
1. ✅ Test automatic deployment
2. ⏳ Set up SSL/TLS certificates (Stage 14)
3. ⏳ Final testing and documentation (Stage 15-16)

