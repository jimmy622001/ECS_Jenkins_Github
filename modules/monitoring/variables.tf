variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "prometheus_cpu" {
  description = "CPU units for Prometheus (1 vCPU = 1024)"
  type        = number
  default     = 1024
}

variable "prometheus_memory" {
  description = "Memory for Prometheus (in MiB)"
  type        = number
  default     = 2048
}

variable "grafana_cpu" {
  description = "CPU units for Grafana (1 vCPU = 1024)"
  type        = number
  default     = 512
}

variable "grafana_memory" {
  description = "Memory for Grafana (in MiB)"
  type        = number
  default     = 1024
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana. Should be provided via environment variable or secure parameter store."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.grafana_admin_password) >= 12
    error_message = "Grafana admin password must be at least 12 characters long."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "https_listener_arn" {
  description = "ARN of the HTTPS listener for the load balancer"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "enable_prometheus" {
  description = "Whether to enable Prometheus"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Whether to enable Grafana"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags for the monitoring resources"
  type        = map(string)
  default     = {}
}