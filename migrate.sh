#!/bin/bash

# Terraform Cloud Migration Script
# This script helps automate the migration from S3 backend to Terraform Cloud

set -e

echo "=========================================="
echo "Terraform Cloud Migration Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

print_success "Terraform is installed: $(terraform version | head -n 1)"
echo ""

# Step 1: Backup current state
echo "Step 1: Backing up current state..."
if terraform state pull > backup-state-$(date +%Y%m%d-%H%M%S).json 2>/dev/null; then
    print_success "State backed up successfully"
else
    print_warning "Could not backup state (this is OK if state doesn't exist yet)"
fi
echo ""

# Step 2: Get Terraform Cloud details
echo "Step 2: Terraform Cloud Configuration"
echo "--------------------------------------"
read -p "Enter your Terraform Cloud organization name: " ORG_NAME
read -p "Enter your workspace name: " WORKSPACE_NAME
echo ""

# Step 3: Check if already logged in
echo "Step 3: Checking Terraform Cloud authentication..."
if [ -f "$HOME/.terraform.d/credentials.tfrc.json" ]; then
    print_success "Already authenticated with Terraform Cloud"
else
    print_info "Please login to Terraform Cloud..."
    terraform login
fi
echo ""

# Step 4: Update backend configuration
echo "Step 4: Updating backend configuration..."
cat > backend-override.tf << EOF
terraform {
  cloud {
    organization = "$ORG_NAME"

    workspaces {
      name = "$WORKSPACE_NAME"
    }
  }
}
EOF
print_success "Backend configuration created in backend-override.tf"
echo ""

# Step 5: Migrate state
echo "Step 5: Migrating state to Terraform Cloud..."
print_warning "You will be prompted to confirm the migration. Type 'yes' to proceed."
echo ""

if terraform init -migrate-state; then
    print_success "State migrated successfully!"
else
    print_error "Migration failed. Please check the errors above."
    exit 1
fi
echo ""

# Step 6: Verify migration
echo "Step 6: Verifying migration..."
if terraform state list > /dev/null 2>&1; then
    print_success "State is accessible from Terraform Cloud"
    echo ""
    echo "Resources in state:"
    terraform state list
else
    print_error "Could not access state from Terraform Cloud"
    exit 1
fi
echo ""

# Step 7: Cleanup
echo "Step 7: Cleanup"
read -p "Do you want to remove the backend-override.tf file? (y/n): " CLEANUP
if [ "$CLEANUP" = "y" ] || [ "$CLEANUP" = "Y" ]; then
    rm backend-override.tf
    print_success "Cleaned up backend-override.tf"
    print_info "Remember to update your main.tf with the cloud backend configuration"
fi
echo ""

# Success message
echo "=========================================="
print_success "Migration completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials in Terraform Cloud workspace"
echo "   - AWS_ACCESS_KEY_ID (mark as sensitive)"
echo "   - AWS_SECRET_ACCESS_KEY (mark as sensitive)"
echo ""
echo "2. Test the setup:"
echo "   terraform plan"
echo "   terraform apply"
echo ""
echo "3. (Optional) Connect to GitHub for automatic runs"
echo ""
print_info "Visit your workspace: https://app.terraform.io/app/$ORG_NAME/workspaces/$WORKSPACE_NAME"
