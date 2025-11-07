output "jenkins_asg_name" {
  description = "Name of the Jenkins Auto Scaling Group"
  value       = aws_autoscaling_group.jenkins.name
}

output "jenkins_launch_template_id" {
  description = "ID of the Jenkins Launch Template"
  value       = aws_launch_template.jenkins.id
}

output "jenkins_load_balancer_dns" {
  description = "DNS name of the Jenkins Load Balancer"
  value       = aws_lb.jenkins_nlb.dns_name
}

output "jenkins_security_group_id" {
  description = "ID of the Jenkins Security Group"
  value       = aws_security_group.jenkins_sg.id
}
