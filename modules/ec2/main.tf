# EC2 Module for managing EC2 instances with best practices
# Latest ECS-Optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template for ECS Instances
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix            = "${var.project}-${var.environment}-"
  image_id               = data.aws_ami.ecs_optimized.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  dynamic "instance_market_options" {
    for_each = var.use_spot_instances ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price = var.spot_price
        spot_instance_type = "persistent"
        instance_interruption_behavior = "terminate"
      }
    }
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  # ECS Instance Configuration
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
    echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
    echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config
    yum update -y
    amazon-linux-extras install epel -y
    yum install -y amazon-cloudwatch-agent
    yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Report instance status to Systems Manager
    aws ssm put-parameter --name "/${var.project}/${var.environment}/instance-ready" --type "String" --value "$(date +%s)" --overwrite --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
  EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required for better security
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name        = "${var.project}-${var.environment}-ecs-instance"
        Environment = var.environment
        Project     = var.project
        ManagedBy   = "Terraform"
        AutoUpdate  = "true"
      },
      var.additional_tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name        = "${var.project}-${var.environment}-ecs-volume"
        Environment = var.environment
        Project     = var.project
        ManagedBy   = "Terraform"
      },
      var.additional_tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for ECS Instances
resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.project}-${var.environment}-ecs-asg"
  vpc_zone_identifier       = var.subnet_ids
  min_size                  = var.is_pilot_light ? (var.min_size > 0 ? 1 : 0) : var.min_size
  max_size                  = var.is_pilot_light ? var.max_size : var.max_size
  desired_capacity          = var.is_pilot_light ? (var.desired_capacity > 0 ? 1 : 0) : var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      {
        Name        = "${var.project}-${var.environment}-ecs-asg"
        Environment = var.environment
        Project     = var.project
        ManagedBy   = "Terraform"
        PilotLight  = var.is_pilot_light ? "true" : "false"
      },
      var.additional_tags
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # ASG warm pool for faster scaling during failover testing
  dynamic "warm_pool" {
    for_each = var.is_pilot_light ? [1] : []
    content {
      pool_state = "Stopped"
      min_size = 1
      max_group_prepared_capacity = 2
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# SSM Association for Patching
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

# S3 Bucket for Patch Logs
resource "aws_s3_bucket" "patch_logs" {
  bucket = "${var.project}-${var.environment}-patch-logs-${random_string.suffix.result}"

  tags = {
    Name        = "${var.project}-${var.environment}-patch-logs"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "patch_logs_lifecycle" {
  bucket = aws_s3_bucket.patch_logs.id

  rule {
    id     = "DeleteOldLogs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

# Maintenance Window for Patching
resource "aws_ssm_maintenance_window" "patching_window" {
  name              = "${var.project}-${var.environment}-patching-window"
  schedule          = var.maintenance_window_schedule
  duration          = 3
  cutoff            = 1
  schedule_timezone = "UTC"
  allow_unassociated_targets = true

  tags = {
    Name        = "${var.project}-${var.environment}-patching-window"
    Environment = var.environment
    Project     = var.project
  }
}

# Maintenance Window Target
resource "aws_ssm_maintenance_window_target" "target" {
  window_id     = aws_ssm_maintenance_window.patching_window.id
  resource_type = "INSTANCE"
  
  targets {
    key    = "tag:Project"
    values = [var.project]
  }
  
  targets {
    key    = "tag:Environment"
    values = [var.environment]
  }
}

# Maintenance Window Task
resource "aws_ssm_maintenance_window_task" "patching_task" {
  window_id        = aws_ssm_maintenance_window.patching_window.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = var.ssm_service_role_arn
  max_concurrency  = "50%"
  max_errors       = "25%"
  
  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.target.id]
  }
  
  task_invocation_parameters {
    run_command_parameters {
      timeout_seconds = 600
      
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }
}

# CloudWatch Alarm for ASG Health
resource "aws_cloudwatch_metric_alarm" "asg_health" {
  alarm_name          = "${var.project}-${var.environment}-asg-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = "60"
  statistic           = "Average"
  threshold           = var.min_size
  alarm_description   = "This alarm monitors ASG health for ${var.project}-${var.environment}"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ecs_asg.name
  }
  
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}