variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "primary_health_check_id" {
  description = "ID of the Route 53 health check for primary region"
  type        = string
}

variable "dr_health_check_id" {
  description = "ID of the Route 53 health check for DR region"
  type        = string
}

variable "primary_asg_name" {
  description = "Name of the Auto Scaling Group in primary region"
  type        = string
}

variable "dr_asg_name" {
  description = "Name of the Auto Scaling Group in DR region"
  type        = string
}

variable "primary_region" {
  description = "AWS region for primary environment"
  type        = string
}

variable "dr_region" {
  description = "AWS region for DR environment"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}

variable "test_schedule" {
  description = "Schedule expression for automated failover tests"
  type        = string
  default     = "cron(0 3 ? * SAT *)" # 3 AM every Saturday
}