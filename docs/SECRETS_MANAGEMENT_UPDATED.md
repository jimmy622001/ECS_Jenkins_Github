# Secrets Management

This document explains the approach to managing secrets in both POC/development and production environments.

## Overview

The infrastructure uses a dual-mode approach to handle sensitive information:

1. **POC/Development Mode** - Uses local dummy values defined in code
2. **Production Mode** - Uses AWS Secrets Manager for secure storage

The system seamlessly switches between these modes using a single configuration flag.

## How It Works

### Switching Between Modes

The entire infrastructure uses a single variable to control where secrets come from:

```hcl
variable "use_aws_secrets" {
  description = "Set to true to use AWS Secrets Manager, false to use dummy values"
  type        = bool
  default     = false  # Default to dummy values for easier POC setup
}
```

### File Structure

- **dummy_secrets.tf** - Contains dummy values for local development/POC
- **secrets.tf** - Configures AWS Secrets Manager integration when needed

### Using in POC/Development

During POC/development:

1. The `use_aws_secrets` variable is set to `false` (default)
2. Terraform uses the dummy values defined in `dummy_secrets.tf`
3. No AWS Secrets Manager resources need to exist

This allows you to:
- Run `terraform plan` and `terraform apply` without setting up AWS Secrets
- Test infrastructure code without exposing real secrets
- Quickly iterate on infrastructure without AWS Secrets Manager overhead

### Using in Production

When moving to production:

1. Set up the required secrets in AWS Secrets Manager using provided scripts
2. Set `use_aws_secrets` to `true` in your tfvars file
3. Terraform will now use the real secrets from AWS Secrets Manager

## Required Secrets

The following secrets are required for the infrastructure:

| Secret Name | Description | Format |
|-------------|-------------|--------|
| `{project}-{env}-db-credentials` | Database credentials | JSON: `{"username": "...", "password": "...", "dbname": "..."}` |
| `{project}-{env}-grafana-credentials` | Grafana admin credentials | JSON: `{"admin_user": "...", "admin_password": "..."}` |
| `{project}-{env}-ssh-key` | SSH key for EC2 instances | JSON: `{"key_name": "...", "public_key": "...", "private_key": "..."}` |
| `{project}-{env}-network-security` | Network security settings | JSON: `{"trusted_ips": ["..."], "vpn_cidrs": ["..."], "office_ip_ranges": ["..."]}` |
| `{project}-{env}-security-settings` | Security settings | JSON: `{"waf_ip_block_list": ["..."], "notification_email": "...", "waf_rate_limit": 1000, "max_request_size": 10485760, "enable_security_hub": false, "enable_guardduty": true}` |
| `{project}-{env}-aws-config` | AWS-specific config | JSON: `{"aws_account_id": "...", "cross_account_role": "...", "backup_retention_period": "7", "cross_region_backup_bucket": "..."}` |
| `{project}-{env}-domain-config` | Domain and certificate | JSON: `{"domain_name": "...", "enable_https": true, "certificate_arn": "..."}` |

## Setting Up AWS Secrets Manager

To set up AWS Secrets Manager (for production use):

1. Use the provided setup scripts:
   ```bash
   # For Linux/Mac
   ./setup_aws_secrets.sh
   
   # For Windows
   setup_aws_secrets.bat
   ```
   
2. Edit these scripts to use your actual secure values before running them

3. Set `use_aws_secrets = true` in your tfvars file:
   ```hcl
   use_aws_secrets = true
   ```

## Best Practices

1. **Never commit real secrets** to version control
2. Always use dummy values for development/testing
3. Set up proper IAM permissions for accessing AWS Secrets Manager
4. Rotate secrets regularly
5. Use separate secrets for each environment
6. Limit who can view/manage production secrets

## Gradual Migration

When moving from POC to production:

1. Set up and test AWS Secrets Manager in a dev environment first
2. Validate that the infrastructure works with real secrets
3. Then migrate other environments one at a time
4. Finally, remove any dummy values that might have been committed to code

## Dummy Value Security

Despite using dummy values for development, always follow these practices:

1. Use different dummy values from any real values
2. Don't use real-looking passwords or keys
3. Structure dummy values to match the expected format in production
4. Clearly mark all dummy values as "dummy" or "change_me"