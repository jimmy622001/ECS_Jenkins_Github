# Environment Deployment Guide

This guide explains how to properly deploy and manage different environments in the ECS Jenkins GitHub project.

## Table of Contents
1. [Environment Structure](#environment-structure)
2. [Deployment Instructions](#deployment-instructions)
3. [Environment Variables](#environment-variables)
4. [Workspaces](#workspaces)
5. [Common Deployment Scenarios](#common-deployment-scenarios)
6. [Environment Destruction](#environment-destruction)

## Environment Structure

The project uses a directory-based approach for managing different environments:

```
environments/
├── dev/
│   ├── main.tf          # Dev environment configuration
│   ├── variables.tf     # Variables declaration
│   └── terraform.tfvars # Dev-specific values
├── prod/
│   ├── main.tf          # Production environment configuration
│   ├── variables.tf     # Variables declaration
│   └── terraform.tfvars # Production-specific values
└── dr-pilot-light/
    ├── main.tf          # DR environment configuration
    ├── variables.tf     # Variables declaration
    └── terraform.tfvars # DR-specific values
```

Each environment directory contains its own Terraform configuration and variable definitions.

## Deployment Instructions

### Prerequisites

- Terraform 1.0.0 or newer
- AWS CLI configured with appropriate permissions
- GitHub access token with repo and admin:repo_hook permissions

### Deploying an Environment

1. **Navigate to the desired environment directory**:

   ```bash
   # For development environment
   cd environments/dev

   # For production environment
   cd environments/prod

   # For DR environment
   cd environments/dr-pilot-light
   ```

2. **Initialize Terraform**:

   ```bash
   terraform init
   ```

3. **Plan the deployment**:

   ```bash
   terraform plan
   ```

4. **Apply the configuration**:

   ```bash
   terraform apply
   ```

> **Note**: You do not need to specify a tfvars file using `-var-file` because each environment directory contains its own `terraform.tfvars` that is automatically loaded when running Terraform commands in that directory.

## Environment Variables

Each environment has its own set of variables defined in `terraform.tfvars`. Some key differences between environments:

| Variable              | Dev                     | Production              | DR                      |
|-----------------------|-------------------------|------------------------|-------------------------|
| instance_type         | t3.small                | t3.large               | t3.medium               |
| min_instance_count    | 1                       | 2                      | 0-1 (pilot light)       |
| vpc_cidr              | 10.2.0.0/16             | 10.1.0.0/16            | 10.3.0.0/16             |
| use_spot_instances    | true                    | false                  | true                    |
| patch_schedule        | cron(0 4 ? * SAT *)     | cron(0 3 ? * MON *)    | cron(0 3 ? * WED *)     |
| trusted_ips           | 0.0.0.0/0 (open)        | [Corporate IPs only]   | [Corporate IPs only]    |

## Workspaces

If you need to maintain multiple instances of the same environment type, you can use Terraform workspaces:

```bash
# Create a new workspace
terraform workspace new dev-feature-x

# Select an existing workspace
terraform workspace select dev-feature-x

# Apply changes to the selected workspace
terraform apply
```

## Common Deployment Scenarios

### Initial Deployment

```bash
cd environments/dev
terraform init
terraform apply
```

### Update Existing Environment

```bash
cd environments/prod
terraform init
terraform plan  # Review changes
terraform apply
```

### Applying Specific Module Changes

```bash
cd environments/dev
terraform apply -target=module.network
```

### Creating a Plan File for Review

```bash
cd environments/prod
terraform plan -out=tfplan
# Review with team
terraform apply tfplan
```

## Environment Destruction

**Warning**: This will permanently delete all resources.

```bash
cd environments/dev
terraform destroy
```

To destroy specific resources:

```bash
cd environments/dev
terraform destroy -target=module.ec2
```