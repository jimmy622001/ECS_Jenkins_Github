# Local Development Guide

This guide provides instructions for setting up and working with the CICD pipeline in a local development environment.

## Prerequisites

1. Terraform v1.0.0 or newer
2. AWS CLI configured with appropriate credentials
3. Git

## Getting Started with Local State

This project is currently set up to use local Terraform state. This is suitable for initial development and testing. When you're ready to move to a team environment, follow the migration steps in the `TERRAFORM_STATE_MANAGEMENT.md` document.

## Initial Setup

### 1. Configure Environment Variables

Create a `.env` file in the repository root:

```
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_github_token=your-github-token
```

Source the file:

```bash
source .env
```

### 2. Set Up Development Environment

```bash
# Navigate to the dev environment directory
cd environments/dev

# Create a terraform.tfvars file from the example
cp terraform.tfvars.example terraform.tfvars

# Edit the terraform.tfvars file with your specific values
# vim terraform.tfvars   # Or use your preferred editor
```

### 3. Initialize and Apply Terraform

```bash
# Initialize Terraform with local state
terraform init

# See what changes will be made
terraform plan

# Apply the changes
terraform apply
```

## Working with the Dev Environment

### Testing the CICD Pipeline Locally

1. Make changes to your application code
2. Push to the `dev` branch
3. The Jenkins pipeline will:
   - Deploy to the dev subdomain (e.g., dev.yourdomain.com)
   - Run tests against the deployment
   - Notify you of the results

### Making Infrastructure Changes

If you need to make changes to the infrastructure:

1. Edit the relevant Terraform files
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes
4. Commit your changes to version control

## Migrating to Production

When your changes are tested and ready for production:

1. Create a pull request from `dev` to `main`
2. After approval, merge the PR
3. The Jenkins pipeline will:
   - Request manual approval before deploying to production
   - Deploy to the production environment (yourdomain.com)
   - Run post-deployment tests

## Troubleshooting

### Common Issues

1. **Terraform initialization error**: Make sure you're in the correct environment directory (dev or prod)
2. **AWS credential errors**: Verify your AWS credentials are properly configured
3. **Resource creation failures**: Check AWS quotas and permissions, review error logs
4. **Provider version conflicts**: If you encounter provider version errors, see the [Provider Version Management](./PROVIDER_VERSION_MANAGEMENT.md) guide

### Debug Tools

- Use `terraform validate` to check for configuration errors
- Use `terraform state list` to view managed resources
- Use `terraform state show [resource]` for detailed resource information

## Additional Resources

- [Official Terraform Documentation](https://www.terraform.io/docs/index.html)
- [AWS CLI Documentation](https://aws.amazon.com/cli/)
- See `TERRAFORM_STATE_MANAGEMENT.md` for instructions on migrating to remote state