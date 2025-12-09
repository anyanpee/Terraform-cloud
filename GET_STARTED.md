# 🚀 Get Started in 3 Steps

## Before You Begin

Make sure you have:
- [ ] AWS Account with credentials
- [ ] Terraform installed (>= 1.0)
- [ ] Git installed (optional, for VCS workflow)

---

## Step 1: Configure Your Project (2 minutes)

### 1.1 Update S3 Bucket Name

The S3 bucket name must be **globally unique** across all AWS accounts.

**Edit `backend-setup.tf` (line 20):**
```hcl
bucket = "YOUR-UNIQUE-BUCKET-NAME-HERE"  # Change this!
```

**Edit `main.tf` (line 13):**
```hcl
bucket = "YOUR-UNIQUE-BUCKET-NAME-HERE"  # Same as above
```

💡 **Tip**: Use something like `terraform-state-yourname-20251208`

### 1.2 Update AWS Key Pair (Optional)

**Edit `terraform.tfvars` (line 6):**
```hcl
key_name = "your-aws-key-pair-name"  # Or leave empty ""
```

### 1.3 Configure AWS Credentials

**Option A: AWS CLI (Recommended)**
```bash
aws configure
```

**Option B: Environment Variables**
```bash
# Windows (Command Prompt)
set AWS_ACCESS_KEY_ID=your-access-key
set AWS_SECRET_ACCESS_KEY=your-secret-key

# Windows (PowerShell)
$env:AWS_ACCESS_KEY_ID="your-access-key"
$env:AWS_SECRET_ACCESS_KEY="your-secret-key"

# Linux/Mac
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

---

## Step 2: Deploy with S3 Backend (3 minutes)

### 2.1 Initialize Terraform
```bash
cd "c:\Users\DELL\Desktop\Terraform cloud project"
terraform init
```

Expected output: `Terraform has been successfully initialized!`

### 2.2 Create S3 Backend Infrastructure
```bash
terraform apply
```

Type `yes` when prompted.

This creates:
- ✅ S3 bucket for state storage
- ✅ DynamoDB table for state locking
- ✅ VPC with 2 subnets
- ✅ 2 EC2 instances with Nginx

### 2.3 Verify Deployment
```bash
terraform output
```

You should see:
- VPC ID
- Subnet IDs
- Instance IDs
- Public IP addresses

### 2.4 Test Your Web Servers

Open a browser and visit the public IPs shown in the output:
```
http://<instance-public-ip>
```

You should see: "Hello from dev - Instance 1"

---

## Step 3: Migrate to Terraform Cloud (5 minutes)

### 3.1 Create Terraform Cloud Account

1. Go to: https://app.terraform.io/signup/account
2. Sign up with your email
3. Verify your email
4. Create an organization (e.g., "my-terraform-org")
5. Create a workspace (e.g., "aws-infrastructure")

### 3.2 Update Backend Configuration

**Edit `main.tf`** - Replace the backend section:

**Comment out S3 backend:**
```hcl
# backend "s3" {
#   bucket         = "YOUR-BUCKET-NAME"
#   key            = "terraform/state/terraform.tfstate"
#   region         = "us-east-1"
#   encrypt        = true
#   dynamodb_table = "terraform-state-lock"
# }
```

**Add Terraform Cloud backend:**
```hcl
cloud {
  organization = "my-terraform-org"  # Your org name

  workspaces {
    name = "aws-infrastructure"  # Your workspace name
  }
}
```

### 3.3 Login to Terraform Cloud

**Windows:**
```bash
terraform login
```

**Follow the prompts:**
1. Press Enter to open browser
2. Generate API token
3. Copy token
4. Paste in terminal

### 3.4 Migrate State

```bash
terraform init -migrate-state
```

When prompted:
```
Do you want to copy existing state to the new backend?
```
Type: `yes`

### 3.5 Configure AWS Credentials in Terraform Cloud

1. Go to your workspace in Terraform Cloud
2. Click **"Variables"** tab
3. Add **Environment Variables**:

| Variable Name | Value | Sensitive |
|--------------|-------|-----------|
| AWS_ACCESS_KEY_ID | your-access-key | ✅ Yes |
| AWS_SECRET_ACCESS_KEY | your-secret-key | ✅ Yes |

### 3.6 Test from Terraform Cloud

**Option A: From CLI**
```bash
terraform plan
terraform apply
```

**Option B: From Web UI**
1. Go to your workspace
2. Click **"Actions"** → **"Start new run"**
3. Add a message: "Testing Terraform Cloud"
4. Click **"Start run"**
5. Review the plan
6. Click **"Confirm & Apply"**

---

## ✅ Success Checklist

After completing all steps, you should have:

- [x] S3 bucket created for state storage
- [x] DynamoDB table created for locking
- [x] VPC with 2 public subnets deployed
- [x] 2 EC2 instances running Nginx
- [x] State migrated to Terraform Cloud
- [x] Can run terraform commands from CLI
- [x] Can run from Terraform Cloud UI
- [x] AWS credentials configured in workspace

---

## 🎯 What's Next?

### Option 1: Connect to GitHub (Recommended)

1. Create a GitHub repository named `terraform-cloud`
2. Push your code:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/terraform-cloud.git
   git push -u origin main
   ```
