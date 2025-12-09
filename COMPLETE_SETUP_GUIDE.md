# Complete Terraform Cloud Project Setup

## 📁 Project Structure

```
Terraform Cloud Project/
├── AMI/                          # Packer configurations
│   ├── ubuntu-nginx.pkr.hcl     # Packer template
│   ├── variables.pkr.hcl        # Packer variables
│   └── README.md
│
├── Ansible/                      # Ansible playbooks
│   ├── webserver.yml            # Web server playbook
│   ├── inventory.ini            # Inventory file
│   ├── ansible.cfg              # Ansible config
│   └── README.md
│
├── modules/                      # Terraform modules
│   ├── vpc/                     # VPC module
│   └── ec2/                     # EC2 module
│
├── main.tf                       # Main Terraform config
├── variables.tf                  # Variables
├── outputs.tf                    # Outputs
├── terraform.tfvars              # Your values
└── Documentation files...
```

## 🎯 Complete Workflow

```
1. Build AMI with Packer
   ↓
2. Configure with Ansible
   ↓
3. Deploy with Terraform
   ↓
4. Push to GitHub
   ↓
5. Migrate to Terraform Cloud
   ↓
6. Automate with VCS workflow
```

## 🚀 Step-by-Step Guide

### Phase 1: Build Custom AMI (Optional)

#### Prerequisites
```bash
# Install Packer
# Windows: choco install packer
# Mac: brew install packer
# Linux: Download from https://www.packer.io/downloads

# Install Ansible
# Windows: pip install ansible
# Mac: brew install ansible
# Linux: sudo apt install ansible
```

#### Build AMI
```bash
cd AMI

# Initialize Packer
packer init .

# Validate template
packer validate ubuntu-nginx.pkr.hcl

# Build AMI (takes 5-10 minutes)
packer build ubuntu-nginx.pkr.hcl

# Note the AMI ID from output
# Example: AMI: ami-0123456789abcdef0
```

#### Update Terraform to Use Custom AMI
```bash
# Edit terraform.tfvars
custom_ami_name = "ubuntu-nginx-*"  # Pattern from Packer build
```

### Phase 2: Configure Infrastructure with Ansible (Optional)

If you want to configure existing instances:

```bash
cd Ansible

# Update inventory.ini with your EC2 IPs
# Get IPs from: terraform output instance_public_ips

# Test connection
ansible all -m ping

# Run playbook
ansible-playbook webserver.yml
```

### Phase 3: Deploy with Terraform

```bash
# Update configuration
# Edit terraform.tfvars with your values

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

### Phase 4: Push to GitHub

```bash
# Initialize Git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Terraform Cloud project with Packer and Ansible"

# Create GitHub repo and push
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/terraform-cloud.git
git push -u origin main
```

### Phase 5: Migrate to Terraform Cloud

#### 5.1 Create Account
1. Go to https://app.terraform.io/signup/account
2. Sign up and verify email
3. Create organization

#### 5.2 Create Workspace (VCS-driven)
1. Click "New Workspace"
2. Choose "Version control workflow"
3. Connect to GitHub
4. Select `terraform-cloud` repository
5. Configure:
   - Name: `terraform-cloud-demo`
   - VCS branch: `main`
   - Working directory: (leave blank)

#### 5.3 Configure Variables

**Environment Variables**:
- `AWS_ACCESS_KEY_ID` (sensitive)
- `AWS_SECRET_ACCESS_KEY` (sensitive)

**Terraform Variables**:
- `aws_region` = "us-east-1"
- `environment` = "dev"
- `instance_type` = "t2.micro"
- `vpc_cidr` = "10.0.0.0/16"
- `key_name` = "your-key-pair"
- `custom_ami_name` = "ubuntu-nginx-*" (if using Packer AMI)

#### 5.4 Test Automatic Trigger
```bash
# Make a change
echo "# Test trigger" >> main.tf

# Commit and push
git add .
git commit -m "Test automatic trigger"
git push

# Check Terraform Cloud - run should start automatically!
```

### Phase 6: Multi-Environment Setup

#### Create Branches
```bash
# Dev branch
git checkout -b dev
git push origin dev

# Test branch
git checkout -b test
git push origin test

