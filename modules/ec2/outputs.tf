output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.ecs_launch_template.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.ecs_launch_template.latest_version
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_asg.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_asg.arn
}

output "ecs_optimized_ami_id" {
  description = "ID of the ECS-optimized AMI"
  value       = data.aws_ami.ecs_optimized.id
}
