# This file provides compatibility between different variable naming conventions
# Used to bridge between secrets.tf and dummy_secrets.tf

locals {
  # These aliases map the variable names expected in secrets.tf to those defined in dummy_secrets.tf
  dummy_db_credentials      = local.dummy_db_creds
  dummy_grafana_credentials = local.dummy_grafana_creds
  dummy_ssh_key             = local.dummy_ssh_key_info
  # The following variables match their names, included for completeness
  # dummy_network_security   = local.dummy_network_security
  # dummy_security_settings  = local.dummy_security_settings
  # dummy_aws_config         = local.dummy_aws_config
  # dummy_domain_config      = local.dummy_domain_config
}