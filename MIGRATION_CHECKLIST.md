# Terraform Cloud Migration Checklist

## Pre-Migration (S3 Backend Setup)

- [ ] Install Terraform CLI (>= 1.0)
- [ ] Configure AWS CLI with credentials
- [ ] Update S3 bucket name in `backend-setup.tf` (must be globally unique)
- [ ] Update S3 bucket name in `main.tf` backend configuration
- [ ] Create S3 bucket and DynamoDB table:
  ```bash
  terraform init
  terraform apply
  ```
- [ ] Verify S3 bucket created: `aws s3 ls | grep terraform-state`
- [ ] Verify DynamoDB table created: `aws dynamodb list-tables`
- [ ] Initialize Terraform with S3 backend: `terraform init`
- [ ] Deploy initial infrastructure: `terraform apply`
- [ ] Verify state file in S3: `aws s3 ls s3://YOUR-BUCKET-NAME/terraform/state/`
- [ ] Test state locking works (try running terraform plan in two terminals)

## Terraform Cloud Setup

- [ ] Create Terraform Cloud account at https://app.terraform.io/signup/account
- [ ] Verify email address
- [ ] Create organization (note the name: _______________)
- [ ] Create workspace:
  - [ ] Choose workflow type (CLI-driven or VCS-driven)
  - [ ] Name workspace (note the name: _______________)
  - [ ] Configure settings

## Migration Process

- [ ] Backup current state file:
  ```bash
  terraform state pull > backup-state.json
  ```
- [ ] Update `main.tf`:
  - [ ] Comment out S3 backend block
  - [ ] Add Terraform Cloud backend block with your org and workspace name
- [ ] Authenticate with Terraform Cloud:
  ```bash
  terraform login
  ```
- [ ] Migrate state:
  ```bash
  terraform init -migrate-state
  ```
- [ ] Confirm migration when prompted (type "yes")
- [ ] Verify state migrated:
  ```bash
  terraform state list
  ```
- [ ] Check Terraform Cloud UI - state should be visible in workspace

## Terraform Cloud Configuration

- [ ] Configure Environment Variables in workspace:
  - [ ] Add `AWS_ACCESS_KEY_ID` (mark as sensitive)
  - [ ] Add `AWS_SECRET_ACCESS_KEY` (mark as sensitive)
- [ ] Configure Terraform Variables (optional):
  - [ ] `aws_region`
  - [ ] `environment`
  - [ ] `instance_type`
  - [ ] `vpc_cidr`
- [ ] Test run from Terraform Cloud:
  - [ ] Queue plan manually
  - [ ] Review plan output
  - [ ] Confirm and apply

## Version Control Setup (Optional)

- [ ] Create GitHub repository named `terraform-cloud`
- [ ] Initialize git locally:
  ```bash
  git init
  git add .
  git commit -m "Initial commit"
  ```
- [ ] Add remote and push:
  ```bash
  git remote add origin https://github.com/YOUR_USERNAME/terraform-cloud.git
  git push -u origin main
  ```
- [ ] Connect workspace to VCS:
  - [ ] Go to workspace Settings → Version Control
  - [ ] Connect to GitHub
  - [ ] Select repository
  - [ ] Configure branch (main)
- [ ] Test automatic trigger:
  - [ ] Make a change to any .tf file
  - [ ] Commit and push
  - [ ] Verify run starts automatically in Terraform Cloud

## Multi-Environment Setup

- [ ] Create branches:
  ```bash
  git checkout -b dev
  git push origin dev
  git checkout -b test
  git push origin test
  git checkout main
  ```
- [ ] Create additional workspaces:
  - [ ] `terraform-cloud-dev` (linked to dev branch, auto-apply enabled)
  - [ ] `terraform-cloud-test` (linked to test branch, auto-apply disabled)
  - [ ] `terraform-cloud-prod` (linked to main branch, auto-apply disabled)
- [ ] Configure variables for each workspace
- [ ] Test each environment

## Notifications Setup

- [ ] Configure Email notifications:
  - [ ] Go to workspace Settings → Notifications
  - [ ] Add email notification
  - [ ] Select events: "Run errored", "Run needs attention"
  - [ ] Add your email
- [ ] Configure Slack notifications (optional):
  - [ ] Create Slack incoming webhook
  - [ ] Add Slack notification in workspace
  - [ ] Select events: "Run started", "Run completed", "Run errored"
  - [ ] Test notification

## Testing & Validation

- [ ] Test CLI-driven workflow:
  ```bash
  terraform plan
  terraform apply
  ```
- [ ] Test UI-driven workflow:
  - [ ] Queue plan from Terraform Cloud UI
  - [ ] Review and apply
- [ ] Test VCS-driven workflow (if configured):
  - [ ] Make a change and push to repository
  - [ ] Verify automatic plan trigger
- [ ] Verify state locking:
  - [ ] Start a run
  - [ ] Try to start another run (should be queued)
- [ ] Test notifications:
  - [ ] Trigger a run
  - [ ] Verify email/Slack notification received
- [ ] Verify outputs are displayed correctly
- [ ] Check run history in Terraform Cloud

## Post-Migration Cleanup

- [ ] Verify all resources are managed correctly
- [ ] Document any issues encountered
- [ ] Update team documentation
- [ ] Train team members on Terraform Cloud workflow
- [ ] Consider cleanup of S3 backend:
  - [ ] Backup S3 state files (optional)
  - [ ] Delete S3 state files: `aws s3 rm s3://BUCKET/terraform/state/ --recursive`
  - [ ] Destroy S3 bucket and DynamoDB table (optional)

## Rollback Plan (If Needed)

- [ ] Keep backup state file: `backup-state.json`
- [ ] To rollback:
  ```bash
  # Restore S3 backend in main.tf
  # Remove Terraform Cloud backend
  terraform init -migrate-state
  # Restore from backup if needed
  terraform state push backup-state.json
  ```

## Notes

- Migration Date: _______________
- Migrated By: _______________
- Organization Name: _______________
- Workspace Name: _______________
- Issues Encountered: _______________
- Resolution: _______________

## Success Criteria

- [x] State successfully migrated to Terraform Cloud
- [x] Can run terraform plan/apply from CLI
- [x] Can run from Terraform Cloud UI
- [x] AWS credentials working in Terraform Cloud
- [x] Notifications configured and working
- [x] Team trained on new workflow
- [x] Documentation updated