# Prod branch
git checkout main
```

#### Create Workspaces

**Dev Workspace**:
- Name: `terraform-cloud-dev`
- VCS Branch: `dev`
- Auto Apply: ✅ Enabled
- Variables: environment = "dev", vpc_cidr = "10.0.0.0/16"

**Test Workspace**:
- Name: `terraform-cloud-test`
- VCS Branch: `test`
- Auto Apply: ❌ Disabled
- Variables: environment = "test", vpc_cidr = "10.1.0.0/16"

**Prod Workspace**:
- Name: `terraform-cloud-prod`
- VCS Branch: `main`
- Auto Apply: ❌ Disabled
- Variables: environment = "prod", vpc_cidr = "10.2.0.0/16"

### Phase 7: Configure Notifications

For each workspace:

1. Go to Settings → Notifications
2. Add Email notification:
   - Events: Run errored, Run needs attention
   - Email: your-email@example.com

3. Add Slack notification (optional):
   - Webhook URL: your-slack-webhook
   - Events: Run started, Run completed, Run errored

## 🎯 Usage Scenarios

### Scenario 1: Using Default Ubuntu AMI
```hcl
# In terraform.tfvars
custom_ami_name = ""  # Empty = use default Ubuntu
```

### Scenario 2: Using Custom Packer AMI
```hcl
# In terraform.tfvars
custom_ami_name = "ubuntu-nginx-*"  # Use Packer-built AMI
```

### Scenario 3: Post-Deployment Configuration with Ansible
```bash
# After Terraform creates instances
terraform output instance_public_ips

# Update Ansible inventory
# Edit Ansible/inventory.ini with IPs

# Run Ansible playbook
cd Ansible
ansible-playbook webserver.yml
```

## 📊 Complete Workflow Example

### Build and Deploy Everything

```bash
# 1. Build custom AMI (optional, takes 10 min)
cd AMI
packer build ubuntu-nginx.pkr.hcl
cd ..

# 2. Update Terraform config
# Edit terraform.tfvars with AMI name

# 3. Deploy infrastructure
terraform init
terraform apply

# 4. Configure with Ansible (optional)
cd Ansible
# Update inventory.ini with instance IPs
ansible-playbook webserver.yml
cd ..

# 5. Push to GitHub
git add .
git commit -m "Complete setup with Packer and Ansible"
git push

# 6. Terraform Cloud automatically runs!
```

## ✅ Verification Checklist

### Packer
- [ ] Packer installed
- [ ] AMI built successfully
- [ ] AMI ID noted
- [ ] AMI visible in AWS Console

### Ansible
- [ ] Ansible installed
- [ ] Inventory updated with IPs
- [ ] Can ping instances
- [ ] Playbook runs successfully
- [ ] Web server accessible

### Terraform
- [ ] Infrastructure deployed
- [ ] Outputs showing correctly
- [ ] Resources in AWS Console
- [ ] State file created

### Terraform Cloud
- [ ] Account created
- [ ] Organization created
- [ ] Workspace connected to GitHub
- [ ] Variables configured
- [ ] Automatic triggers working
- [ ] Multi-environment setup
- [ ] Notifications configured

### GitHub
- [ ] Repository created
- [ ] Code pushed
- [ ] Branches created (dev/test/main)
- [ ] Commits trigger runs

## 🔧 Troubleshooting

### Packer Issues

**Error: AWS credentials not found**
```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

**Error: AMI build failed**
```bash
# Check Packer logs
packer build -debug ubuntu-nginx.pkr.hcl
```

### Ansible Issues

**Error: Cannot connect to hosts**
```bash
# Check SSH key permissions
chmod 400 ~/.ssh/your-key.pem

# Test connection
ansible all -m ping -vvv
```

**Error: Permission denied**
```bash
# Ensure become is enabled in playbook
# Check ansible.cfg has correct settings
```

### Terraform Issues

**Error: Custom AMI not found**
```bash
# Check AMI name pattern matches
# Verify AMI exists in correct region
aws ec2 describe-images --owners self --filters "Name=name,Values=ubuntu-nginx-*"
```

## 💡 Pro Tips

1. **Packer**: Build AMIs in the same region as your Terraform deployment
2. **Ansible**: Use dynamic inventory for automatic IP discovery
3. **Terraform**: Use data sources to find latest custom AMI automatically
4. **Git**: Use meaningful commit messages for better run tracking
5. **Terraform Cloud**: Use workspace-specific variables for environment differences

## 📚 Additional Resources

- [Packer Documentation](https://www.packer.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Cloud Documentation](https://www.terraform.io/cloud-docs)

## 🎊 Success!

You now have a complete infrastructure-as-code setup with:
- ✅ Custom AMI building with Packer
- ✅ Configuration management with Ansible
- ✅ Infrastructure provisioning with Terraform
- ✅ Version control with GitHub
- ✅ Automation with Terraform Cloud
- ✅ Multi-environment support
- ✅ Notifications and monitoring

**This is a production-ready DevOps workflow!** 🚀
