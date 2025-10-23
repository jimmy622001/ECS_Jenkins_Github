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

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_task_execution_role" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "alb_security_group" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "ecs_security_group" {
  description = "Security group ID for the ECS tasks"
  type        = string
}

variable "container_port" {
  description = "Port on which the container is listening"
  type        = number
  default     = 80
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"
}

variable "create_dummy_cert" {
  description = "Whether to create a self-signed certificate for testing"
  type        = bool
  default     = true
}

variable "create_jenkins" {
  description = "Whether to create Jenkins instance for CI/CD"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "SSH key name for Jenkins instance"
  type        = string
  default     = ""
}

variable "jenkins_security_group" {
  description = "Security group ID for Jenkins"
  type        = string
  default     = ""
}