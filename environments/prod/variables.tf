variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
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
  description = "Environment name"
  type        = string
}

variable "db_username" {
  description = "Database username for production environment"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password for production environment"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Jenkins instance type"
  type        = string
}

variable "jenkins_version" {
  description = "Jenkins version"
  type        = string
}

variable "jenkins_role_name" {
  description = "Jenkins IAM role name"
  type        = string
}

variable "trusted_ips" {
  description = "Trusted IP CIDR ranges for security groups"
  type        = list(string)
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana in production environment"
  type        = string
  sensitive   = true
}

variable "grafana_admin_user" {
  description = "Admin username for Grafana"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_instance_count" {
  description = "Minimum number of instances"
  type        = number
}

variable "max_instance_count" {
  description = "Maximum number of instances"
  type        = number
}

variable "desired_instance_count" {
  description = "Desired number of instances"
  type        = number
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
}

variable "patch_schedule" {
  description = "Patch schedule cron expression"
  type        = string
}

variable "maintenance_window_schedule" {
  description = "Maintenance window schedule cron expression"
  type        = string
}

variable "use_spot_instances" {
  description = "Whether to use spot instances"
  type        = bool
}

variable "is_pilot_light" {
  description = "Whether this environment is a pilot light DR setup"
  type        = bool
}
