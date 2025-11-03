# ECS Jenkins GitHub - Usage Guide

This guide provides instructions for deploying, managing, and maintaining the ECS Jenkins GitHub infrastructure.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deployment Instructions](#deployment-instructions)
3. [Environment Management](#environment-management)
4. [Patching and Update Management](#patching-and-update-management)
5. [Blue/Green Deployments](#bluegreen-deployments)
6. [Disaster Recovery](#disaster-recovery)
7. [Monitoring and Alerting](#monitoring-and-alerting)
8. [Troubleshooting](#troubleshooting)
9. [Security Best Practices](#security-best-practices)

## Prerequisites

Before deploying the infrastructure, ensure you have:

- Terraform 1.0.0 or newer
- AWS CLI configured with appropriate permissions
- GitHub access token with repo and admin:repo_hook permissions

## Deployment Instructions

### Basic Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/ECS_Jenkins_Github.git
   cd ECS_Jenkins_Github
Initialize Terraform:
terraform init
Deploy the infrastructure:
# For development environment
cd environments/dev
terraform apply -var-file=dev.tfvars

# For production environment
cd environments/prod
terraform apply -var-file=prod.tfvars
Configuration Variables
Key configuration variables for deployment:

Variable	Description	Default
environment	Environment name (dev/staging/prod)	dev
aws_region	AWS region for deployment	us-east-1
dr_region	Disaster recovery region	us-west-2
instance_type	EC2 instance type	t3.medium
dr_mode	DR mode (disabled/pilot-light/hot-standby)	pilot-light
use_spot_instances	Whether to use spot instances in DR region	true
Environment Management
Dev Environment
The dev environment provides a scaled-down version of the infrastructure for development and testing:

Smaller instance types
Fewer minimum capacity for auto-scaling
Development domain name (e.g., dev.example.com)
Production Environment
The production environment is optimized for reliability and performance:

Larger instance types
Higher minimum capacity for auto-scaling
Production domain name (e.g., example.com)
Enhanced monitoring and alerting
DR Environment
The DR environment in the secondary region (us-west-2) operates in pilot light mode:

Uses spot instances for cost efficiency
Maintains minimal infrastructure in standby mode
Can be rapidly scaled up during failover events
Patching and Update Management
AMI Updates
The infrastructure automatically uses the latest ECS-optimized Amazon Linux AMIs via data sources:

data "aws_ami" "ecs_optimized" {
most_recent = true
owners      = ["amazon"]

filter {
name   = "name"
values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
}
}
To update instances with the latest AMI:

Update the launch template to use the latest AMI
Trigger an instance refresh in the Auto Scaling Group
Automated Patching with SSM
The infrastructure uses AWS Systems Manager (SSM) for automated patching:

Patches are applied during maintenance windows
Security patches are applied automatically
Non-security patches follow the defined schedule
To view patch compliance:

Open the AWS Management Console
Navigate to Systems Manager > Patch Manager > Compliance
Filter by resource groups or patch groups
Blue/Green Deployments
ECS Service Deployments
The ECS services are configured for blue/green deployments using AWS CodeDeploy:

New task definitions are deployed to a new set of tasks
Traffic is gradually shifted from old tasks to new ones
Automatic rollback occurs if health checks fail
Example deployment:

aws ecs update-service --cluster main-cluster --service api-service --force-new-deployment
EC2 Instance Updates
For EC2 instance updates:

Update the launch template with new configuration
Create an instance refresh:
aws autoscaling start-instance-refresh \
--auto-scaling-group-name jenkins-asg \
--preferences '{"MinHealthyPercentage": 90, "InstanceWarmup": 300}'
Disaster Recovery
Testing Failover
To test failover between regions:

Using the AWS Console:
Navigate to Route 53 > Health Checks
Temporarily disable the primary region health check
Using the automated Lambda function:
Invoke the failover testing Lambda manually:
aws lambda invoke \
--function-name dr-failover-test \
--payload '{"testDuration": 15}' \
output.json
Schedule automated testing:
The infrastructure includes a CloudWatch Events rule that triggers monthly failover tests
Test results are sent to the SNS topic: dr-test-notifications
Activating Disaster Recovery
In case of a regional outage:

The automated failover will trigger based on Route 53 health checks
Infrastructure in the DR region will scale up automatically
DNS will direct traffic to the DR region
To manually activate DR:

aws lambda invoke --function-name dr-activate-failover output.json
To return to primary region after recovery:

aws lambda invoke --function-name dr-revert-failover output.json
Monitoring and Alerting
CloudWatch Dashboards
Custom dashboards have been created for monitoring:

ECS cluster metrics
EC2 instance health
Application performance
DR health status
Alerting
Alerts are configured for:

Instance health issues
ECS service health
Patch compliance failures
DR readiness status
All alerts are sent to the SNS topic: infrastructure-alerts

Troubleshooting
Common Issues and Resolutions
Instance Access Issues
If you need to access an EC2 instance for troubleshooting:

Use SSM Session Manager (preferred method):
aws ssm start-session --target i-1234567890abcdef0
Check SSM agent status on problematic instances:
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=i-1234567890abcdef0"
ECS Service Deployment Issues
If ECS deployments fail:

Check service events:
aws ecs describe-services --cluster main-cluster --services api-service
Check task status:
aws ecs list-tasks --cluster main-cluster --service-name api-service
Check CloudWatch Logs for container issues:
Navigate to CloudWatch > Log Groups > /ecs/[service-name]
Auto Scaling Issues
If instances are not scaling correctly:

Check scaling activities:
aws autoscaling describe-scaling-activities --auto-scaling-group-name jenkins-asg
Verify health check status:
aws autoscaling describe-auto-scaling-instances --instance-ids i-1234567890abcdef0
Failover Testing Issues
If DR failover tests are failing:

Check Route 53 health check status
Verify instance capacity in DR region
Review CloudWatch Logs for failover Lambda function
Security Best Practices

### OWASP Security Implementation
The project includes a dedicated security module that implements OWASP Top 10 protections:

- **AWS WAF** with OWASP Top 10 rules that protect against common vulnerabilities
- **Security Headers** configured according to OWASP recommendations
- **Rate Limiting** to prevent abuse and DDoS attacks
- **Geo-Blocking** for high-risk countries

For detailed information about OWASP security implementation, see the [SECURITY.md](SECURITY.md) file.

### Static Code Analysis Tools

- **Checkov** scans infrastructure code for security vulnerabilities and compliance issues
- **TFLint** validates Terraform code against AWS best practices and security standards
- **Pre-commit hooks** run security checks locally before code is committed
- **CI/CD integration** ensures all code is security-scanned before deployment

See [docs/SECURITY_SCANNING.md](docs/SECURITY_SCANNING.md) for usage instructions.

### Access Management
- Use SSM Session Manager instead of SSH for instance access
- Apply least privilege IAM policies
- Enable CloudTrail for all API actions

### Data Protection
- All EBS volumes are encrypted using AWS KMS
- RDS databases use encryption at rest
- All S3 buckets enforce encryption

### Network Security
- VPC security groups follow least privilege
- No direct internet access to private subnets
- NACLs provide additional network layer protection

### Compliance Monitoring
- AWS Config rules monitor compliance
- Security Hub provides security standards assessment
- GuardDuty monitors for threats
