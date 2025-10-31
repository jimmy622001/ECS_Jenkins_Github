variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "security_group_id" {
  description = "Security group ID for the EC2 instances"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "additional_tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "patch_schedule" {
  description = "Schedule expression for patching"
  type        = string
  default     = "cron(0 2 ? * SUN *)" # 2 AM every Sunday
}

variable "maintenance_window_schedule" {
  description = "Schedule expression for maintenance window"
  type        = string
  default     = "cron(0 2 ? * SUN *)" # 2 AM every Sunday
}

variable "ssm_service_role_arn" {
  description = "Service role ARN for SSM"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms"
  type        = string
  default     = ""
}

variable "use_spot_instances" {
  description = "Whether to use spot instances"
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "Maximum spot price"
  type        = string
  default     = null
}

variable "is_pilot_light" {
  description = "Whether this is a pilot light DR setup"
  type        = bool
  default     = false
}