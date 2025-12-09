# Terraform Cloud Migration Project

This project demonstrates how to migrate from S3 backend to Terraform Cloud for state management.

## Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── terraform.tfvars        # Variable values (DO NOT commit to Git)
├── backend-setup.tf        # S3 backend infrastructure setup
├── modules/
│   ├── vpc/               # VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/               # EC2 module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0 installed
- AWS account with appropriate permissions
- Terraform Cloud account (for migration)

## Phase 1: Setup with S3 Backend

### Step 1: Create S3 Backend Infrastructure

First, create the S3 bucket and DynamoDB table for state management:

```bash
# Initialize and apply backend setup
terraform init
terraform apply -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks

# Or use the backend-setup.tf file separately
cd backend-setup
terraform init
terraform apply
cd ..
```

**Note:** The bucket name `my-terraform-state-bucket-demo` must be globally unique. Update it in both `backend-setup.tf` and `main.tf` if needed.

### Step 2: Initialize with S3 Backend

After creating the S3 bucket and DynamoDB table:

```bash
# Initialize Terraform with S3 backend
terraform init

# You should see: "Successfully configured the backend "s3"!"
```

### Step 3: Deploy Infrastructure

```bash
# Plan the infrastructure
terraform plan

# Apply the configuration
terraform apply

# Verify state is stored in S3
aws s3 ls s3://my-terraform-state-bucket-demo/terraform/state/
```

### Step 4: Verify State in S3

```bash
# Check S3 bucket
aws s3 ls s3://my-terraform-state-bucket-demo/terraform/state/

# Check DynamoDB lock table
aws dynamodb scan --table-name terraform-state-lock
```

## Phase 2: Migrate to Terraform Cloud

### Step 1: Create Terraform Cloud Account

1. Go to https://app.terraform.io/signup/account
2. Create an account and verify your email
3. Create an organization (e.g., "my-org")

### Step 2: Create a Workspace

1. In Terraform Cloud, click "New Workspace"
2. Choose "CLI-driven workflow" (for migration) or "Version control workflow" (for GitHub integration)
3. Name your workspace (e.g., "terraform-cloud-demo")
4. Click "Create workspace"

### Step 3: Configure Terraform Cloud Backend

Update `main.tf` to use Terraform Cloud backend:

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Comment out S3 backend
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket-demo"
  #   key            = "terraform/state/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }

  # Add Terraform Cloud backend
  cloud {
    organization = "my-org"  # Replace with your organization name

    workspaces {
      name = "terraform-cloud-demo"  # Replace with your workspace name
    }
  }
}
```

### Step 4: Authenticate with Terraform Cloud

```bash
# Login to Terraform Cloud
terraform login

# Follow the prompts to generate an API token
# The token will be saved to: %APPDATA%\terraform.d\credentials.tfrc.json
```

### Step 5: Migrate State to Terraform Cloud

```bash
# Reinitialize with new backend
terraform init -migrate-state

# Terraform will prompt: "Do you want to copy existing state to the new backend?"
# Type "yes" to migrate

# Verify migration
terraform state list
```

### Step 6: Configure Variables in Terraform Cloud

1. Go to your workspace in Terraform Cloud
2. Navigate to "Variables"
3. Add **Environment Variables**:
   - `AWS_ACCESS_KEY_ID` (mark as sensitive)
   - `AWS_SECRET_ACCESS_KEY` (mark as sensitive)

4. Add **Terraform Variables** (optional):
   - `aws_region` = "us-east-1"
   - `environment` = "dev"
   - `instance_type` = "t2.micro"

### Step 7: Run from Terraform Cloud

#### Option A: CLI-driven workflow

```bash
# Plan from local machine
terraform plan

# Apply from local machine
terraform apply
```

#### Option B: Web UI workflow

1. Go to your workspace in Terraform Cloud
2. Click "Actions" → "Start new run"
3. Add a message and click "Start run"
4. Review the plan
5. Click "Confirm & Apply"

### Step 8: Connect to GitHub (Optional)

For version control workflow:

1. Create a GitHub repository named `terraform-cloud`
2. Push your code:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/terraform-cloud.git
git push -u origin main
```

3. In Terraform Cloud workspace settings:
   - Go to "Version Control"
   - Click "Connect to version control"
   - Select GitHub and authorize
   - Choose your repository
   - Save settings

4. Now every push to the repository will trigger a plan automatically!

## Phase 3: Multi-Environment Setup

### Create Environment-Specific Workspaces

1. **Dev Workspace**
   - Name: `terraform-cloud-dev`
   - VCS Branch: `dev`
   - Auto-apply: Enabled

2. **Test Workspace**
   - Name: `terraform-cloud-test`
   - VCS Branch: `test`
   - Auto-apply: Disabled

3. **Prod Workspace**
   - Name: `terraform-cloud-prod`
   - VCS Branch: `main`
   - Auto-apply: Disabled

### Create Branches

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

### Configure Notifications

1. Go to workspace "Settings" → "Notifications"
2. Add Email notification:
   - Events: "Run errored", "Run needs attention"
   - Email: your-email@example.com

3. Add Slack notification (optional):
   - Create Slack webhook
   - Events: "Run started", "Run completed", "Run errored"
   - Webhook URL: your-slack-webhook-url

## Testing the Setup

### Test 1: Verify State Migration

```bash
# Check state is in Terraform Cloud
terraform state list

# Compare with S3 (should be the same)
terraform state pull > cloud-state.json
```

### Test 2: Make a Change

```bash
# Edit terraform.tfvars
# Change instance_type = "t2.small"

# Plan and apply
terraform plan
terraform apply
```

### Test 3: Automatic Triggers (VCS workflow)

```bash
# Make a change to any .tf file
echo '# Test comment' >> main.tf

# Commit and push
git add .
git commit -m "Test automatic trigger"
git push

# Check Terraform Cloud - a run should start automatically!
```

## Cleanup

### Destroy Infrastructure

```bash
# From CLI
terraform destroy

# Or from Terraform Cloud UI
# Settings → Destruction and Deletion → Queue destroy plan
```

### Remove S3 Backend Resources

```bash
# Delete state files from S3
aws s3 rm s3://my-terraform-state-bucket-demo/terraform/state/ --recursive

# Destroy backend infrastructure
cd backend-setup
terraform destroy
```

## Troubleshooting

### Issue: State lock error

```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### Issue: Migration failed

```bash
# Remove local state and re-migrate
rm -rf .terraform
rm .terraform.lock.hcl
terraform init -migrate-state
```

### Issue: AWS credentials not working in Terraform Cloud

- Ensure AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are set as environment variables
- Mark them as "sensitive"
- Check IAM permissions

## Best Practices

1. **Never commit sensitive data** - Use .gitignore for .tfvars files
2. **Use state locking** - Prevents concurrent modifications
3. **Enable versioning** - S3 versioning helps recover from mistakes
4. **Use workspaces** - Separate environments (dev/test/prod)
5. **Enable notifications** - Stay informed about infrastructure changes
6. **Review plans** - Always review before applying
7. **Use modules** - Reusable, maintainable code
8. **Tag resources** - Better organization and cost tracking

## Resources

- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [Migrating State to Terraform Cloud](https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-migrate)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

This project is for educational purposes.
