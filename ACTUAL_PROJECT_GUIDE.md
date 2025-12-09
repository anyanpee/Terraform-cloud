# Terraform Cloud Migration - Actual Project Guide

## 🎯 What This Project Actually Requires

Based on the project instructions, you need to:

1. ✅ Have existing Terraform code (from previous projects)
2. ✅ Create a GitHub repository named `terraform-cloud`
3. ✅ Push your Terraform code to GitHub
4. ✅ Create Terraform Cloud account and organization
5. ✅ Set up VCS-driven workflow (not CLI-driven)
6. ✅ Configure workspaces for dev/test/prod
7. ✅ Set up notifications (Email/Slack)
8. ✅ Test automatic triggers from GitHub

## 📝 Important Note

**You DON'T need to deploy infrastructure immediately!**

The project assumes you already have Terraform code from previous projects that includes:
- ✅ Packer configurations (AMI folder) - **NOW INCLUDED**
- ✅ Ansible playbooks (Ansible folder) - **NOW INCLUDED**
- ✅ Terraform configurations - **NOW INCLUDED**

This project now includes:
- **AMI/** - Packer template for building custom Ubuntu AMI with Nginx
- **Ansible/** - Playbook for configuring web servers
- **modules/** - Terraform modules for VPC and EC2

**Focus on the Terraform Cloud migration workflow, not on building infrastructure!**

## 🚀 Actual Steps to Follow

### Step 1: Prepare Your Repository (5 minutes)

1. **Create GitHub repository**:
   - Go to GitHub
   - Create new repository: `terraform-cloud`
   - Don't initialize with README (you'll push existing code)

2. **Initialize Git locally**:
   ```bash
   cd "c:\Users\DELL\Desktop\Terraform cloud project"
   git init
   git add .
   git commit -m "Initial commit - Terraform configurations"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/terraform-cloud.git
   git push -u origin main
   ```

### Step 2: Create Terraform Cloud Account (5 minutes)

1. Go to: https://app.terraform.io/signup/account
2. Sign up and verify email
3. Click **"Start from scratch"**
4. Create organization (e.g., "my-terraform-org")

### Step 3: Create Workspace with VCS (10 minutes)

**IMPORTANT**: Choose **"Version control workflow"** (NOT CLI-driven)

1. In Terraform Cloud, click **"New Workspace"**
2. Choose **"Version control workflow"**
3. Connect to GitHub:
   - Click "GitHub.com"
   - Authorize Terraform Cloud
   - Select your `terraform-cloud` repository
4. Configure workspace:
   - Name: `terraform-cloud-demo`
   - Description: "Demo workspace for Terraform Cloud migration"
   - Terraform Working Directory: leave blank (or specify if code is in subfolder)
   - VCS branch: `main`
5. Click **"Create workspace"**

### Step 4: Configure Variables (5 minutes)

In your workspace, go to **Variables** tab:

**Environment Variables** (for AWS):
- `AWS_ACCESS_KEY_ID` = your-access-key (mark as **sensitive**)
- `AWS_SECRET_ACCESS_KEY` = your-secret-key (mark as **sensitive**)

**Terraform Variables** (optional):
- `aws_region` = "us-east-1"
- `environment` = "dev"
- `instance_type` = "t2.micro"

### Step 5: Test Automatic Trigger (5 minutes)

1. Make a small change to any `.tf` file locally:
   ```bash
   echo "# Testing automatic trigger" >> main.tf
   ```

2. Commit and push:
   ```bash
   git add .
   git commit -m "Test automatic trigger"
   git push
   ```

3. Go to Terraform Cloud workspace
4. You should see a new run automatically started!
5. Review the plan
6. Click **"Confirm & Apply"** if you want to deploy

### Step 6: Configure Multi-Environment (15 minutes)

**Create branches**:
```bash
# Create dev branch
git checkout -b dev
git push origin dev

# Create test branch
git checkout -b test
git push origin test

# Back to main
git checkout main
```

**Create workspaces for each environment**:

1. **Dev Workspace**:
   - Name: `terraform-cloud-dev`
   - VCS Branch: `dev`
   - Auto Apply: **Enabled** ✅
   - Variables: Set environment = "dev"

2. **Test Workspace**:
   - Name: `terraform-cloud-test`
   - VCS Branch: `test`
   - Auto Apply: **Disabled** ❌
   - Variables: Set environment = "test"

3. **Prod Workspace**:
   - Name: `terraform-cloud-prod`
   - VCS Branch: `main`
   - Auto Apply: **Disabled** ❌
   - Variables: Set environment = "prod"

### Step 7: Configure Notifications (5 minutes)

For each workspace:

1. Go to **Settings** → **Notifications**
2. Click **"Create a Notification"**

**Email Notification**:
- Destination: Email
- Recipients: your-email@example.com
- Events: 
  - ✅ Run errored
  - ✅ Run needs attention
  - ✅ Run completed (optional)

**Slack Notification** (optional):
- Destination: Slack
- Webhook URL: your-slack-webhook
- Events:
  - ✅ Run started
  - ✅ Run completed
  - ✅ Run errored

### Step 8: Test the Complete Workflow (10 minutes)

1. **Test Dev Environment**:
   ```bash
   git checkout dev
   echo "# Dev change" >> variables.tf
   git add .
   git commit -m "Test dev environment"
   git push
   ```
   - Check Terraform Cloud - should auto-apply ✅

2. **Test Test Environment**:
   ```bash
   git checkout test
   echo "# Test change" >> variables.tf
   git add .
   git commit -m "Test test environment"
   git push
   ```
   - Check Terraform Cloud - should require manual approval ⏸️

3. **Test Prod Environment**:
   ```bash
   git checkout main
   echo "# Prod change" >> variables.tf
   git add .
   git commit -m "Test prod environment"
   git push
   ```
   - Check Terraform Cloud - should require manual approval ⏸️

## ✅ Success Criteria

You've completed the project when:

- [x] GitHub repository created and code pushed
- [x] Terraform Cloud account created
- [x] Organization created
- [x] Workspace connected to GitHub (VCS workflow)
- [x] AWS credentials configured
- [x] Automatic triggers working (push → plan)
- [x] Three environments configured (dev/test/prod)
- [x] Notifications configured (email/Slack)
- [x] Tested automatic runs from GitHub
- [x] Understand the workflow

## 🎯 Key Differences from My Initial Setup

| What I Created | What Project Actually Needs |
|----------------|----------------------------|
| CLI-driven workflow | **VCS-driven workflow** ✅ |
| Deploy infrastructure first | **Just migrate existing code** ✅ |
| S3 backend migration | **Direct to Terraform Cloud** ✅ |
| Focus on infrastructure | **Focus on workflow & automation** ✅ |

## 📚 Practice Tasks from Project

### Practice Task #1
- [x] Configure 3 branches (dev, test, prod)
- [x] Trigger runs automatically for dev only
- [x] Create Email and Slack notifications
- [x] Test notifications
- [x] Apply destroy from Terraform Cloud console

### Practice Task #2 (Advanced)
- [ ] Create a simple Terraform module
- [ ] Import module into private registry
- [ ] Create configuration using the module
- [ ] Create workspace for the configuration
- [ ] Deploy and destroy

## 💡 What You Should Actually Do

**If you have existing Terraform code from previous projects**:
1. Copy it to this folder
2. Push to GitHub
3. Follow steps above

**If you DON'T have existing code**:
1. Use the modules I created (they work fine!)
2. Push to GitHub
3. Follow steps above
4. Focus on learning Terraform Cloud features, not infrastructure

## 🎓 The Real Learning Objectives

This project is about:
- ✅ Terraform Cloud features
- ✅ VCS integration
- ✅ Automated workflows
- ✅ Multi-environment management
- ✅ Team collaboration
- ✅ Notifications and monitoring

NOT about:
- ❌ Creating complex infrastructure
- ❌ S3 backend setup
- ❌ CLI-driven workflows

## 🚀 Quick Start (Correct Approach)

```bash
# 1. Push to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/terraform-cloud.git
git push -u origin main

# 2. Create Terraform Cloud account
# Visit: https://app.terraform.io/signup/account

# 3. Create workspace with VCS workflow
# Connect to your GitHub repository

# 4. Configure variables in workspace
# Add AWS credentials

# 5. Test automatic trigger
git commit --allow-empty -m "Test trigger"
git push

# 6. Done! ✅
```

## 📞 Summary

The project wants you to:
1. **Push code to GitHub** ✅
2. **Connect Terraform Cloud to GitHub** ✅
3. **Configure VCS-driven workflow** ✅
4. **Set up multi-environment** ✅
5. **Configure notifications** ✅
6. **Test automatic triggers** ✅

You can use the infrastructure code I created, but the focus should be on **Terraform Cloud features and workflows**, not on deploying infrastructure.

---

**Ready?** Start with Step 1 above! 🚀
