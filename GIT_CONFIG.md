# Git Configuration - Quick Setup

## Set Your Git Identity

Before you can commit, Git needs to know who you are. Run these commands:

### Option 1: Use Your GitHub Email

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Example:**
```powershell
git config --global user.name "Pankaj"
git config --global user.email "pankaj@example.com"
```

### Option 2: Use GitHub's No-Reply Email

If you want to keep your email private:

```powershell
git config --global user.name "Your Name"
git config --global user.email "YOUR_USERNAME@users.noreply.github.com"
```

**Example:**
```powershell
git config --global user.name "Pankaj"
git config --global user.email "pankaj123@users.noreply.github.com"
```

(Replace `pankaj123` with your actual GitHub username)

## Verify Configuration

```powershell
git config --global user.name
git config --global user.email
```

## After Configuration

Once configured, you can commit:

```powershell
cd "C:\Users\Pankaj\OneDrive - Infiniti Research\Downloads\AWS"
git commit -m "Initial commit: AWS Infrastructure as Code assignment"
```

## Next Steps

After committing:
1. Create GitHub repository
2. Add remote: `git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git`
3. Push: `git push -u origin main`

