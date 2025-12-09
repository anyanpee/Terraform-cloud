# Architecture Diagram

## AWS Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud (us-east-1)                    │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    VPC (10.0.0.0/16)                        │ │
│  │                                                              │ │
│  │  ┌──────────────────────┐    ┌──────────────────────┐     │ │
│  │  │  Availability Zone A │    │  Availability Zone B │     │ │
│  │  │                      │    │                      │     │ │
│  │  │  ┌────────────────┐ │    │  ┌────────────────┐ │     │ │
│  │  │  │ Public Subnet  │ │    │  │ Public Subnet  │ │     │ │
│  │  │  │ 10.0.0.0/24    │ │    │  │ 10.0.1.0/24    │ │     │ │
│  │  │  │                │ │    │  │                │ │     │ │
│  │  │  │  ┌──────────┐  │ │    │  │  ┌──────────┐  │ │     │ │
│  │  │  │  │ EC2      │  │ │    │  │  │ EC2      │  │ │     │ │
│  │  │  │  │ Instance │  │ │    │  │  │ Instance │  │ │     │ │
│  │  │  │  │ (Nginx)  │  │ │    │  │  │ (Nginx)  │  │ │     │ │
│  │  │  │  │ t2.micro │  │ │    │  │  │ t2.micro │  │ │     │ │
│  │  │  │  └────┬─────┘  │ │    │  │  └────┬─────┘  │ │     │ │
│  │  │  └───────┼────────┘ │    │  └───────┼────────┘ │     │ │
│  │  └──────────┼──────────┘    └──────────┼──────────┘     │ │
│  │             │                           │                 │ │
│  │             └───────────┬───────────────┘                 │ │
│  │                         │                                 │ │
│  │                  ┌──────▼──────┐                         │ │
│  │                  │   Route     │                         │ │
│  │                  │   Table     │                         │ │
│  │                  └──────┬──────┘                         │ │
│  │                         │                                 │ │
│  │                  ┌──────▼──────┐                         │ │
│  │                  │  Internet   │                         │ │
│  │                  │  Gateway    │                         │ │
│  │                  └──────┬──────┘                         │ │
│  └─────────────────────────┼────────────────────────────────┘ │
│                            │                                   │
└────────────────────────────┼───────────────────────────────────┘
                             │
                             ▼
                        Internet
```

## State Management Architecture

### Phase 1: S3 Backend

```
┌──────────────────┐
│  Developer       │
│  Workstation     │
└────────┬─────────┘
         │
         │ terraform apply
         │
         ▼
┌────────────────────────────────────────┐
│         Terraform CLI                  │
│  ┌──────────────────────────────────┐ │
│  │  Backend Configuration           │ │
│  │  - Type: S3                      │ │
│  │  - Bucket: terraform-state       │ │
│  │  - Lock: DynamoDB                │ │
│  └──────────────────────────────────┘ │
└────────┬───────────────────┬──────────┘
         │                   │
         │                   │
         ▼                   ▼
┌─────────────────┐  ┌──────────────────┐
│   S3 Bucket     │  │   DynamoDB       │
│                 │  │   Table          │
│ ┌─────────────┐ │  │                  │
│ │ State File  │ │  │ ┌──────────────┐ │
│ │ (Encrypted) │ │  │ │ Lock Record  │ │
│ │ (Versioned) │ │  │ │ (LockID)     │ │
│ └─────────────┘ │  │ └──────────────┘ │
└─────────────────┘  └──────────────────┘
```

### Phase 2: Terraform Cloud

```
┌──────────────────┐
│  Developer       │
│  Workstation     │
└────────┬─────────┘
         │
         │ terraform apply
         │
         ▼
┌────────────────────────────────────────┐
│         Terraform CLI                  │
│  ┌──────────────────────────────────┐ │
│  │  Cloud Configuration             │ │
│  │  - Organization: my-org          │ │
│  │  - Workspace: demo               │ │
│  └──────────────────────────────────┘ │
└────────┬───────────────────────────────┘
         │
         │ HTTPS/TLS
         │
         ▼
