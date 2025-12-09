# Quick Reference Guide

## 📁 What's Included

✅ **AMI/** - Packer configurations for building custom AMIs  
✅ **Ansible/** - Playbooks for server configuration  
✅ **modules/** - Terraform modules (VPC, EC2)  
✅ **Documentation** - Complete guides and references  

## 🎯 Main Goal

**Migrate Terraform code to Terraform Cloud with VCS workflow**

## ⚡ Quick Start (15 minutes)

```bash
# 1. Push to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/terraform-cloud.git
git push -u origin main

# 2. Create Terraform Cloud account
# Visit: https://app.terraform.io/signup/account

# 3. Create workspace (VCS-driven)
# Connect to GitHub repository

# 4. Configure AWS credentials in workspace
# AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

# 5. Test automatic trigger
echo "# Test" >> main.tf
git add . && git commit -m "Test" && git push

# Done! ✅
```

## 📋 Optional: Use Packer & Ansible

### Build Custom AMI
```bash
cd AMI
packer init .
packer build ubuntu-nginx.pkr.hcl
# Note the AMI ID
```

### Configure Servers
```bash
cd Ansible
# Update inventory.ini with IPs
ansible-playbook webserver.yml
```

## 🌳 Multi-Environment Setup

```bash
# Create branches
git checkout -b dev && git push origin dev
git checkout -b test && git push origin test
git checkout main

# Create 3 workspaces in Terraform Cloud:
# - terraform-cloud-dev (branch: dev, auto-apply: ON)
# - terraform-cloud-test (branch: test, auto-apply: OFF)
# - terraform-cloud-prod (branch: main, auto-apply: OFF)
```

## 🔔 Notifications

In each workspace:
- Settings → Notifications
- Add Email: your-email@example.com
- Events: Run errored, Run needs attention

## 📚 Documentation Files

| File | Purpose | Time |
|------|---------|------|
| **ACTUAL_PROJECT_GUIDE.md** | Main guide | 15 min |
| **COMPLETE_SETUP_GUIDE.md** | With Packer/Ansible | 30 min |
| **QUICK_REFERENCE.md** | This file | 2 min |

## ✅ Success Checklist

- [ ] Code pushed to GitHub
- [ ] Terraform Cloud account created
- [ ] Workspace connected (VCS workflow)
- [ ] AWS credentials configured
- [ ] Automatic trigger tested
- [ ] Multi-environment setup (dev/test/prod)
- [ ] Notifications configured
- [ ] Understand the workflow

## 🎯 Key Commands

```bash
# Packer
packer init .
packer validate ubuntu-nginx.pkr.hcl
packer build ubuntu-nginx.pkr.hcl

# Ansible
ansible all -m ping
ansible-playbook webserver.yml

# Terraform
terraform init
terraform plan
terraform apply
terraform destroy

# Git
git add .
git commit -m "message"
git push
```

## 💡 Remember

- Focus on **Terraform Cloud workflow**, not infrastructure
- Use **VCS-driven** workflow (not CLI-driven)
- **Auto-apply** only for dev environment
- Always **review plans** before applying
- **Destroy resources** when done testing

---

**Need detailed instructions?** Read `ACTUAL_PROJECT_GUIDE.md` or `COMPLETE_SETUP_GUIDE.md`
