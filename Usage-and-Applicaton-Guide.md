Usage and Application Guide

This guide provides detailed instructions for setting up, customizing, and operating the ECS with Jenkins CI/CD and Monitoring infrastructure.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Deployment Steps](#deployment-steps)
- [Security Scanning](#security-scanning)
- [Accessing Services](#accessing-services)
- [Working with CI/CD](#working-with-cicd)
- [Monitoring Setup](#monitoring-setup)
- [Customization](#customization)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- AWS CLI installed and configured with appropriate permissions
- Terraform v1.0.0 or newer installed
- Git installed
- Docker installed (for local testing)
- SSH key pair created in AWS for Jenkins access
- GitHub repository for your application code

## Initial Setup

1. **Clone this repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
Initialize Terraform
terraform init
Configure Variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
Important variables to set:
aws_region: Region to deploy resources
availability_zones: At least two AZs for high availability
db_username and db_password: For RDS instance
key_name: SSH key name for Jenkins access
trusted_ips: IP addresses allowed to access Jenkins
grafana_admin_password: Admin password for Grafana
Deployment Steps
Validate Configuration
terraform validate
Preview Changes
terraform plan
Deploy Infrastructure
terraform apply
Verify Deployment After deployment completes (~10-15 minutes), verify:
All resources show in AWS Console
Security groups are correctly configured
Load balancer health checks are passing
Security Scanning
Run security scans regularly to ensure your infrastructure follows best practices:

Install Security Tools
# For Linux/Mac
pip install checkov
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# For Windows
pip install checkov
# Download TFLint from https://github.com/terraform-linters/tflint/releases
Run Scans
# Run Checkov
checkov -d .

# Run TFLint
tflint
Review Results
Address high-severity findings immediately
Create a plan to address medium and low-severity findings
Accessing Services
Load Balancer
Access the ALB at: http://<load-balancer-dns>/
Find the DNS name in AWS Console or Terraform outputs
Jenkins
Access Jenkins at: http://<load-balancer-dns>/jenkins/
Initial admin password is stored in:
aws ssm get-parameter --name=/jenkins/admin/password --with-decryption
Prometheus
Access Prometheus at: http://<load-balancer-dns>/prometheus/
Basic authentication is enabled
Grafana
Access Grafana at: http://<load-balancer-dns>/grafana/
Login with:
Username: admin
Password: Value specified in grafana_admin_password variable
Working with CI/CD
Setting up a Pipeline
Configure GitHub Webhook
Go to your GitHub repository settings
Add webhook: http://<load-balancer-dns>/jenkins/github-webhook/
Select "application/json" for content type
Choose events to trigger the webhook (typically push events)
Create a Jenkinsfile Add a Jenkinsfile to your repository:
pipeline {
agent any
stages {
stage('Build') {
steps {
sh 'docker build -t my-application .'
}
}
stage('Test') {
steps {
sh 'docker run my-application npm test'
}
}
stage('Deploy') {
steps {
withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
sh 'aws ecs update-service --cluster main-cluster --service my-service --force-new-deployment'
}
}
}
}
}
Configure Jenkins Pipeline
In Jenkins, create a new Pipeline job
Select "Pipeline script from SCM"
Enter your GitHub repository URL
Specify the branch to build
Save and run the pipeline
Monitoring Setup
Configuring Prometheus
Access Prometheus UI Navigate to http://<load-balancer-dns>/prometheus/
Verify Targets
Go to Status > Targets
Ensure all services are being monitored successfully
Setting up Grafana Dashboards
Access Grafana Navigate to http://<load-balancer-dns>/grafana/
Add Data Source
Go to Configuration > Data Sources
Add Prometheus data source
URL: http://prometheus:9090
Save & Test
Import Dashboards
Go to Create > Import
Import dashboard ID 1860 for Node Exporter metrics
Import dashboard ID 3662 for Prometheus stats
Import dashboard ID 7589 for ECS monitoring
Configure Alerts
Go to Alerting > Notification channels
Set up email, Slack, or other notification channels
Create alert rules in the dashboard settings
Customization
Adding New ECS Services
Create a new ECS task definition Add to the ECS module in modules/ecs/main.tf:
resource "aws_ecs_task_definition" "new_service" {
family                   = "new-service"
network_mode             = "awsvpc"
requires_compatibilities = ["FARGATE"]
cpu                      = 256
memory                   = 512
execution_role_arn       = var.execution_role_arn
task_role_arn            = var.task_role_arn

container_definitions = jsonencode([{
name      = "new-service"
image     = "nginx:latest"
essential = true
portMappings = [{
containerPort = 80
hostPort      = 80
}]
}])
}
Create a service for the task
resource "aws_ecs_service" "new_service" {
name            = "new-service"
cluster         = aws_ecs_cluster.cluster.id
task_definition = aws_ecs_task_definition.new_service.arn
desired_count   = 2
launch_type     = "FARGATE"

network_configuration {
subnets          = var.private_subnet_ids
security_groups  = [var.ecs_security_group]
assign_public_ip = false
}
}
Adding Custom Monitoring
Add CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
alarm_name          = "high-cpu-utilization"
comparison_operator = "GreaterThanThreshold"
evaluation_periods  = 2
metric_name         = "CPUUtilization"
namespace           = "AWS/ECS"
period              = 60
statistic           = "Average"
threshold           = 80
alarm_description   = "High CPU utilization"
alarm_actions       = [aws_sns_topic.alerts.arn]
dimensions = {
ClusterName = aws_ecs_cluster.cluster.name
ServiceName = aws_ecs_service.service.name
}
}
Create custom Prometheus exporters Add to your ECS task definitions:
container_definitions = jsonencode([
# Main application container
{
name      = "app"
image     = "your-app:latest"
essential = true
},
# Sidecar exporter
{
name      = "exporter"
image     = "prom/node-exporter:latest"
essential = false
}
])
Maintenance
Updating Infrastructure
Make changes to Terraform code
Run plan to review changes
terraform plan
Apply changes
terraform apply
Backing Up State
Configure Remote State Add to your Terraform configuration:
terraform {
backend "s3" {
bucket         = "your-terraform-state-bucket"
key            = "terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-lock"
}
}
Initialize with new backend
terraform init -migrate-state
Regular Maintenance Tasks
Update Jenkins plugins monthly
Review and rotate credentials quarterly
Update ECS task definitions with latest container images
Review security scan results weekly
Troubleshooting
Common Issues
ECS Service Deployment Failures
Check CloudWatch logs for container issues
Verify task definition is correct
Check ECR image exists and is properly tagged
Jenkins Pipeline Failures
Check Jenkins console output
Verify AWS credentials are properly configured
Check network connectivity to AWS services
Database Connectivity Issues
Verify security groups allow traffic from ECS tasks
Check subnet routing is correct
Validate database credentials in task environment
Monitoring Alert Storms
Check for resource constraints
Review alert thresholds and adjust if necessary
Implement alert grouping in Prometheus
Support Resources
Terraform Documentation: https://www.terraform.io/docs
AWS ECS Documentation: https://docs.aws.amazon.com/ecs/
Prometheus Documentation: https://prometheus.io/docs/
Grafana Documentation: https://grafana.com/docs/
Cleaning Up
To destroy all resources when no longer needed:

terraform destroy
⚠️ Warning: This will permanently delete all resources including databases and stored data.