┌─────────────────────────────────────────────────┐
│         Terraform Cloud                         │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │  Workspace: terraform-cloud-demo           │ │
│  │                                            │ │
│  │  ┌──────────────┐  ┌──────────────────┐  │ │
│  │  │ State File   │  │ Run History      │  │ │
│  │  │ (Encrypted)  │  │ - Plan #1        │  │ │
│  │  │ (Versioned)  │  │ - Plan #2        │  │ │
│  │  └──────────────┘  │ - Apply #1       │  │ │
│  │                    └──────────────────┘  │ │
│  │                                            │ │
│  │  ┌──────────────┐  ┌──────────────────┐  │ │
│  │  │ Variables    │  │ Notifications    │  │ │
│  │  │ - AWS Keys   │  │ - Email          │  │ │
│  │  │ - Terraform  │  │ - Slack          │  │ │
│  │  └──────────────┘  └──────────────────┘  │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │  Remote Execution Environment              │ │
│  │  - Terraform Runtime                       │ │
│  │  - AWS Provider                            │ │
│  │  - Secure Credentials                      │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────┬───────────────────────────┘
                      │
                      │ AWS API Calls
                      │
                      ▼
              ┌───────────────┐
              │   AWS Cloud   │
              │   Resources   │
              └───────────────┘
```

## VCS Integration Workflow

```
┌──────────────────┐
│   Developer      │
│   Local Machine  │
└────────┬─────────┘
         │
         │ git push
         │
         ▼
┌─────────────────────────────────┐
│         GitHub                  │
│                                 │
│  ┌───────────────────────────┐ │
│  │  Repository:              │ │
│  │  terraform-cloud          │ │
│  │                           │ │
│  │  Branches:                │ │
│  │  - main (prod)            │ │
│  │  - test                   │ │
│  │  - dev                    │ │
│  └───────────────────────────┘ │
└────────┬────────────────────────┘
         │
         │ Webhook
         │
         ▼
┌─────────────────────────────────────────────┐
│         Terraform Cloud                     │
│                                             │
│  ┌────────────────┐  ┌──────────────────┐ │
│  │ Workspace: Dev │  │ Workspace: Test  │ │
│  │ Branch: dev    │  │ Branch: test     │ │
│  │ Auto-apply: ✓  │  │ Auto-apply: ✗    │ │
│  └────────────────┘  └──────────────────┘ │
│                                             │
│  ┌────────────────┐                        │
│  │ Workspace:Prod │                        │
│  │ Branch: main   │                        │
│  │ Auto-apply: ✗  │                        │
│  └────────────────┘                        │
└─────────────────────────────────────────────┘
         │
         │ Automatic Trigger
         │
         ▼
┌─────────────────────────────────┐
│   Terraform Run                 │
│   1. Queue Plan                 │
│   2. Run Plan                   │
│   3. Wait for Approval          │
│   4. Apply (if approved)        │
└─────────────────────────────────┘
```

## Multi-Environment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Terraform Cloud                          │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Organization: my-org                                │  │
│  │                                                       │  │
│  │  ┌────────────────┐  ┌────────────────┐            │  │
│  │  │ Dev Workspace  │  │ Test Workspace │            │  │
│  │  │                │  │                │            │  │
│  │  │ VPC: 10.0.x.x  │  │ VPC: 10.1.x.x  │            │  │
│  │  │ Instances: 2   │  │ Instances: 2   │            │  │
│  │  │ Type: t2.micro │  │ Type: t2.small │            │  │
│  │  │ Auto-apply: ✓  │  │ Auto-apply: ✗  │            │  │
│  │  └────────┬───────┘  └────────┬───────┘            │  │
│  │           │                   │                     │  │
│  │           ▼                   ▼                     │  │
│  │  ┌─────────────────┐  ┌─────────────────┐         │  │
│  │  │ AWS Dev Account │  │ AWS Test Account│         │  │
│  │  └─────────────────┘  └─────────────────┘         │  │
│  │                                                     │  │
│  │  ┌────────────────┐                                │  │
│  │  │ Prod Workspace │                                │  │
│  │  │                │                                │  │
│  │  │ VPC: 10.2.x.x  │                                │  │
│  │  │ Instances: 4   │                                │  │
│  │  │ Type: t3.medium│                                │  │
│  │  │ Auto-apply: ✗  │                                │  │
│  │  └────────┬───────┘                                │  │
│  │           │                                         │  │
│  │           ▼                                         │  │
│  │  ┌─────────────────┐                               │  │
│  │  │ AWS Prod Account│                               │  │
│  │  └─────────────────┘                               │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Module Structure

```
┌─────────────────────────────────────────┐
│         Root Module (main.tf)           │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Provider Configuration           │ │
│  │  - AWS Provider                   │ │
│  │  - Region: us-east-1              │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Backend Configuration            │ │
│  │  - S3 or Terraform Cloud          │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────┐  ┌───────────────┐ │
│  │               │  │               │ │
│  │  VPC Module   │  │  EC2 Module   │ │
│  │               │  │               │ │
│  └───────┬───────┘  └───────┬───────┘ │
│          │                  │          │
└──────────┼──────────────────┼──────────┘
           │                  │
           ▼                  ▼
    ┌──────────────┐   ┌──────────────┐
    │ VPC Module   │   │ EC2 Module   │
    │              │   │              │
    │ Resources:   │   │ Resources:   │
    │ - VPC        │   │ - Instances  │
    │ - Subnets    │   │ - SG         │
    │ - IGW        │   │ - AMI Data   │
    │ - Routes     │   │              │
    │              │   │ Depends on:  │
    │ Outputs:     │   │ - VPC ID     │
    │ - VPC ID     │───┤ - Subnet IDs │
    │ - Subnet IDs │   │              │
    └──────────────┘   └──────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Security Layers                      │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Layer 1: Access Control                          │ │
