# Terraform Cloud Migration Project

This project demonstrates migrating Terraform infrastructure code to Terraform Cloud with VCS (Version Control System) workflow integration using GitHub.

## 📁 Project Overview

### What's Included:
- ✅ **Terraform Modules** - VPC and EC2 infrastructure modules
- ✅ **Packer Configurations** - Custom AMI building templates
- ✅ **Ansible Playbooks** - Server configuration automation
- ✅ **Multi-Environment Setup** - Dev, Test, and Production workspaces
- ✅ **VCS Integration** - GitHub automatic triggers
- ✅ **Notifications** - Email alerts for run status

### Project Objectives:
1. Push Terraform code to GitHub
2. Connect Terraform Cloud to GitHub (VCS workflow)
3. Create multi-environment workspaces (Dev, Test, Prod)
4. Configure AWS credentials and variables
5. Set up automatic triggers
6. Configure email notifications

---

## 📂 Project Structure

```
Terraform-cloud/
├── AMI/                          # Packer configurations
│   ├── ubuntu-nginx.pkr.hcl     # Packer template for Ubuntu AMI
│   ├── variables.pkr.hcl        # Packer variables
│   └── README.md
│
├── Ansible/                      # Ansible playbooks
│   ├── webserver.yml            # Web server configuration
│   ├── inventory.ini            # Server inventory
│   ├── ansible.cfg              # Ansible configuration
│   └── README.md
│
├── modules/                      # Terraform modules
│   ├── vpc/                     # VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/                     # EC2 module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── main.tf                       # Root module configuration
├── variables.tf                  # Variable definitions
├── outputs.tf                    # Output definitions
├── terraform.tfvars              # Variable values
├── screenshots/                  # Project screenshots
└── README.md                     # This file
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Push Code to GitHub

#### 1.1 Initialize Git Repository

```bash
cd "c:\Users\DELL\Desktop\Terraform cloud project"
git init
git add .
git commit -m "Initial commit: Terraform modules with Packer and Ansible configurations"
git branch -M main
```

#### 1.2 Push to GitHub Repository

```bash
git remote add origin https://github.com/anyanpee/Terraform-cloud.git
git push -u origin main
```

#### 1.3 Create Environment Branches

```bash
# Create dev branch
git checkout -b dev
git push origin dev

# Create test branch
git checkout -b test
git push origin test

