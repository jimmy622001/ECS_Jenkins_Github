output "ecs_task_execution_role" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "jenkins_role" {
  description = "ARN of the Jenkins role"
  value       = aws_iam_role.jenkins_role.arn
}
output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ssm_service_role_arn" {
  description = "ARN of the SSM service role"
  value       = aws_iam_role.ssm_service_role.arn
}

output "ec2_instance_profile" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy role for ECS blue/green deployments"
  value       = aws_iam_role.codedeploy_role.arn
}