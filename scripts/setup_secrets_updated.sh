#!/bin/bash

# Script to set up SENSITIVE information in AWS Secrets Manager
# Usage: ./setup_secrets.sh <environment> <aws-profile>

ENVIRONMENT=$1
AWS_PROFILE=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$AWS_PROFILE" ]; then
  echo "Usage: ./setup_secrets.sh <environment> <aws-profile>"
  echo "Example: ./setup_secrets.sh dev default"
  exit 1
fi

# Function to check if secret exists and update it, otherwise create it
function manage_secret {
  local secret_name=$1
  local description=$2
  local secret_string=$3

  # Check if secret exists
  if aws secretsmanager describe-secret --secret-id "$secret_name" --profile "$AWS_PROFILE" 2>&1 | grep -q 'ResourceNotFoundException'; then
    # Create a new secret
    echo "Creating secret: $secret_name"
    aws secretsmanager create-secret \
      --name "$secret_name" \
      --description "$description" \
      --secret-string "$secret_string" \
      --profile "$AWS_PROFILE"
  else
    # Update existing secret
    echo "Updating existing secret: $secret_name"
    aws secretsmanager update-secret \
      --secret-id "$secret_name" \
      --description "$description" \
      --secret-string "$secret_string" \
      --profile "$AWS_PROFILE"
  fi
}

# Determine project name based on environment
if [ "$ENVIRONMENT" == "dev" ]; then
  PROJECT_NAME="ecs-jenkins-dev"
elif [ "$ENVIRONMENT" == "prod" ]; then
  PROJECT_NAME="ecs-jenkins-production"
elif [ "$ENVIRONMENT" == "dr-pilot-light" ]; then
  PROJECT_NAME="ecs-jenkins-dr"
else
  echo "Unknown environment: $ENVIRONMENT"
  echo "Supported environments: dev, prod, dr-pilot-light"
  exit 1
fi

echo "=============================================================================="
echo "HYBRID APPROACH TO TERRAFORM VARIABLES:"
echo "This script is for SENSITIVE information ONLY - to be stored in AWS Secrets Manager"
echo "NON-SENSITIVE configuration (like instance sizes, etc.) belongs in terraform.tfvars"
echo "=============================================================================="
echo ""

# Database credentials
read -sp "Enter database username: " DB_USERNAME
echo ""
read -sp "Enter database password: " DB_PASSWORD
echo ""

# Grafana credentials
read -p "Enter Grafana admin username: " GRAFANA_ADMIN_USER
read -sp "Enter Grafana admin password: " GRAFANA_ADMIN_PASSWORD
echo ""

# SSH key information
read -p "Enter SSH key name: " KEY_NAME

# AWS configuration
read -p "Enter AWS profile to use: " TF_AWS_PROFILE

# Domain configuration
read -p "Enter domain name: " DOMAIN_NAME
read -p "Enter failover domain name (for DR): " FAILOVER_DOMAIN

# Network security
echo "Enter trusted IP addresses/ranges (comma-separated, e.g., 10.0.0.0/8,192.168.1.0/24): "
read -r TRUSTED_IPS
IFS=',' read -ra TRUSTED_IP_ARRAY <<< "$TRUSTED_IPS"
TRUSTED_IP_JSON=$(printf '%s\n' "${TRUSTED_IP_ARRAY[@]}" | jq -R . | jq -s .)

# Blocked IP addresses
echo "Enter blocked IP addresses (comma-separated): "
read -r BLOCKED_IPS
IFS=',' read -ra BLOCKED_IP_ARRAY <<< "$BLOCKED_IPS"
BLOCKED_IP_JSON=$(printf '%s\n' "${BLOCKED_IP_ARRAY[@]}" | jq -R . | jq -s .)

