# Secrets Management

This project uses AWS Secrets Manager for handling all sensitive information. No secrets or credentials are stored directly in the Terraform code or in environment files.

## Required Secrets

Before deploying the infrastructure with Terraform, you must set up these secrets in AWS Secrets Manager:

### 1. Database Credentials
- **Secret Name**: `<project_name>-<environment>-db-credentials`
- **Content**:
  ```json
  {
    "username": "dbadmin",
    "password": "YourStrongPassword"
  }
  ```

### 2. Grafana Credentials
- **Secret Name**: `<project_name>-<environment>-grafana-credentials`
- **Content**:
  ```json
  {
    "admin_user": "admin",
    "admin_password": "YourGrafanaPassword"
  }
  ```

### 3. SSH Key
- **Secret Name**: `<project_name>-<environment>-ssh-key`
- **Content**:
  ```json
  {
    "key_name": "jenkins-ssh-key",
    "private_key": "ACTUAL_PRIVATE_KEY_CONTENT"
  }
  ```

### 4. Network Security
- **Secret Name**: `<project_name>-<environment>-network-security`
- **Content**:
  ```json
  {
    "trusted_ips": ["203.0.113.1/32", "198.51.100.0/24"]
  }
  ```

### 5. Security Settings
- **Secret Name**: `<project_name>-<environment>-security-settings`
- **Content**:
  ```json
  {
    "waf_rate_limit": 1000,
    "max_request_size": 10485760,
    "enable_security_hub": false,
    "enable_guardduty": true
  }
  ```

### 6. AWS Config
- **Secret Name**: `<project_name>-<environment>-aws-config`
- **Content**:
  ```json
  {
    "aws_account_id": "123456789012",
    "cross_account_role": "arn:aws:iam::123456789012:role/CrossAccountAccessRole"
  }
  ```

### 7. Domain Config
- **Secret Name**: `<project_name>-<environment>-domain-config`
- **Content**:
  ```json
  {
    "domain_name": "dev.yourdomain.com",
    "enable_https": true,
    "certificate_arn": "arn:aws:acm:region:account-id:certificate/certificate-id"
  }
  ```

## Setting Up Secrets

You can set up these secrets using:

1. **AWS Console**: Create secrets manually through the AWS Secrets Manager console
2. **Setup Script**: Use the provided setup scripts:
   - `setup_aws_secrets.sh` (Linux/Mac)
   - `setup_aws_secrets.bat` (Windows)

Before running the scripts, edit them to include your specific values.

## Accessing Secrets in Terraform

The `secrets.tf` file contains the logic to securely access these secrets:

1. It retrieves the secrets from AWS Secrets Manager
2. It decodes the JSON contents into usable variables
3. It makes the values available to Terraform modules

Example:
```hcl
data "aws_secretsmanager_secret" "db_credentials" {
  provider = aws.secrets
  name = "${var.project_name}-${var.environment}-db-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
  db_username = local.db_creds.username
  db_password = local.db_creds.password
}
```

## Security Considerations

1. **IAM Permissions**: Ensure that the IAM role or user running Terraform has appropriate permissions to read secrets
2. **Secret Rotation**: Consider setting up automatic rotation for secrets like database passwords
3. **Access Logging**: Enable CloudTrail logging for AWS Secrets Manager actions
4. **Resource Policies**: Apply resource policies to restrict who can access specific secrets
5. **Encryption**: All secrets are automatically encrypted at rest by AWS Secrets Manager

## Best Practices

1. **Never hardcode secrets** in Terraform files or commit them to Git
2. **Use separate secrets** for each environment (dev, prod, dr)
3. **Limit access** to secrets based on the principle of least privilege
4. **Regularly audit** who has access to your secrets
5. **Monitor and alert** on unexpected access patterns to sensitive information