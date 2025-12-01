#!/bin/bash
# Script to create the required AWS Secrets Manager secrets

# Configuration - Update these values
PROJECT_NAME="ecs-jenkins-dev"
ENVIRONMENT="dev"
AWS_REGION="us-east-1"
AWS_PROFILE="default" # Modify this to use your specific AWS profile if needed

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Function to create or update a secret
create_or_update_secret() {
    local name=$1
    local value=$2
    
    # Check if secret already exists
    if aws secretsmanager describe-secret --secret-id "$name" --region "$AWS_REGION" --profile "$AWS_PROFILE" &> /dev/null; then
        echo "Secret $name already exists, updating..."
        aws secretsmanager update-secret --secret-id "$name" --secret-string "$value" --region "$AWS_REGION" --profile "$AWS_PROFILE"
    else
        echo "Creating secret $name..."
        aws secretsmanager create-secret --name "$name" --secret-string "$value" --region "$AWS_REGION" --profile "$AWS_PROFILE"
    fi
}

# 1. Database Credentials
DB_CREDENTIALS='{
    "username": "dbadmin",
    "password": "YourStrongPasswordHere123!"
}'
create_or_update_secret "${PROJECT_NAME}-${ENVIRONMENT}-db-credentials" "$DB_CREDENTIALS"

# 2. Grafana Credentials
GRAFANA_CREDENTIALS='{
    "admin_user": "admin",
    "admin_password": "YourStrongGrafanaPasswordHere123!"
}'
create_or_update_secret "${PROJECT_NAME}-${ENVIRONMENT}-grafana-credentials" "$GRAFANA_CREDENTIALS"

# 3. SSH Key
SSH_KEY='{
    "key_name": "jenkins-ssh-key",
    "private_key": "PLACEHOLDER_FOR_ACTUAL_PRIVATE_KEY_CONTENT"
}'
create_or_update_secret "${PROJECT_NAME}-${ENVIRONMENT}-ssh-key" "$SSH_KEY"

# 4. Network Security
NETWORK_SECURITY='{
    "trusted_ips": ["203.0.113.1/32", "198.51.100.0/24"]
}'
create_or_update_secret "${PROJECT_NAME}-${ENVIRONMENT}-network-security" "$NETWORK_SECURITY"

# 5. Security Settings
SECURITY_SETTINGS='{
    "waf_rate_limit": 1000,
    "max_request_size": 10485760,
    "enable_security_hub": false,
    "enable_guardduty": true
}'
create_or_update_secret "${PROJECT_NAME}-${ENVIRONMENT}-security-settings" "$SECURITY_SETTINGS"

# 6. AWS Config
AWS_CONFIG='{
    "aws_account_id": "123456789012",
    "cross_account_role": "arn:aws:iam::123456789012:role/CrossAccountAccessRole"
}'
create_or_update_secret "${PROJECT_NAME}-${ENVIRONMENT}-aws-config" "$AWS_CONFIG"

# 7. Domain Config
DOMAIN_CONFIG='{
    "domain_name": "dev.yourdomain.com",
    "enable_https": true,
    "certificate_arn": "arn:aws:acm:region:account-id:certificate/certificate-id"
}'
create_or_update_secret "${PROJECT_NAME}-${ENVIRONMENT}-domain-config" "$DOMAIN_CONFIG"

echo "All secrets have been created successfully!"