3. In Terraform Cloud workspace:
   - Go to **Settings** → **Version Control**
   - Click **"Connect to version control"**
   - Select **GitHub**
   - Choose your repository
   - Save settings

Now every push to GitHub will automatically trigger a Terraform plan! 🎉

### Option 2: Set Up Multi-Environment

Create separate workspaces for each environment:

1. **Dev Workspace**
   - Name: `aws-infrastructure-dev`
   - Branch: `dev`
   - Auto-apply: Enabled

2. **Test Workspace**
   - Name: `aws-infrastructure-test`
   - Branch: `test`
   - Auto-apply: Disabled

3. **Prod Workspace**
   - Name: `aws-infrastructure-prod`
   - Branch: `main`
   - Auto-apply: Disabled

### Option 3: Configure Notifications

1. Go to workspace **Settings** → **Notifications**
2. Add **Email notification**:
   - Events: "Run errored", "Run needs attention"
   - Email: your-email@example.com
3. Add **Slack notification** (optional):
   - Create Slack webhook
   - Events: "Run started", "Run completed", "Run errored"

---

## 🧹 Cleanup (When Done Testing)

To avoid AWS charges, destroy the infrastructure:

```bash
terraform destroy
```

Type `yes` when prompted.

This will delete:
- EC2 instances
- VPC and subnets
- Internet gateway
- Security groups

**Optional**: Delete S3 backend resources:
```bash
# Delete state files
aws s3 rm s3://YOUR-BUCKET-NAME/terraform/state/ --recursive

# Destroy backend infrastructure
terraform destroy
```

---

## 🆘 Troubleshooting

### Issue: "Bucket name already exists"
**Solution**: S3 bucket names are globally unique. Change the bucket name in both `backend-setup.tf` and `main.tf`.

### Issue: "No valid credential sources"
**Solution**: Run `aws configure` or set AWS environment variables.

### Issue: "State locked"
**Solution**: Wait for other operations to complete, or run:
```bash
terraform force-unlock LOCK_ID
```

### Issue: "Migration failed"
**Solution**: 
```bash
rm -rf .terraform
rm .terraform.lock.hcl
terraform init -migrate-state
```

### Issue: Can't access EC2 instances
**Solution**: Check security group rules and ensure your IP is allowed, or use `0.0.0.0/0` for testing (not recommended for production).

---

## 📚 Documentation

- **[README.md](README.md)** - Complete documentation
- **[QUICKSTART.md](QUICKSTART.md)** - Quick reference guide
- **[MIGRATION_CHECKLIST.md](MIGRATION_CHECKLIST.md)** - Detailed migration steps
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Project overview
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Architecture diagrams

---

## 💡 Pro Tips

1. **Always review plans** before applying
2. **Use workspaces** for different environments
3. **Enable notifications** to stay informed
4. **Tag your resources** for better organization
5. **Never commit** `.tfvars` files with secrets
6. **Backup state** before major changes
7. **Use modules** for reusable code
8. **Document changes** in commit messages

---

## 🎓 Learning Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Cloud Docs](https://developer.hashicorp.com/terraform/cloud-docs)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## 📞 Need Help?

- Check the [README.md](README.md) for detailed instructions
- Review the [MIGRATION_CHECKLIST.md](MIGRATION_CHECKLIST.md)
- Visit [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)
- Check [AWS Documentation](https://docs.aws.amazon.com/)

---

**Happy Terraforming! 🚀**

Remember: Infrastructure as Code is a journey, not a destination. Start small, learn continuously, and automate everything!