# Switch back to main
git checkout main
```

**Result:** Code successfully pushed to GitHub with 3 branches (main, dev, test)

---

### Step 2: Create Terraform Cloud Account

1. Go to: **https://app.terraform.io/signup/account**
2. Sign up with your email
3. Verify your email
4. Click **"Start from scratch"**
5. Create organization: **peter-terraform-org**

---

### Step 3: Create Production Workspace

#### 3.1 Create Workspace

1. In Terraform Cloud, click **"New Workspace"**
2. Choose **"Version control workflow"** (NOT CLI-driven)
3. Click **"GitHub.com"**
4. Authorize Terraform Cloud to access GitHub
5. Select repository: **anyanpee/Terraform-cloud**
6. Configure workspace:
   - **Workspace Name:** `Terraform-cloud`
   - **Description:** Production environment
   - **VCS Branch:** `main`
   - **Project:** Default Project
7. Click **"Create workspace"**

![Workspace Created in Terraform Account]
![](<workspace created in terraform account screenshot-1.PNG>)

### Step 4: Configure AWS Credentials

#### 4.1 Add Environment Variables

1. Go to **Variables** tab in your workspace
2. Click **"+ Add variable"**

**Add AWS Access Key:**
- Select **"Environment variable"**
- Key: `AWS_ACCESS_KEY_ID`
- Value: `<your-aws-access-key>`
- ✅ Check **"Sensitive"**
- Click **"Add variable"**

**Add AWS Secret Key:**
- Click **"+ Add variable"**
- Select **"Environment variable"**
- Key: `AWS_SECRET_ACCESS_KEY`
- Value: `<your-aws-secret-key>`
- ✅ Check **"Sensitive"**
- Click **"Add variable"**

![Adding Access Key and Secret Access Key]
![](<adding access key and secret access key variable screenshot.PNG>)

#### 4.2 Add Terraform Variables (Optional)

- `environment` = `prod`
- `vpc_cidr` = `10.2.0.0/16`

---

### Step 5: Create Dev Environment Workspace

#### 5.1 Create Dev Workspace

1. Click **"New Workspace"**
2. Choose **"Version control workflow"**
3. Select **GitHub.com**
4. Choose repository: **anyanpee/Terraform-cloud**
5. Configure:
   - **Workspace Name:** `Terraform-cloud-dev`
   - **Description:** Development environment
   - **VCS Branch:** `dev`
   - **Project:** Default Project
6. Click **"Create workspace"**

#### 5.2 Configure Dev Variables

**Environment Variables:**
- `AWS_ACCESS_KEY_ID` (sensitive, env)
- `AWS_SECRET_ACCESS_KEY` (sensitive, env)

**Terraform Variables:**
- `environment` = `dev`
- `vpc_cidr` = `10.0.0.0/16`

![Terraform Dev Environment Workplace Variables]
![](<terraform dev environment workplace variable screenshot.PNG>)

#### 5.3 Enable Auto-Apply for Dev

1. Go to **Settings** → **General**
2. Scroll to **"Apply Method"**
3. Select **"Auto apply"**
4. Check both boxes:
   - ✅ Auto-apply API, UI, & VCS runs
   - ✅ Auto-apply run trigger
5. Click **"Save settings"**

---

### Step 6: Create Test Environment Workspace

#### 6.1 Create Test Workspace

1. Click **"New Workspace"**
2. Choose **"Version control workflow"**
3. Select **GitHub.com**
4. Choose repository: **anyanpee/Terraform-cloud**
5. Configure:
   - **Workspace Name:** `Terraform-cloud-test`
   - **Description:** Test environment
   - **VCS Branch:** `test`
   - **Project:** Default Project
6. Click **"Create workspace"**

#### 6.2 Configure Test Variables

**Environment Variables:**
- `AWS_ACCESS_KEY_ID` (sensitive, env)
- `AWS_SECRET_ACCESS_KEY` (sensitive, env)

**Terraform Variables:**
- `environment` = `test`
- `vpc_cidr` = `10.1.0.0/16`

![Terraform Cloud Test Environment Variables]
![](<terraform cloud test env variable screen shot.PNG>)

**Note:** Keep Auto-apply **disabled** for Test environment (manual approval required)

---

### Step 7: Verify All Workspaces

![All Workspace (Dev, Test, Prod)]
![](<All workspace (dev,test,prod) screenshot.PNG>)

**Workspace Summary:**

| Workspace | Branch | Auto-Apply | VPC CIDR |
|-----------|--------|------------|----------|
| Terraform-cloud (Prod) | main | ❌ No | 10.2.0.0/16 |
| Terraform-cloud-dev | dev | ✅ Yes | 10.0.0.0/16 |
| Terraform-cloud-test | test | ❌ No | 10.1.0.0/16 |

---

### Step 8: Configure Email Notifications

#### 8.1 Set Up Email Notifications for Dev

1. Go to **Terraform-cloud-dev** workspace
2. Click **Settings** → **Notifications**
3. Click **"Create a Notification"**
4. Configure:
   - **Destination:** Email
   - **Name:** Dev Email Notifications
   - **Recipients:** your-email@example.com
   - **Triggers:**
     - ✅ Run errored
     - ✅ Run needs attention
     - ✅ Run completed
5. Click **"Create notification"**

![Email Notification for Dev Environment]
![](<Email notification for dev env screenshot.PNG>)

#### 8.2 Verify Email Notification

Check your email for verification message from Terraform Cloud.

![Email Notification Verification]
![](<Email notification verification screenshot.PNG>)

#### 8.3 Repeat for Other Workspaces

Configure email notifications for:
- **Terraform-cloud-test** workspace
- **Terraform-cloud** (prod) workspace

---

### Step 9: Test Automatic Triggers

#### 9.1 Remove Conflicting Backend File

```bash
git rm backend-setup.tf
git commit -m "Remove backend-setup.tf - using Terraform Cloud backend"
git push
```

**Why?** The `backend-setup.tf` file caused duplicate provider configuration errors.

#### 9.2 Test Dev Environment (Auto-Apply)

```bash
# Switch to dev branch
git checkout dev

# Make a change
echo "# Testing dev environment" >> README.md

# Commit and push
git add .
git commit -m "Test dev environment automatic trigger"
git push
```

**Expected Result:** 
- Terraform Cloud automatically detects the push
- Run starts automatically
- Plan executes
- Apply runs automatically (auto-apply enabled)

#### 9.3 Test Test Environment (Manual Approval)

```bash
# Switch to test branch
git checkout test

