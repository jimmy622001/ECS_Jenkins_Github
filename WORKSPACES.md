# Terraform Workspaces for ECS Jenkins Deployment

This project uses Terraform workspaces to manage multiple environments (dev, prod, dr). This document explains how to use them.

## Available Workspaces

1. **dev** - Development environment
2. **prod** - Production environment
3. **dr** - Disaster Recovery environment

## Getting Started

### 1. Initialize Terraform

```bash
terraform init
```

### 2. List available workspaces

```bash
terraform workspace list
```

### 3. Create or select a workspace

For development:
```bash
terraform workspace new dev
# or if it already exists
terraform workspace select dev
```

For production:
```bash
terraform workspace new prod
# or if it already exists
terraform workspace select prod
```

For disaster recovery:
```bash
terraform workspace new dr
# or if it already exists
terraform workspace select dr
```

### 4. Apply Configuration with Workspace-Specific Variables

Each environment has its own directory under `environments/` with a `terraform.tfvars` file:
- `environments/dev/terraform.tfvars` - Development variables
- `environments/prod/terraform.tfvars` - Production variables
- `environments/dr/terraform.tfvars` - Disaster Recovery variables

To apply the configuration for the current workspace, first ensure you're in the root directory of your Terraform project, then run:

```bash
# For dev
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars

# For prod
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars

# For dr
terraform plan -var-file=environments/dr/terraform.tfvars
terraform apply -var-file=environments/dr/terraform.tfvars
```

Or if you prefer to use the `-chdir` flag to specify the working directory:

```bash
# For dev
terraform -chdir="D:\Terraform Playground\ECS_Jenkins_Github" plan -var-file=environments/dev/terraform.tfvars
```

## Workspace-Specific Behaviors

### Development (dev)
- Uses smaller instance types
- Spot instances enabled for cost savings
- Minimal monitoring
- Lower instance counts

### Production (prod)
- Larger instance types
- No spot instances for stability
- Full monitoring enabled
- Higher availability with multiple instances

### Disaster Recovery (dr)
- Medium instance types
- Spot instances enabled for cost savings
- Minimal monitoring by default (can be enabled)
- Database restored from production snapshot
- Can be run in a different region

## Important Notes

1. **State Isolation**: Each workspace maintains its own state file, so changes in one workspace won't affect others.

2. **DR Environment**: 
   - By default, the DR environment is set up as a "pilot light" with minimal resources
   - Database is not created by default (set `create_database = true` if needed)
   - Monitoring can be enabled with `enable_dr_monitoring = true`

3. **Variables**: Always check the workspace-specific `.tfvars` file before applying changes.

4. **Backup**: Regularly back up your Terraform state files, especially for production environments.

## Example Workflow

### Deploying to Production

```bash
# Switch to prod workspace
terraform workspace select prod

# Plan the changes
terraform plan -var-file=terraform.tfvars.prod

# Apply the changes
terraform apply -var-file=terraform.tfvars.prod
```

### Setting up DR Environment

1. First, create a database snapshot in production
2. Update `terraform.tfvars.dr` with the snapshot ARN
3. Deploy the DR environment:

```bash
# Switch to dr workspace
terraform workspace select dr

# Initialize (first time only)
terraform init

# Apply DR configuration
terraform apply -var-file=terraform.tfvars.dr
```

## Troubleshooting

If you encounter issues with workspaces:

1. Verify current workspace:
   ```bash
   terraform workspace show
   ```

2. List all workspaces:
   ```bash
   terraform workspace list
   ```

3. Delete a workspace (be careful!):
   ```bash
   terraform workspace select default
   terraform workspace delete <workspace_name>
   ```

4. If you get state lock errors:
   ```bash
   terraform force-unlock <LOCK_ID>
   ```
