# Automated Patching Guide

This guide explains how patching is handled in the ECS Jenkins GitHub project, including automated patching options and customization.

## Table of Contents
1. [Current Patching Setup](#current-patching-setup)
2. [Automated Patching Mechanisms](#automated-patching-mechanisms)
3. [Setting Up Automated Patching](#setting-up-automated-patching)
4. [Triggering Manual Patching](#triggering-manual-patching)
5. [Patch Compliance Monitoring](#patch-compliance-monitoring)
6. [Customizing Patching Schedule](#customizing-patching-schedule)

## Current Patching Setup

The project already includes automated patching through AWS Systems Manager (SSM), contrary to what the Usage.md file suggests. The EC2 module configures:

1. SSM Agent installation on instances
2. Regularly scheduled patching via SSM associations
3. Maintenance windows for controlled patching
4. Patch compliance reporting

## Automated Patching Mechanisms

### 1. SSM Association for Patching

The infrastructure includes an AWS SSM Association that automatically applies patches according to a schedule:

```hcl
resource "aws_ssm_association" "patching" {
  name = "AWS-RunPatchBaseline"

  targets {
    key    = "tag:Project"
    values = [var.project]
  }

  targets {
    key    = "tag:Environment"
    values = [var.environment]
  }

  schedule_expression = var.patch_schedule

  parameters = {
    Operation    = "Install"
    RebootOption = "RebootIfNeeded"
  }

  output_location {
    s3_bucket_name = aws_s3_bucket.patch_logs.id
    s3_key_prefix  = "ssm-patch-logs"
  }
}
```

### 2. Maintenance Window

Dedicated maintenance windows are configured to perform patching during specified times:

```hcl
resource "aws_ssm_maintenance_window" "patching_window" {
  name                       = "${var.project}-${var.environment}-patching-window"
  schedule                   = var.maintenance_window_schedule
  duration                   = 3
  cutoff                     = 1
  schedule_timezone          = "UTC"
  allow_unassociated_targets = true
}
```

### 3. AMI Updates

The infrastructure uses the latest ECS-optimized Amazon Linux AMIs through data sources:

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

## Setting Up Automated Patching

Automated patching is already enabled in your project. You can customize it by modifying the following variables in your environment's `terraform.tfvars` file:

```hcl
# Patching schedule
patch_schedule              = "cron(0 3 ? * MON *)"  # 3 AM every Monday
maintenance_window_schedule = "cron(0 1 ? * SUN *)"  # 1 AM every Sunday
```

Supported schedules use standard cron expressions or rate expressions:

- `cron(0 2 ? * SUN *)` - 2 AM every Sunday
- `cron(0 2 ? * SUN#1 *)` - 2 AM on the first Sunday of each month
- `rate(7 days)` - Every 7 days

## Triggering Manual Patching

You can trigger manual patching using AWS SSM:

### via AWS CLI:

```bash
# Start patching immediately for tagged instances
aws ssm send-command \
  --document-name "AWS-RunPatchBaseline" \
  --targets "Key=tag:Environment,Values=dev" \
  --parameters "Operation=Install,RebootOption=RebootIfNeeded" \
  --region us-east-1
```

### via AWS Console:

1. Open the AWS Management Console
2. Navigate to Systems Manager > Run Command
3. Select the document "AWS-RunPatchBaseline"
4. Choose targets by tag (Project and Environment)
5. Set Operation to "Install" and RebootOption to "RebootIfNeeded"
6. Click "Run"

## Patch Compliance Monitoring

### Via AWS Console

Monitor patch compliance through:

1. Open AWS Management Console
2. Navigate to Systems Manager > Patch Manager > Compliance
3. Filter by environment tags to see compliance status

### Via AWS CLI

```bash
# Get patch compliance information
aws ssm list-compliance-items \
  --resource-ids "i-1234567890abcdef0" \
  --resource-types "ManagedInstance" \
  --filters "Key=ComplianceType,Values=Patch" \
  --region us-east-1
```

## Customizing Patching Schedule

To change the patching schedule:

1. Edit the `terraform.tfvars` file in the desired environment directory:

```hcl
# For weekly patching on Saturday at 4 AM
patch_schedule = "cron(0 4 ? * SAT *)"

# For monthly patching on the first Monday at 2 AM
patch_schedule = "cron(0 2 ? * MON#1 *)"
```

2. Apply the changes:

```bash
cd environments/dev
terraform apply
```

## Setting up Patch Notifications

To receive notifications about patch status:

1. Create an SNS topic and subscription
2. Configure AWS Eventbridge rules to send events to SNS:

```hcl
resource "aws_cloudwatch_event_rule" "patch_compliance_event" {
  name        = "${var.project}-${var.environment}-patch-compliance"
  description = "Captures patch compliance changes"

  event_pattern = jsonencode({
    source      = ["aws.ssm"]
    detail-type = ["Compliance Change"]
    detail = {
      resource-type = ["ManagedInstance"]
      compliance-type = ["Patch"]
    }
  })
}

resource "aws_cloudwatch_event_target" "patch_compliance_target" {
  rule      = aws_cloudwatch_event_rule.patch_compliance_event.name
  target_id = "SendToSNS"
  arn       = var.sns_topic_arn
}
```

## Best Practices

1. **Staggered patching**: Set different schedules for different environments
2. **Testing**: Apply patches to dev environment first
3. **Monitoring**: Check patch compliance regularly
4. **Rollback plan**: Have a plan to restore from snapshots if patching causes issues
5. **Documentation**: Keep records of patching activity and any issues encountered