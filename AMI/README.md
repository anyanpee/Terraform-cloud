# Packer AMI Configuration

This folder contains Packer templates for building custom AMIs.

## Prerequisites

- Packer installed (>= 1.8.0)
- AWS credentials configured
- Ansible installed (for provisioning)

## Build AMI

```bash
# Initialize Packer
packer init .

# Validate template
packer validate ubuntu-nginx.pkr.hcl

# Build AMI
packer build ubuntu-nginx.pkr.hcl
```

## Files

- `ubuntu-nginx.pkr.hcl` - Main Packer template
- `variables.pkr.hcl` - Variable definitions
