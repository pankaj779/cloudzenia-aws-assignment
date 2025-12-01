# GitHub Repository Setup Guide

## Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and make sure you're logged in
2. Click the **+** icon in the top right → **New repository**
3. Fill in the details:
   - **Repository name**: `cloudzenia-aws-assignment` (or any name you prefer)
   - **Description**: `AWS Infrastructure as Code assignment using Terraform - ECS, RDS, EC2, ALB`
   - **Visibility**: Select **Public** (so recruiters can access it)
   - **DO NOT** check:
     - ❌ Add a README file
     - ❌ Add .gitignore
     - ❌ Choose a license
   - (We already have these files)
4. Click **Create repository**

## Step 2: Install Git (if not installed)

If you got "git is not recognized" error, install Git:

1. Download from: https://git-scm.com/download/win
2. Install with default settings
3. Restart your terminal/PowerShell

## Step 3: Initialize Git and Push Code

Open PowerShell in your project directory and run these commands:

### 3.1: Initialize Git (if not already done)
```powershell
cd "C:\Users\Pankaj\OneDrive - Infiniti Research\Downloads\AWS"
git init
```

### 3.2: Add all files
```powershell
git add .
```

### 3.3: Make your first commit
```powershell
git commit -m "Initial commit: AWS Infrastructure as Code assignment

- Terraform modules for ECS, RDS, EC2, ALB
- GitHub Actions workflow for CI/CD
- Microservice Node.js application
- Complete infrastructure setup"
```

### 3.4: Add remote repository
Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` with your actual GitHub username and repo name:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

Example:
```powershell
git remote add origin https://github.com/pankaj123/cloudzenia-aws-assignment.git
```

### 3.5: Rename branch to main (if needed)
```powershell
git branch -M main
```

### 3.6: Push to GitHub
```powershell
git push -u origin main
```

You'll be prompted for your GitHub username and password (use a Personal Access Token, not your password).

## Step 4: Create Personal Access Token (if needed)

If GitHub asks for authentication:

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Give it a name: `AWS Assignment Push`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
5. Click **Generate token**
6. **Copy the token immediately** (you won't see it again!)
7. Use this token as your password when pushing

## Step 5: Verify Upload

1. Go to your GitHub repository page
2. You should see all your files:
   - `terraform/` directory
   - `services/` directory
   - `.github/workflows/` directory
   - All documentation files
3. Check that `.gitignore` is working (you should NOT see `terraform.tfstate` or `terraform.tfvars`)

## Step 6: Update GitHub Actions Workflow (if needed)

After pushing, check that the workflow file is in:
`.github/workflows/deploy-microservice.yml`

## What Gets Pushed

✅ **Will be pushed:**
- All Terraform code (`terraform/` directory)
- Microservice code (`services/` directory)
- GitHub Actions workflow (`.github/` directory)
- Documentation files (`.md` files)
- Configuration files (`.json`, `.tfvars.example`)

❌ **Will NOT be pushed** (thanks to `.gitignore`):
- `terraform.tfstate` (contains sensitive state)
- `terraform.tfstate.backup`
- `terraform.tfvars` (contains passwords)
- Any `.pem` or `.key` files

## Next Steps After Pushing

1. ✅ Repository created and code pushed
2. ⏳ Configure GitHub Secrets (see `GITHUB_ACTIONS_TESTING.md`)
3. ⏳ Test GitHub Actions workflow
4. ⏳ Set up SSL/TLS certificates

## Troubleshooting

### "git is not recognized"
- Install Git from https://git-scm.com/download/win
- Restart PowerShell after installation

### "Authentication failed"
- Use Personal Access Token instead of password
- Make sure token has `repo` scope

### "Remote origin already exists"
```powershell
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

### "Permission denied"
- Check your GitHub username is correct
- Use Personal Access Token, not password
- Make sure repository is public or you have access

### Files not showing in GitHub
- Make sure you ran `git add .`
- Check `.gitignore` isn't excluding them
- Verify you committed: `git status`

