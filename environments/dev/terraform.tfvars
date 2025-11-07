# AWS Configuration
aws_region   = "us-east-1"
aws_profile  = "dev"
project_name = "ecs-jenkins-dev"

# Network Configuration (different CIDR ranges from prod)
vpc_cidr              = "10.2.0.0/16"
public_subnet_cidrs   = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs  = ["10.2.3.0/24", "10.2.4.0/24"]
database_subnet_cidrs = ["10.2.5.0/24", "10.2.6.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"] # Fewer AZs for dev

# Environment
environment = "dev"

# Database Configuration (different credentials from prod)
db_username = "devdbadmin"
db_password = "DevSecurePass123!" # For PoC only - use AWS Secrets Manager in real deployment
db_name     = "devappdb"

# Application Configuration
container_image = "nginx:alpine"
container_port  = 8080

# Jenkins Configuration
key_name              = "dev-key"
jenkins_instance_type = "t3.small" # Smaller instance for dev/PoC
jenkins_role_name     = "jenkins-ecs-role-dev"
spot_price            = "0.04"
jenkins_version       = "2.222.1"

# Security - More permissive for dev/PoC
trusted_ips            = ["0.0.0.0/0"]        # WARNING: For PoC only - restrict in production
grafana_admin_password = "DevGrafanaPass123!" # For PoC only - use AWS Secrets Manager in real deployment
grafana_admin_user     = "devadmin"
domain_name            = "dev.example.com"    # Update with your dev domain or use placeholder

# Development EC2 configuration (smaller instances for PoC)
ec2_instance_type           = "t3.small"
min_instance_count          = 1
max_instance_count          = 2
desired_instance_count      = 1
root_volume_size            = 15
patch_schedule              = "cron(0 4 ? * SAT *)"
maintenance_window_schedule = "cron(0 2 ? * SAT *)"

# Cost optimization settings for PoC
use_spot_instances = true
is_pilot_light     = false

# Development-specific settings
disable_monitoring   = false
enable_dr_monitoring = false

# OWASP Security settings
blocked_ip_addresses = ["192.168.1.100", "10.0.0.50"] # Example IPs for PoC
max_request_size     = 131072                         # 128 KB
request_limit        = 1000
enable_security_hub  = false