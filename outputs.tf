output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.network.database_subnet_ids
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs.alb_dns_name
}

output "jenkins_load_balancer_dns" {
  description = "DNS name of the Jenkins load balancer"
  value       = module.cicd.jenkins_load_balancer_dns
}

output "database_endpoint" {
  description = "Endpoint of the RDS database"
  value       = module.database.db_instance_endpoint
}

# New outputs for ECS and EC2 managed AMI resources
output "ecs_optimized_ami_id" {
  description = "ID of the ECS-optimized AMI being used"
  value       = module.ec2.ecs_optimized_ami_id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group for ECS container instances"
  value       = module.ec2.autoscaling_group_name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.ec2.launch_template_id
}

# Commented out until CodeDeploy app is implemented in the ECS module
#output "codedeploy_app_name" {
#  description = "Name of the CodeDeploy application"
#  value       = module.ecs.codedeploy_app_name
#}

output "infrastructure_alerts_topic_arn" {
  description = "ARN of the SNS topic for infrastructure alerts"
  value       = module.monitoring.infrastructure_alerts_topic_arn
}