variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for the database subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "container_port" {
  description = "Port exposed by the docker image"
  type        = number
}

variable "key_name" {
  description = "SSH key name for Jenkins instance"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins"
  type        = string
  default     = "t3.micro"
}
variable "jenkins_role_name" {
  description = "Name of the IAM role for Jenkins"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true

}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

# Variables for EC2 Auto Scaling Group
variable "ec2_instance_type" {
  description = "EC2 instance type for ECS container instances"
  type        = string
  default     = "t3.medium"
}

variable "min_instance_count" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_instance_count" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 5
}

variable "desired_instance_count" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "Root volume size in GB for EC2 instances"
  type        = number
  default     = 30
}

variable "patch_schedule" {
  description = "Cron expression for patching schedule"
  type        = string
  default     = "cron(0 2 ? * SUN *)"
}

variable "maintenance_window_schedule" {
  description = "Cron expression for maintenance window"
  type        = string
  default     = "cron(0 2 ? * SUN *)"
}

variable "use_spot_instances" {
  description = "Whether to use spot instances for ECS"
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "Maximum price to bid for spot instances"
  type        = string
  default     = null
}

variable "is_pilot_light" {
  description = "Whether this environment is a pilot light DR setup"
  type        = bool
  default     = false
}

variable "failover_domain" {
  description = "Domain name for failover routing"
  type        = string
  default     = null
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