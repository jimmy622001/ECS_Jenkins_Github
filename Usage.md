# ECS Jenkins GitHub - Usage Guide

> **Important**: For detailed guides on specific topics, please refer to:
> - [Environment Deployment Guide](docs/ENVIRONMENT_DEPLOYMENT.md) - How to deploy and manage environments
> - [Automated Patching Guide](docs/AUTOMATED_PATCHING.md) - Automated patching setup and customization
> - [Testing Usage Guide](docs/TESTING_USAGE.md) - How to use quality checking tools, Terratest, and other testing tools

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
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Deploy the infrastructure:
   ```bash
   # For development environment
   cd environments/dev
   terraform apply

   # For production environment
   cd environments/prod
   terraform apply
   ```

> **Note**: Each environment directory contains its own terraform.tfvars file that is automatically loaded when running terraform commands in that directory. You do not need to specify the tfvars file with -var-file.

### Configuration Variables
Key configuration variables for deployment:

| Variable | Description | Default |
|----------|-------------|---------|
| environment | Environment name (dev/staging/prod) | dev |
| aws_region | AWS region for deployment | us-east-1 |
| dr_region | Disaster recovery region | us-west-2 |
| instance_type | EC2 instance type | t3.medium |
| dr_mode | DR mode (disabled/pilot-light/hot-standby) | pilot-light |
| use_spot_instances | Whether to use spot instances in DR region | true |

## Environment Management

### Dev Environment
The dev environment provides a scaled-down version of the infrastructure for development and testing:

- Smaller instance types
- Fewer minimum capacity for auto-scaling
- Development domain name (e.g., dev.example.com)

### Production Environment
The production environment is optimized for reliability and performance:

- Larger instance types
- Higher minimum capacity for auto-scaling
- Production domain name (e.g., example.com)
- Enhanced monitoring and alerting

### DR Environment
The DR environment in the secondary region (us-west-2) operates in pilot light mode:

- Uses spot instances for cost efficiency
- Maintains minimal infrastructure in standby mode
- Can be rapidly scaled up during failover events

## Patching and Update Management

### AMI Updates
The infrastructure automatically uses the latest ECS-optimized Amazon Linux AMIs via data sources:

```hcl
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}
```

To update instances with the latest AMI:

1. Update the launch template to use the latest AMI
2. Trigger an instance refresh in the Auto Scaling Group

### Automated Patching with SSM
The infrastructure uses AWS Systems Manager (SSM) for automated patching:

- Patches are applied during maintenance windows
- Security patches are applied automatically
- Non-security patches follow the defined schedule

To view patch compliance:

1. Open the AWS Management Console
2. Navigate to Systems Manager > Patch Manager > Compliance
3. Filter by resource groups or patch groups

**Note**: While the AWS Console can be used to monitor patch compliance, the infrastructure includes automated patching via AWS Systems Manager. Please see the [Automated Patching Guide](docs/AUTOMATED_PATCHING.md) for details on the automated patching setup and customization options.

## Blue/Green Deployments

### ECS Service Deployments
The ECS services are configured for blue/green deployments using AWS CodeDeploy:

- New task definitions are deployed to a new set of tasks
- Traffic is gradually shifted from old tasks to new ones
- Automatic rollback occurs if health checks fail

Example deployment:

```bash
aws ecs update-service --cluster main-cluster --service api-service --force-new-deployment
```

### EC2 Instance Updates
For EC2 instance updates:

1. Update the launch template with new configuration
2. Create an instance refresh:
   ```bash
   aws autoscaling start-instance-refresh \
     --auto-scaling-group-name jenkins-asg \
     --preferences '{"MinHealthyPercentage": 90, "InstanceWarmup": 300}'
   ```

## Disaster Recovery

### Testing Failover
To test failover between regions:

#### Using the AWS Console:
1. Navigate to Route 53 > Health Checks
2. Temporarily disable the primary region health check

#### Using the automated Lambda function:
1. Invoke the failover testing Lambda manually:
   ```bash
   aws lambda invoke \
     --function-name dr-failover-test \
     --payload '{"testDuration": 15}' \
     output.json
   ```

2. Schedule automated testing:
   - The infrastructure includes a CloudWatch Events rule that triggers monthly failover tests
   - Test results are sent to the SNS topic: dr-test-notifications

### Activating Disaster Recovery
In case of a regional outage:

1. The automated failover will trigger based on Route 53 health checks
2. Infrastructure in the DR region will scale up automatically
3. DNS will direct traffic to the DR region

To manually activate DR:

```bash
aws lambda invoke --function-name dr-activate-failover output.json
```

To return to primary region after recovery:

```bash
aws lambda invoke --function-name dr-revert-failover output.json
```

## Monitoring and Alerting

### CloudWatch Dashboards
Custom dashboards have been created for monitoring:

- ECS cluster metrics
- EC2 instance health
- Application performance
- DR health status

### Alerting
Alerts are configured for:

- Instance health issues
- ECS service health
- Patch compliance failures
- DR readiness status

All alerts are sent to the SNS topic: infrastructure-alerts

## Troubleshooting

### Common Issues and Resolutions

#### Instance Access Issues
If you need to access an EC2 instance for troubleshooting:

1. Use SSM Session Manager (preferred method):
   ```bash
   aws ssm start-session --target i-1234567890abcdef0
   ```

2. Check SSM agent status on problematic instances:
   ```bash
   aws ssm describe-instance-information --filters "Key=InstanceIds,Values=i-1234567890abcdef0"
   ```

#### ECS Service Deployment Issues
If ECS deployments fail:

1. Check service events:
   ```bash
   aws ecs describe-services --cluster main-cluster --services api-service
   ```

2. Check task status:
   ```bash
   aws ecs list-tasks --cluster main-cluster --service-name api-service
   ```

3. Check CloudWatch Logs for container issues:
   - Navigate to CloudWatch > Log Groups > /ecs/[service-name]

#### Auto Scaling Issues
If instances are not scaling correctly:

1. Check scaling activities:
   ```bash
   aws autoscaling describe-scaling-activities --auto-scaling-group-name jenkins-asg
   ```

2. Verify health check status:
   ```bash
   aws autoscaling describe-auto-scaling-instances --instance-ids i-1234567890abcdef0
   ```

#### Failover Testing Issues
If DR failover tests are failing:

1. Check Route 53 health check status
2. Verify instance capacity in DR region
3. Review CloudWatch Logs for failover Lambda function

## Security Best Practices

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
