variable "db_username" {
  description = "Database username for dev environment"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password for dev environment"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name for dev environment"
  type        = string
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana in dev environment"
  type        = string
  sensitive   = true
}

variable "grafana_admin_user" {
  description = "Admin username for Grafana in dev environment"
  type        = string
  default     = "admin"
}

# OWASP Security Variables
variable "blocked_ip_addresses" {
  description = "List of IP addresses to block"
  type        = list(string)
  default     = []
}

variable "max_request_size" {
  description = "Maximum allowed request size in bytes"
  type        = number
  default     = 131072 # 128 KB
}

variable "request_limit" {
  description = "Maximum number of requests allowed in 5-minute period from a single IP"
  type        = number
  default     = 1000
}

variable "enable_security_hub" {
  description = "Whether to enable AWS Security Hub"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type for ECS container instances"
  type        = string
}

variable "min_instance_count" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
}

variable "max_instance_count" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
}

variable "desired_instance_count" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
}

variable "root_volume_size" {
  description = "Root volume size in GB for EC2 instances"
  type        = number
  default     = 30
}

variable "patch_schedule" {
  description = "Cron expression for patching schedule"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "maintenance_window_schedule" {
  description = "Maintenance window for Auto Scaling Group"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for the database subnets"
  type        = list(string)
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile to use for deployment"
  type        = string
  default     = "default"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "jenkins_role_name" {
  description = "Name of the IAM role for Jenkins"
  type        = string
}

variable "container_port" {
  description = "Port on which the container will run"
  type        = number
  default     = 8080
}

variable "use_spot_instances" {
  description = "Whether to use Spot Instances"
  type        = bool
  default     = true
}

variable "spot_price" {
  description = "Spot instance maximum price"
  type        = string
}

variable "jenkins_version" {
  description = "Version of Jenkins to deploy"
  type        = string
  default     = "2.346.1"
}

variable "is_pilot_light" {
  description = "Whether the environment is in pilot light mode"
  type        = bool
  default     = false
}

variable "trusted_ips" {
  description = "List of trusted IP addresses/ranges"
  type        = list(string)
  default     = []
}

variable "container_image" {
  description = "Docker image for the application container"
  type        = string
  default     = "nginx:latest"
}

variable "disable_monitoring" {
  description = "Whether to disable monitoring for the environment"
  type        = bool
  default     = false
}

variable "enable_dr_monitoring" {
  description = "Whether to enable disaster recovery monitoring"
  type        = bool
  default     = false
}