# API keys and tokens (if applicable)
read -p "Does this environment use any API keys or tokens? (y/n): " USE_API_KEYS
API_KEYS_JSON="{}"
if [[ "$USE_API_KEYS" == "y" || "$USE_API_KEYS" == "Y" ]]; then
  API_KEYS_ARRAY=()
  echo "Enter API key details (leave name blank when done): "
  while true; do
    read -p "API key name (or blank to finish): " API_KEY_NAME
    [[ -z "$API_KEY_NAME" ]] && break
    read -sp "API key value: " API_KEY_VALUE
    echo ""
    API_KEYS_ARRAY+=("\"$API_KEY_NAME\":\"$API_KEY_VALUE\"")
  done

  # Create JSON from API keys
  if [ ${#API_KEYS_ARRAY[@]} -gt 0 ]; then
    API_KEYS_JSON="{${API_KEYS_ARRAY[*]}}"
  fi
fi

# Create JSON for DB credentials
DB_CREDS_JSON='{"username":"'"$DB_USERNAME"'","password":"'"$DB_PASSWORD"'"}'

# Create JSON for Grafana credentials
GRAFANA_CREDS_JSON='{"admin_user":"'"$GRAFANA_ADMIN_USER"'","admin_password":"'"$GRAFANA_ADMIN_PASSWORD"'"}'

# Create JSON for SSH key
SSH_KEY_JSON='{"key_name":"'"$KEY_NAME"'"}'

# Create JSON for AWS configuration
AWS_CONFIG_JSON='{"aws_profile":"'"$TF_AWS_PROFILE"'"}'

# Create JSON for domain configuration
DOMAIN_CONFIG_JSON='{"domain_name":"'"$DOMAIN_NAME"'","failover_domain":"'"$FAILOVER_DOMAIN"'"}'

# Create JSON for network security
NETWORK_SECURITY_JSON='{"trusted_ips":'"$TRUSTED_IP_JSON"',"blocked_ip_addresses":'"$BLOCKED_IP_JSON"'}'

# Manage the secrets in AWS Secrets Manager
manage_secret "$PROJECT_NAME-$ENVIRONMENT-db-credentials" "Database credentials for $ENVIRONMENT environment" "$DB_CREDS_JSON"
manage_secret "$PROJECT_NAME-$ENVIRONMENT-grafana-credentials" "Grafana credentials for $ENVIRONMENT environment" "$GRAFANA_CREDS_JSON"
manage_secret "$PROJECT_NAME-$ENVIRONMENT-ssh-key" "SSH key information for $ENVIRONMENT environment" "$SSH_KEY_JSON"
manage_secret "$PROJECT_NAME-$ENVIRONMENT-network-security" "Network security settings for $ENVIRONMENT environment" "$NETWORK_SECURITY_JSON"
manage_secret "$PROJECT_NAME-$ENVIRONMENT-aws-config" "AWS configuration for $ENVIRONMENT environment" "$AWS_CONFIG_JSON"
manage_secret "$PROJECT_NAME-$ENVIRONMENT-domain-config" "Domain configuration for $ENVIRONMENT environment" "$DOMAIN_CONFIG_JSON"

# Create API keys secret if necessary
if [ "$API_KEYS_JSON" != "{}" ]; then
  manage_secret "$PROJECT_NAME-$ENVIRONMENT-api-keys" "API keys for $ENVIRONMENT environment" "$API_KEYS_JSON"
fi

echo "Secrets created/updated successfully for $ENVIRONMENT environment."
echo ""
echo "IMPORTANT: Remember that instance sizes and other operational parameters should"
echo "be managed in terraform.tfvars files, not in AWS Secrets Manager."
echo ""
echo "The following secrets were configured:"
echo "- $PROJECT_NAME-$ENVIRONMENT-db-credentials"
echo "- $PROJECT_NAME-$ENVIRONMENT-grafana-credentials"
echo "- $PROJECT_NAME-$ENVIRONMENT-ssh-key"
echo "- $PROJECT_NAME-$ENVIRONMENT-network-security"
echo "- $PROJECT_NAME-$ENVIRONMENT-aws-config"
echo "- $PROJECT_NAME-$ENVIRONMENT-domain-config"
if [ "$API_KEYS_JSON" != "{}" ]; then
  echo "- $PROJECT_NAME-$ENVIRONMENT-api-keys"
fi