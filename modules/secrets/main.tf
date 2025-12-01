# This module provides a consistent interface for secret values
# It can use either AWS Secrets Manager (for production) or local values (for POC/Dev)

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use for credentials"
  type        = string
}

variable "use_aws_secrets" {
  description = "Whether to use AWS Secrets Manager or local values"
  type        = bool
  default     = false
}

# Local variables - only used when use_aws_secrets = false
variable "local_db_username" {
  description = "Database username (only used when use_aws_secrets = false)"
  type        = string
  default     = "db_admin"
  sensitive   = true
}

variable "local_db_password" {
  description = "Database password (only used when use_aws_secrets = false)"
  type        = string
  default     = "dummy_password_change_me"
  sensitive   = true
}

variable "local_db_name" {
  description = "Database name (only used when use_aws_secrets = false)"
  type        = string
  default     = "application_db"
}

variable "local_grafana_admin_user" {
  description = "Grafana admin username (only used when use_aws_secrets = false)"
  type        = string
  default     = "admin"
}

variable "local_grafana_admin_password" {
  description = "Grafana admin password (only used when use_aws_secrets = false)"
  type        = string
  default     = "admin_password_change_me"
  sensitive   = true
}

variable "local_key_name" {
  description = "SSH key name (only used when use_aws_secrets = false)"
  type        = string
  default     = "dummy-ssh-key"
}

variable "local_trusted_ips" {
  description = "List of trusted IP addresses/ranges (only used when use_aws_secrets = false)"
  type        = list(string)
  default     = ["10.0.0.0/16", "192.168.1.0/24"]
}

variable "local_blocked_ip_addresses" {
  description = "List of IP addresses to block (only used when use_aws_secrets = false)"
  type        = list(string)
  default     = ["198.51.100.0/24"]
}

variable "local_domain_name" {
  description = "Domain name (only used when use_aws_secrets = false)"
  type        = string
  default     = "dev.example.com"
}

variable "local_aws_profile" {
  description = "AWS profile (only used when use_aws_secrets = false)"
  type        = string
  default     = "default"
}

# Configure AWS provider for accessing Secrets Manager
provider "aws" {
  alias   = "secrets"
  region  = var.aws_region
  profile = var.aws_profile
}

# Only create these data sources if use_aws_secrets = true
data "aws_secretsmanager_secret" "db_credentials" {
  count    = var.use_aws_secrets ? 1 : 0
  provider = aws.secrets
  name     = "${var.project_name}-${var.environment}-db-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  count     = var.use_aws_secrets ? 1 : 0
  provider  = aws.secrets
  secret_id = var.use_aws_secrets ? data.aws_secretsmanager_secret.db_credentials[0].id : null
}

data "aws_secretsmanager_secret" "grafana_credentials" {
  count    = var.use_aws_secrets ? 1 : 0
  provider = aws.secrets
  name     = "${var.project_name}-${var.environment}-grafana-credentials"
}

data "aws_secretsmanager_secret_version" "grafana_credentials" {
  count     = var.use_aws_secrets ? 1 : 0
  provider  = aws.secrets
  secret_id = var.use_aws_secrets ? data.aws_secretsmanager_secret.grafana_credentials[0].id : null
}

data "aws_secretsmanager_secret" "ssh_key" {
  count    = var.use_aws_secrets ? 1 : 0
  provider = aws.secrets
  name     = "${var.project_name}-${var.environment}-ssh-key"
}

data "aws_secretsmanager_secret_version" "ssh_key" {
  count     = var.use_aws_secrets ? 1 : 0
  provider  = aws.secrets
  secret_id = var.use_aws_secrets ? data.aws_secretsmanager_secret.ssh_key[0].id : null
}

data "aws_secretsmanager_secret" "network_security" {
  count    = var.use_aws_secrets ? 1 : 0
  provider = aws.secrets
  name     = "${var.project_name}-${var.environment}-network-security"
}

data "aws_secretsmanager_secret_version" "network_security" {
  count     = var.use_aws_secrets ? 1 : 0
  provider  = aws.secrets
  secret_id = var.use_aws_secrets ? data.aws_secretsmanager_secret.network_security[0].id : null
}

