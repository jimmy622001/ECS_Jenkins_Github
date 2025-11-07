variable "project" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to protect"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "blocked_ip_addresses" {
  description = "List of IP addresses to block"
  type        = list(string)
  default     = [] # Empty by default, to be filled in by each environment
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

# Optional: SSL Policy to enforce
variable "ssl_policy" {
  description = "SSL Policy to use for ALB HTTPS listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01" # Minimum TLS 1.2
}
