variable "domain_name" {
  description = "Primary domain name for the application"
  type        = string
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "primary_endpoint" {
  description = "Endpoint URL for the primary environment health check"
  type        = string
}

variable "dr_endpoint" {
  description = "Endpoint URL for the DR environment health check"
  type        = string
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/health"
}

variable "primary_region" {
  description = "AWS region for the primary environment"
  type        = string
}

variable "dr_region" {
  description = "AWS region for the DR environment"
  type        = string
}

variable "primary_alb_dns_name" {
  description = "DNS name of the primary ALB"
  type        = string
}

variable "primary_alb_zone_id" {
  description = "Zone ID of the primary ALB"
  type        = string
}

variable "dr_alb_dns_name" {
  description = "DNS name of the DR ALB"
  type        = string
}

variable "dr_alb_zone_id" {
  description = "Zone ID of the DR ALB"
  type        = string
}

variable "enable_latency_based_routing" {
  description = "Whether to create latency-based routing records"
  type        = bool
  default     = false
}