data "aws_secretsmanager_secret" "security_settings" {
  count    = var.use_aws_secrets ? 1 : 0
  provider = aws.secrets
  name     = "${var.project_name}-${var.environment}-security-settings"
}

data "aws_secretsmanager_secret_version" "security_settings" {
  count     = var.use_aws_secrets ? 1 : 0
  provider  = aws.secrets
  secret_id = var.use_aws_secrets ? data.aws_secretsmanager_secret.security_settings[0].id : null
}

data "aws_secretsmanager_secret" "aws_config" {
  count    = var.use_aws_secrets ? 1 : 0
  provider = aws.secrets
  name     = "${var.project_name}-${var.environment}-aws-config"
}

data "aws_secretsmanager_secret_version" "aws_config" {
  count     = var.use_aws_secrets ? 1 : 0
  provider  = aws.secrets
  secret_id = var.use_aws_secrets ? data.aws_secretsmanager_secret.aws_config[0].id : null
}

data "aws_secretsmanager_secret" "domain_config" {
  count    = var.use_aws_secrets ? 1 : 0
  provider = aws.secrets
  name     = "${var.project_name}-${var.environment}-domain-config"
}

data "aws_secretsmanager_secret_version" "domain_config" {
  count     = var.use_aws_secrets ? 1 : 0
  provider  = aws.secrets
  secret_id = var.use_aws_secrets ? data.aws_secretsmanager_secret.domain_config[0].id : null
}

locals {
  # Parse secrets from AWS Secrets Manager or use local values
  db_credentials = var.use_aws_secrets ? jsondecode(data.aws_secretsmanager_secret_version.db_credentials[0].secret_string) : {
    username = var.local_db_username
    password = var.local_db_password
    name     = var.local_db_name
  }

  grafana_credentials = var.use_aws_secrets ? jsondecode(data.aws_secretsmanager_secret_version.grafana_credentials[0].secret_string) : {
    admin_user     = var.local_grafana_admin_user
    admin_password = var.local_grafana_admin_password
  }

  ssh_key = var.use_aws_secrets ? jsondecode(data.aws_secretsmanager_secret_version.ssh_key[0].secret_string) : {
    key_name = var.local_key_name
  }

  network_security = var.use_aws_secrets ? jsondecode(data.aws_secretsmanager_secret_version.network_security[0].secret_string) : {
    trusted_ips = var.local_trusted_ips
  }

  security_settings = var.use_aws_secrets ? jsondecode(data.aws_secretsmanager_secret_version.security_settings[0].secret_string) : {
    blocked_ip_addresses = var.local_blocked_ip_addresses
  }

  aws_config = var.use_aws_secrets ? jsondecode(data.aws_secretsmanager_secret_version.aws_config[0].secret_string) : {
    aws_profile = var.local_aws_profile
  }

  domain_config = var.use_aws_secrets ? jsondecode(data.aws_secretsmanager_secret_version.domain_config[0].secret_string) : {
    domain_name = var.local_domain_name
  }
}

# Output variables
output "db_username" {
  description = "Database username"
  value       = local.db_credentials.username
  sensitive   = true
}

output "db_password" {
  description = "Database password"
  value       = local.db_credentials.password
  sensitive   = true
}

output "db_name" {
  description = "Database name"
  value       = lookup(local.db_credentials, "name", var.local_db_name)
}

output "grafana_admin_user" {
  description = "Grafana admin username"
  value       = local.grafana_credentials.admin_user
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = local.grafana_credentials.admin_password
  sensitive   = true
}

output "key_name" {
  description = "SSH key name"
  value       = local.ssh_key.key_name
}

output "trusted_ips" {
  description = "Trusted IP addresses/ranges"
  value       = local.network_security.trusted_ips
}

output "blocked_ip_addresses" {
  description = "IP addresses to block"
  value       = local.security_settings.blocked_ip_addresses
}

output "aws_profile" {
  description = "AWS profile"
  value       = local.aws_config.aws_profile
}

output "domain_name" {
  description = "Domain name"
  value       = local.domain_config.domain_name
}

output "secrets_mode" {
  description = "Mode of secrets retrieval"
  value       = var.use_aws_secrets ? "AWS Secrets Manager" : "Local Values (POC Mode)"
}