│  │  - IAM Roles & Policies                           │ │
│  │  - Terraform Cloud Team Permissions               │ │
│  │  - GitHub Repository Access                       │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Layer 2: Network Security                        │ │
│  │  - VPC Isolation                                  │ │
│  │  - Security Groups (Ports 22, 80, 443)           │ │
│  │  - Public/Private Subnet Separation               │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Layer 3: Data Security                           │ │
│  │  - S3 Encryption at Rest (AES-256)               │ │
│  │  - S3 Versioning Enabled                          │ │
│  │  - S3 Public Access Blocked                       │ │
│  │  - Terraform Cloud Encrypted State                │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Layer 4: Secrets Management                      │ │
│  │  - Sensitive Variables Marked                     │ │
│  │  - .gitignore for .tfvars                         │ │
│  │  - Environment Variables in TF Cloud              │ │
│  │  - No Hardcoded Credentials                       │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Layer 5: Audit & Compliance                      │ │
│  │  - State History & Versioning                     │ │
│  │  - Run Logs in Terraform Cloud                    │ │
│  │  - Notifications for Changes                      │ │
│  │  - Resource Tagging                               │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌──────────┐
│Developer │
└────┬─────┘
     │
     │ 1. Write Code
     │
     ▼
┌─────────────┐
│ Local Files │
│ (.tf files) │
└────┬────────┘
     │
     │ 2. Git Push
     │
     ▼
┌──────────┐
│ GitHub   │
└────┬─────┘
     │
     │ 3. Webhook Trigger
     │
     ▼
┌──────────────────┐
│ Terraform Cloud  │
│ - Queue Plan     │
└────┬─────────────┘
     │
     │ 4. Fetch Code
     │
     ▼
┌──────────────────┐
│ Plan Execution   │
│ - Parse Config   │
│ - Load State     │
│ - Calculate Diff │
└────┬─────────────┘
     │
     │ 5. Display Plan
     │
     ▼
┌──────────────────┐
│ Manual Approval  │
│ (if required)    │
└────┬─────────────┘
     │
     │ 6. Confirm Apply
     │
     ▼
┌──────────────────┐
│ Apply Execution  │
│ - AWS API Calls  │
│ - Create/Update  │
│ - Save State     │
└────┬─────────────┘
     │
     │ 7. Provision
     │
     ▼
┌──────────────────┐
│ AWS Resources    │
│ - VPC            │
│ - EC2 Instances  │
└────┬─────────────┘
     │
     │ 8. Notification
     │
     ▼
┌──────────────────┐
│ Email/Slack      │
│ Notification     │
└──────────────────┘
```

## Deployment Pipeline

```
┌─────────────┐
│   Commit    │
│   to Git    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Automatic  │
│   Trigger   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Terraform  │
│    Plan     │
└──────┬──────┘
       │
       ├─── Success ───┐
       │               │
       └─── Failure ───┼──► Notification
                       │
                       ▼
                ┌─────────────┐
                │   Review    │
                │    Plan     │
                └──────┬──────┘
                       │
                       ├─── Approve ───┐
                       │               │
                       └─── Reject ────┼──► Stop
                                       │
                                       ▼
                                ┌─────────────┐
                                │  Terraform  │
                                │    Apply    │
                                └──────┬──────┘
                                       │
                                       ├─── Success ───┐
                                       │               │
                                       └─── Failure ───┼──► Rollback
                                                       │
                                                       ▼
                                                ┌─────────────┐
                                                │ Resources   │
                                                │  Deployed   │
                                                └──────┬──────┘
                                                       │
                                                       ▼
                                                ┌─────────────┐
                                                │Notification │
                                                │  (Success)  │
                                                └─────────────┘
```

---

**Note**: These diagrams provide a visual representation of the infrastructure, workflows, and security architecture implemented in this project.
