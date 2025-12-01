# ECS with Jenkins CI/CD - POC Guide

This guide will help you run the Terraform code in POC mode without needing to set up AWS Secrets Manager.

## Running in POC Mode

The infrastructure is designed to work in two modes:
1. **POC Mode**: Uses local values for sensitive information (passwords, keys, etc.)
2. **Production Mode**: Uses AWS Secrets Manager for sensitive information

By default, the infrastructure is set to run in POC Mode.

## Quick Start

1. Copy the environment-specific example variables:
   ```
   cd environments/dev
   copy terraform.tfvars.example terraform.tfvars
   ```

2. Ensure the `local.auto.tfvars` file in your environment directory contains any sensitive values you want to override.

3. Initialize and apply the Terraform configuration:
   ```
   terraform init
   terraform plan
   terraform apply
   ```

## Modular Deployment

If you want to deploy components separately:

1. For network infrastructure only:
   ```
   cd environments/dev
   deploy_network.bat  # or .sh on Linux/Mac
   ```

2. For ECS cluster only:
   ```
   cd environments/dev
   deploy_ecs.bat  # or .sh on Linux/Mac
   ```

3. For CI/CD components only:
   ```
   cd environments/dev
   deploy_cicd.bat  # or .sh on Linux/Mac
   ```

4. For monitoring components only:
   ```
   cd environments/dev
   deploy_monitoring.bat  # or .sh on Linux/Mac
   ```

## Transitioning to Production

When you're ready to move to production:

1. Set up the required AWS Secrets Manager secrets (use the `setup_aws_secrets.sh` script as a guide)
2. Update your terraform.tfvars file to set `use_aws_secrets = true`
3. Apply the configuration again

## Sensitive Information

In POC mode, sensitive information is stored in:
- `environments/[env]/local.auto.tfvars`
- The secrets module's default values

In production mode:
- All sensitive information should be stored in AWS Secrets Manager
- No sensitive information should be in any Terraform files

See `docs/SECRETS_MANAGEMENT.md` for more details on secrets management.