# Make a change
echo "# Testing test environment" >> README.md

# Commit and push
git add .
git commit -m "Test test environment trigger"
git push
```

**Expected Result:**
- Terraform Cloud detects the push
- Run starts automatically
- Plan executes
- Waits for manual approval (auto-apply disabled)

---

## 🔧 Troubleshooting

### Issue: Run Stuck in "Waiting for resources"

![Terraform Plan Refuse to Run](screenshots/terraform-plan-refuse-to-run.png)
![](<terraform-plan-refuse-to-run.png>)
*Screenshot: Terraform plan stuck in queue showing pending status*

**Cause:** Terraform Cloud free tier has limited concurrent run capacity (1 run at a time)

I wanted for long and apply refuse to go throught after trying a couple of times it just kept staying in pending state, just like it is in the screenshot above

### Issue: Duplicate Provider Configuration Error

**Error Message:**
```
Error: Duplicate required providers configuration
Error: Duplicate provider configuration
```

**Solution:** Remove `backend-setup.tf` file:
```bash
git rm backend-setup.tf
git commit -m "Remove backend-setup.tf - using Terraform Cloud backend"
git push
```

### Issue: AWS Credentials Not Working

**Solution:** Ensure both credentials are:
- Set as **Environment variables** (not Terraform variables)
- Marked as **Sensitive**
- Category shows "env" not "terraform"


## ✅ Project Completion Checklist

### GitHub Integration
- [x] Code pushed to GitHub repository
- [x] Three branches created (main, dev, test)
- [x] Repository connected to Terraform Cloud

### Terraform Cloud Setup
- [x] Account created and verified
- [x] Organization created (peter-terraform-org)
- [x] VCS workflow configured

### Workspaces
- [x] Production workspace created (main branch)
- [x] Dev workspace created (dev branch, auto-apply enabled)
- [x] Test workspace created (test branch, manual approval)
- [x] AWS credentials configured in all workspaces
- [x] Terraform variables configured for each environment

### Automation
- [x] Automatic triggers tested
- [x] VCS integration verified
- [x] Auto-apply working for dev environment
- [x] Manual approval working for test/prod

### Notifications
- [x] Email notifications configured
- [x] Notification verification completed

---

## 📊 Infrastructure Components

### What Gets Created (When Applied):

**VPC Module:**
- 1 VPC (CIDR varies by environment)
- 2 Public Subnets across 2 Availability Zones
- 1 Internet Gateway
- 1 Route Table with routes
- Route table associations

**EC2 Module:**
- 2 EC2 instances (t2.micro)
- 1 Security Group (ports 22, 80, 443)
- Ubuntu 22.04 AMI
- Nginx web server (via user data)

**Estimated Cost:** ~$18-20/month (if deployed)


## 📚 Additional Resources

### Packer (AMI Building)
```bash
cd AMI
packer init .
packer validate ubuntu-nginx.pkr.hcl
packer build ubuntu-nginx.pkr.hcl
```

### Ansible (Server Configuration)
```bash
cd Ansible
ansible-playbook -i inventory.ini webserver.yml
```

### Terraform Commands
```bash
terraform fmt       # Format code
terraform validate  # Validate configuration
terraform plan      # Plan changes
terraform apply     # Apply changes
terraform destroy   # Destroy resources
```

---

## 🎯 Conclusion

This project successfully demonstrates:
- ✅ Migration of Terraform infrastructure code to Terraform Cloud
- ✅ Implementation of VCS-driven workflow with GitHub
- ✅ Multi-environment workspace management (Dev, Test, Prod)
- ✅ Automated infrastructure deployment workflows
- ✅ Notification and monitoring setup

The setup provides a production-ready foundation for managing infrastructure as code with:
- Team collaboration capabilities
- Automated workflows
- Proper environment separation
- Security best practices

---

## 👥 Project Information

**Author:** Peter Anyankpele  
**GitHub:** [@anyanpee](https://github.com/anyanpee)  
**Repository:** [Terraform-cloud](https://github.com/anyanpee/Terraform-cloud)  
**Organization:** peter-terraform-org  
**Date:** December 2025  
**Status:** ✅ Complete

---

## 📝 License

This project is for educational purposes.