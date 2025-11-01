variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = ""
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
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "container_image" {
  description = "Docker image to use"
  type        = string
  default     = "nginx:alpine"
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

variable "jenkins_version" {
  description = "Jenkins version to install"
  type        = string
  default     = "2.222.1"
}

variable "jenkins_role_name" {
  description = "Name of the IAM role for Jenkins"
  type        = string
}

variable "trusted_ips" {
  description = "List of trusted IP addresses for security groups"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

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

variable "disable_monitoring" {
  description = "Whether to disable monitoring"
  type        = bool
  default     = false
}

variable "enable_dr_monitoring" {
  description = "Whether to enable DR monitoring"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "create_database" {
  description = "Whether to create a database"
  type        = bool
  default     = true
}

variable "db_snapshot_identifier" {
  description = "DB snapshot identifier for restoration"
  type        = string
  default     = null
}