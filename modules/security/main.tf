# OWASP Security Module for AWS Infrastructure
# This module implements AWS WAF with OWASP Top 10 protections

# WAF IP Set for known bad IPs (can be regularly updated)
resource "aws_wafv2_ip_set" "known_bad_ips" {
  name               = "${var.project}-${var.environment}-bad-ips"
  description        = "Known malicious IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_addresses

  tags = {
    Name        = "${var.project}-${var.environment}-bad-ips"
    Environment = var.environment
    Project     = var.project
  }
}

# AWS WAF Web ACL with OWASP Top 10 Protections
resource "aws_wafv2_web_acl" "owasp_top10_protection" {
  name        = "${var.project}-${var.environment}-owasp-protection"
  description = "WAF WebACL with OWASP Top 10 protections"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule #1: Block IPs from blocklist
  rule {
    name     = "block-known-bad-ips"
    priority = 0

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.known_bad_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockKnownBadIPs"
      sampled_requests_enabled   = true
    }
  }

  # Rule #2: AWS Managed Rules for SQL Injection
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule #3: AWS Managed Rules for XSS Protection
  rule {
    name     = "AWS-AWSManagedRulesXSSRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesXSSRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesXSSRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule #4: Size Constraint Rule - Prevents abnormally large requests
  rule {
    name     = "SizeConstraint"
    priority = 30

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        field_to_match {
          body {}
        }
        comparison_operator = "GT"
        size                = var.max_request_size
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SizeConstraint"
      sampled_requests_enabled   = true
    }
  }

  # Rule #5: Rate-Based Rule for DDoS protection
  rule {
    name     = "RateBasedRule"
    priority = 40

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.request_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateBasedRule"
      sampled_requests_enabled   = true
    }
  }

  # Rule #6: AWS Managed Rules for Known Bad Inputs
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 50

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule #7: AWS Managed Rules for OWASP Core Ruleset
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 60

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule #8: AWS Managed Rules for PHP applications
  rule {
    name     = "AWS-AWSManagedRulesPHPRuleSet"
    priority = 70

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesPHPRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule #9: AWS Managed Rules for Linux OS
  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 80

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule #10: AWS Managed Rules for Bot Control
  rule {
    name     = "AWS-AWSManagedRulesBotControlRuleSet"
    priority = 90

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesBotControlRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "owasp-top10-protection"
    sampled_requests_enabled   = true
  }

  # Prevent terraform from rebuilding this resource unless actual changes are made
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project}-${var.environment}-waf"
    Environment = var.environment
    Project     = var.project
  }
}

# Associate WAF WebACL with Application Load Balancer
resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.owasp_top10_protection.arn
}

# AWS Shield Advanced (Optional - Uncomment if required)
# resource "aws_shield_protection" "alb_shield" {
#   name         = "${var.project}-${var.environment}-alb-protection"
#   resource_arn = var.alb_arn
# }

# AWS Config for Security Compliance
resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.project}-${var.environment}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    resource_types = [
      "AWS::EC2::Instance",
      "AWS::EC2::SecurityGroup",
      "AWS::ECS::Cluster",
      "AWS::ElasticLoadBalancingV2::LoadBalancer",
      "AWS::S3::Bucket",
      "AWS::RDS::DBInstance",
      "AWS::IAM::Role",
      "AWS::IAM::Policy"
    ]
  }
}

resource "aws_config_delivery_channel" "channel" {
  name           = "${var.project}-${var.environment}-config-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  s3_key_prefix  = "config"
  sns_topic_arn  = aws_sns_topic.security_alerts.arn
  depends_on     = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

# Config S3 bucket
resource "aws_s3_bucket" "config_bucket" {
  bucket        = "${var.project}-${var.environment}-config-${random_string.bucket_suffix.result}"
  force_destroy = var.environment != "prod"

  tags = {
    Name        = "${var.project}-${var.environment}-config-bucket"
    Environment = var.environment
    Project     = var.project
  }
}

# Block public access to config bucket
resource "aws_s3_bucket_public_access_block" "config_bucket_block" {
  bucket                  = aws_s3_bucket.config_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket encryption for config bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket_encryption" {
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# SNS Topic for Security Alerts
resource "aws_sns_topic" "security_alerts" {
  name = "${var.project}-${var.environment}-security-alerts"

  tags = {
    Name        = "${var.project}-${var.environment}-security-alerts"
    Environment = var.environment
    Project     = var.project
  }
}

# IAM Role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "${var.project}-${var.environment}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-config-role"
    Environment = var.environment
    Project     = var.project
  }
}

