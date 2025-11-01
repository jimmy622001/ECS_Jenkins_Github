# AWS Configuration
aws_region   = "us-west-2"  # DR region
aws_profile  = "dr"
project_name = "ecs-jenkins-dr"

# Network Configuration for DR
vpc_cidr              = "10.2.0.0/16"
public_subnet_cidrs   = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs  = ["10.2.3.0/24", "10.2.4.0/24"]
database_subnet_cidrs = ["10.2.5.0/24", "10.2.6.0/24"]
availability_zones    = ["us-west-2a", "us-west-2b"]

# Environment
environment = "dr"

# Database Configuration
db_username = "drdbadmin"
db_password = "DrSecurePass123!"  # Change this to a secure password
db_name     = "drappdb"

# Application Configuration (minimal for DR)
container_image = "nginx:stable"
container_port  = 8080

# Jenkins Configuration
key_name              = "dr-key"
jenkins_instance_type = "t3.micro"  # Smaller instance for cost saving in DR
jenkins_role_name     = "jenkins-role-dr"

# Security - Restricted but allows failover access
trusted_ips            = ["10.0.0.0/8", "192.168.0.0/16"]
grafana_admin_password = "DrGrafanaPass123!"  # Change this
domain_name            = "dr.example.com"

# DR-specific EC2 configuration (minimal for pilot light)
ec2_instance_type      = "t3.small"
min_instance_count     = 1
max_instance_count     = 4
desired_instance_count = 1
patch_schedule         = "cron(0 4 ? * SAT *)"

# Pilot light configuration - enable spot instances and pilot light for DR
use_spot_instances     = true
is_pilot_light         = true

# DR-specific settings
enable_dr_monitoring = true