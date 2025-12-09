# Quick Start Guide

This guide will help you get started quickly with the Terraform Cloud migration project.

## 🚀 Quick Setup (5 minutes)

### 1. Update Configuration

Edit the following files with your specific values:

**backend-setup.tf** - Line 20:
```hcl
bucket = "YOUR-UNIQUE-BUCKET-NAME"  # Must be globally unique!
```

**main.tf** - Line 13:
```hcl
bucket = "YOUR-UNIQUE-BUCKET-NAME"  # Same as above
```

**terraform.tfvars** - Line 6:
```hcl
key_name = "YOUR-AWS-KEY-PAIR-NAME"  # Your existing AWS key pair
```

### 2. Setup S3 Backend (First Time Only)

```bash
# Initialize Terraform
terraform init

# Create S3 bucket and DynamoDB table
terraform apply

# Type 'yes' when prompted
```

### 3. Deploy Infrastructure

```bash
# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Type 'yes' when prompted
```

### 4. Verify Deployment

```bash
# Check outputs
terraform output

# You should see:
# - vpc_id
# - public_subnet_ids
# - instance_ids
# - instance_public_ips
```

## 🌩️ Migrate to Terraform Cloud (10 minutes)

### 1. Create Terraform Cloud Account

1. Go to: https://app.terraform.io/signup/account
2. Sign up and verify email
3. Create organization (remember the name!)
4. Create workspace (remember the name!)

### 2. Update Backend Configuration

Edit **main.tf** and replace the backend section:

```hcl
# Comment out S3 backend
# backend "s3" {
#   bucket         = "YOUR-BUCKET-NAME"
#   key            = "terraform/state/terraform.tfstate"
#   region         = "us-east-1"
#   encrypt        = true
#   dynamodb_table = "terraform-state-lock"
# }

# Add Terraform Cloud backend
cloud {
  organization = "YOUR-ORG-NAME"

  workspaces {
    name = "YOUR-WORKSPACE-NAME"
  }
}
```

### 3. Login and Migrate

```bash
# Login to Terraform Cloud
terraform login

# Follow the prompts to create API token

# Migrate state
terraform init -migrate-state

# Type 'yes' when prompted
```

### 4. Configure AWS Credentials in Terraform Cloud

1. Go to your workspace in Terraform Cloud
2. Click "Variables"
3. Add Environment Variables:
   - `AWS_ACCESS_KEY_ID` = your-access-key (mark as sensitive)
   - `AWS_SECRET_ACCESS_KEY` = your-secret-key (mark as sensitive)

### 5. Test from Terraform Cloud

```bash
# Run from CLI (uses Terraform Cloud)
terraform plan
terraform apply

# Or run from Terraform Cloud UI:
# 1. Go to workspace
# 2. Click "Actions" → "Start new run"
# 3. Review and apply
```

## 🎯 Common Commands

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show outputs
terraform output

# List resources
terraform state list

# Show specific resource
terraform state show aws_vpc.main

# Destroy everything
terraform destroy
```

## 🔧 Troubleshooting

### Error: Bucket name already exists
```bash
# Update bucket name in backend-setup.tf and main.tf
# Bucket names must be globally unique across all AWS accounts
```

### Error: No valid credential sources
```bash
# Configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

### Error: State locked
```bash
# Wait for other operations to complete, or force unlock
terraform force-unlock LOCK_ID
```

### Error: Migration failed
```bash
# Remove local state and retry
rm -rf .terraform
rm .terraform.lock.hcl
terraform init -migrate-state
```

## 📚 Next Steps

1. ✅ Read the full [README.md](README.md) for detailed instructions
2. ✅ Follow the [MIGRATION_CHECKLIST.md](MIGRATION_CHECKLIST.md)
3. ✅ Set up GitHub integration for automatic runs
4. ✅ Configure notifications (email/Slack)
5. ✅ Create multi-environment workspaces (dev/test/prod)

## 🆘 Need Help?

- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)

## ⚠️ Important Notes

- **Never commit** `.tfvars` files with sensitive data to Git
- **Always review** plans before applying
- **Use workspaces** for different environments
- **Enable notifications** to stay informed
- **Backup state** before major changes

## 💰 Cost Considerations

This configuration creates:
- 1 VPC (Free)
- 2 Public Subnets (Free)
- 1 Internet Gateway (Free)
- 2 EC2 t2.micro instances (~$0.0116/hour each = ~$17/month)
- 1 Security Group (Free)
- 1 S3 Bucket (~$0.023/GB/month)
- 1 DynamoDB Table (Pay per request, minimal cost)

**Estimated monthly cost: ~$20-25**

Remember to destroy resources when not in use:
```bash
terraform destroy
```

---

Happy Terraforming! 🚀
