# Lambda module for scheduled failover testing

# S3 bucket to store Lambda function code
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "lambda_code" {
  bucket = "${var.project}-${var.environment}-lambda-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project}-${var.environment}-lambda"
    Environment = var.environment
    Project     = var.project
  }
}

# ZIP archive of Lambda function code
data "archive_file" "failover_lambda" {
  type        = "zip"
  output_path = "${path.module}/failover_lambda.zip"

  source {
    content  = <<EOF
import boto3
import os
import json
import time
from datetime import datetime

def toggle_health_check(health_check_id, status):
    """Toggle Route 53 health check status."""
    client = boto3.client('route53')
    response = client.update_health_check(
        HealthCheckId=health_check_id,
        Disabled=(status == 'disable')
    )
    return response

def scale_asg(asg_name, region, min_size, max_size, desired_capacity):
    """Scale ASG to specified capacity."""
    client = boto3.client('autoscaling', region_name=region)
    response = client.update_auto_scaling_group(
        AutoScalingGroupName=asg_name,
        MinSize=min_size,
        MaxSize=max_size,
        DesiredCapacity=desired_capacity
    )
    return response

def notify_sns(topic_arn, subject, message):
    """Send notification to SNS topic."""
    client = boto3.client('sns')
    response = client.publish(
        TopicArn=topic_arn,
        Subject=subject,
        Message=message
    )
    return response

def lambda_handler(event, context):
    """Main Lambda handler for failover testing."""
    # Configuration from environment variables
    primary_health_check_id = os.environ['PRIMARY_HEALTH_CHECK_ID']
    dr_health_check_id = os.environ['DR_HEALTH_CHECK_ID']
    primary_asg_name = os.environ['PRIMARY_ASG_NAME']
    dr_asg_name = os.environ['DR_ASG_NAME']
    primary_region = os.environ['PRIMARY_REGION']
    dr_region = os.environ['DR_REGION']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    failover_mode = os.environ.get('FAILOVER_MODE', 'test') # test, activate_dr, restore
    
    # Timestamp for logging
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    try:
        if failover_mode == 'test':
            # Failover test mode - temporary test
            notify_sns(
                sns_topic_arn,
                f"Failover Testing Started - {timestamp}",
                f"Initiating failover test from {primary_region} to {dr_region}"
            )
            
            # Disable primary health check to simulate failure
            toggle_health_check(primary_health_check_id, 'disable')
            
            # Scale up DR environment
            scale_asg(dr_asg_name, dr_region, 2, 6, 4)
            
            # Wait for 15 minutes to observe
            time.sleep(900)
            
            # Restore primary
            toggle_health_check(primary_health_check_id, 'enable')
            
            # Scale back DR environment
            scale_asg(dr_asg_name, dr_region, 1, 4, 1)
            
            notify_sns(
                sns_topic_arn,
                f"Failover Testing Completed - {timestamp}",
                f"Failover test completed and primary region {primary_region} restored"
            )
            
        elif failover_mode == 'activate_dr':
            # Emergency DR activation
            notify_sns(
                sns_topic_arn,
                f"DR ACTIVATION - {timestamp}",
                f"Activating DR environment in {dr_region} due to emergency failover request"
            )
            
            # Disable primary health check
            toggle_health_check(primary_health_check_id, 'disable')
            
            # Scale up DR environment
            scale_asg(dr_asg_name, dr_region, 2, 6, 4)
            
        elif failover_mode == 'restore':
            # Restore primary environment
            notify_sns(
                sns_topic_arn,
                f"Primary Restoration - {timestamp}",
                f"Restoring primary environment in {primary_region}"
            )
            
            # Re-enable primary health check
            toggle_health_check(primary_health_check_id, 'enable')
            
            # Scale down DR environment
            scale_asg(dr_asg_name, dr_region, 1, 4, 1)
            
        return {
            'statusCode': 200,
            'body': json.dumps(f'Failover operation completed: {failover_mode}')
        }
    except Exception as e:
        # Error handling
        error_message = f"Error during failover operation: {str(e)}"
        notify_sns(
            sns_topic_arn,
            f"FAILOVER ERROR - {timestamp}",
            error_message
        )
        return {
            'statusCode': 500,
            'body': json.dumps(error_message)
        }
EOF
    filename = "lambda_function.py"
  }
}

# Upload Lambda code to S3
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "failover_lambda.zip"
  source = data.archive_file.failover_lambda.output_path
  etag   = filemd5(data.archive_file.failover_lambda.output_path)
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-lambda-role"
    Environment = var.environment
    Project     = var.project
  }
}

# IAM policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.project}-${var.environment}-lambda-policy"
  description = "Policy to allow Lambda functions to perform failover operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "route53:GetHealthCheck",
          "route53:UpdateHealthCheck"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda function
resource "aws_lambda_function" "failover_lambda" {
  function_name = "${var.project}-${var.environment}-failover-test"
  description   = "Lambda function to test and manage failover between primary and DR regions"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900  # 15 minutes
  memory_size   = 128

  s3_bucket = aws_s3_bucket.lambda_code.id
  s3_key    = aws_s3_object.lambda_code.key

  environment {
    variables = {
      PRIMARY_HEALTH_CHECK_ID = var.primary_health_check_id
      DR_HEALTH_CHECK_ID      = var.dr_health_check_id
      PRIMARY_ASG_NAME        = var.primary_asg_name
      DR_ASG_NAME             = var.dr_asg_name
      PRIMARY_REGION          = var.primary_region
      DR_REGION               = var.dr_region
      SNS_TOPIC_ARN           = var.sns_topic_arn
      FAILOVER_MODE           = "test"  # Default mode
    }
  }

  tags = {
    Name        = "${var.project}-${var.environment}-failover-lambda"
    Environment = var.environment
    Project     = var.project
  }
}

# CloudWatch Event Rule for scheduled testing
resource "aws_cloudwatch_event_rule" "scheduled_failover_test" {
  name                = "${var.project}-${var.environment}-failover-test"
  description         = "Schedule for automated failover testing"
  schedule_expression = var.test_schedule

  tags = {
    Name        = "${var.project}-${var.environment}-failover-test-rule"
    Environment = var.environment
    Project     = var.project
  }
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "failover_lambda_target" {
  rule      = aws_cloudwatch_event_rule.scheduled_failover_test.name
  target_id = "FailoverLambda"
  arn       = aws_lambda_function.failover_lambda.arn
}

# Lambda permission for CloudWatch Event
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_failover_test.arn
}