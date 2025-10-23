variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where Jenkins instance will be deployed"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key name for Jenkins instance"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR blocks allowed to SSH to Jenkins"
  type        = list(string)
  default     = ["0.0.0.0/0"] # For production, restrict this to specific IPs
}

variable "web_allowed_cidr" {
  description = "CIDR blocks allowed to access Jenkins web UI"
  type        = list(string)
  default     = ["0.0.0.0/0"] # For production, restrict this to specific IPs
}

variable "jenkins_role_name" {
  description = "Name of the IAM role for Jenkins"
  type        = string
}