# IAM Policy for AWS Config
resource "aws_iam_role_policy" "config_policy" {
  name = "${var.project}-${var.environment}-config-policy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.config_bucket.arn}",
          "${aws_s3_bucket.config_bucket.arn}/*"
        ]
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect = "Allow"
        Resource = [
          aws_sns_topic.security_alerts.arn
        ]
      },
      {
        Action = [
          "config:Put*",
          "config:Get*",
          "config:List*",
          "config:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# AWS Config Rules for security best practices
resource "aws_config_config_rule" "restricted_ssh" {
  name = "${var.project}-${var.environment}-restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name = "${var.project}-${var.environment}-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "root_mfa" {
  name = "${var.project}-${var.environment}-root-mfa"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "iam_password_policy" {
  name = "${var.project}-${var.environment}-iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "${var.project}-${var.environment}-s3-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  name = "${var.project}-${var.environment}-s3-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "s3_bucket_ssl_requests_only" {
  name = "${var.project}-${var.environment}-s3-ssl-requests-only"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# GuardDuty for threat detection
resource "aws_guardduty_detector" "security_detector" {
  enable = true

  finding_publishing_frequency = "SIX_HOURS"

  tags = {
    Name        = "${var.project}-${var.environment}-guardduty"
    Environment = var.environment
    Project     = var.project
  }
}

# Associate GuardDuty findings with SNS topic
resource "aws_cloudwatch_event_rule" "guardduty_event" {
  name        = "${var.project}-${var.environment}-guardduty-event"
  description = "Capture GuardDuty findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_event.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts.arn
}

# Security Hub (Optional) - Uncomment if you want to enable Security Hub
resource "aws_securityhub_account" "security_hub" {
  count = var.enable_security_hub ? 1 : 0
}

# Random string for unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# WAF Logging to S3
resource "aws_s3_bucket" "waf_logs" {
  bucket        = "${var.project}-${var.environment}-waf-logs-${random_string.bucket_suffix.result}"
  force_destroy = var.environment != "prod"

  tags = {
    Name        = "${var.project}-${var.environment}-waf-logs"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_public_access_block" "waf_logs_block" {
  bucket                  = aws_s3_bucket.waf_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs_encryption" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_s3_bucket.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.owasp_top10_protection.arn
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}

# CloudWatch Dashboard for security monitoring
resource "aws_cloudwatch_dashboard" "security_dashboard" {
  dashboard_name = "${var.project}-${var.environment}-security-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAF", "BlockedRequests", "WebACL", aws_wafv2_web_acl.owasp_top10_protection.name, "Region", var.aws_region],
          ]
          period = 300
          region = var.aws_region
          title  = "WAF Blocked Requests"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAF", "AllowedRequests", "WebACL", aws_wafv2_web_acl.owasp_top10_protection.name, "Region", var.aws_region],
          ]
          period = 300
          region = var.aws_region
          title  = "WAF Allowed Requests"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/WAF", "CountedRequests", "Rule", "RateBasedRule", "WebACL", aws_wafv2_web_acl.owasp_top10_protection.name, "Region", var.aws_region],
            ["AWS/WAF", "CountedRequests", "Rule", "AWS-AWSManagedRulesSQLiRuleSet", "WebACL", aws_wafv2_web_acl.owasp_top10_protection.name, "Region", var.aws_region],
            ["AWS/WAF", "CountedRequests", "Rule", "AWS-AWSManagedRulesXSSRuleSet", "WebACL", aws_wafv2_web_acl.owasp_top10_protection.name, "Region", var.aws_region]
          ]
          period = 300
          region = var.aws_region
          title  = "WAF Rules Activity"
        }
      }
    ]
  })
}