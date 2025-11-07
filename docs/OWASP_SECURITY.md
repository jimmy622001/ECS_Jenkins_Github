# OWASP Security Implementation Guide

This document provides guidance on how the OWASP security features are implemented in the ECS Jenkins GitHub project and how to use them effectively.

## Overview

The security implementation in this project follows the OWASP (Open Web Application Security Project) recommendations and best practices to protect against common web application vulnerabilities. The security features are implemented primarily through the `security` module, which adds AWS WAF, GuardDuty, and AWS Config to provide multi-layered security protection.

## Components

### 1. AWS WAF (Web Application Firewall)

AWS WAF is configured to protect against the OWASP Top 10 vulnerabilities:

- **SQL Injection Protection**: Blocks SQL injection attempts
- **XSS Protection**: Blocks cross-site scripting attacks
- **Size Constraint**: Prevents abnormally large requests
- **Rate-Based Protection**: Limits request rate to prevent DDoS attacks
- **Known Bad Inputs Protection**: Blocks common attack patterns
- **IP-based Protection**: Blocks requests from known malicious IPs

#### How to customize WAF rules:

To block specific IP addresses, update the `blocked_ip_addresses` variable in your environment's terraform.tfvars file:

```hcl
blocked_ip_addresses = ["203.0.113.1", "198.51.100.2"]
```

To adjust rate limiting:

```hcl
request_limit = 500  # Lower for stricter protection
```

To adjust maximum request size:

```hcl
max_request_size = 65536  # 64 KB
```

### 2. Security Headers

The application implements recommended security headers through CloudFront:

- **Content-Security-Policy**: Controls resources the browser is allowed to load
- **X-Content-Type-Options**: Prevents MIME-type sniffing
- **X-Frame-Options**: Prevents clickjacking via iframe embedding
- **X-XSS-Protection**: Enables browser-level XSS filtering
- **Strict-Transport-Security**: Forces HTTPS connections
- **Referrer-Policy**: Controls information sent in the Referer header

### 3. TLS Configuration

The application enforces modern TLS protocols:

- **Minimum TLS Version**: TLS 1.2
- **Secure Cipher Suites**: Using ELBSecurityPolicy-TLS-1-2-2017-01

### 4. GuardDuty

AWS GuardDuty is enabled for continuous threat detection:

- Monitors for malicious activity and unauthorized behavior
- Analyzes AWS CloudTrail logs, VPC Flow Logs, and DNS logs
- Sends findings to the security alerts SNS topic

### 5. AWS Config

AWS Config monitors security compliance:

- Tracks resource configurations against security best practices
- Evaluates resources against security rules
- Sends notifications when resources violate policies

### 6. Security Dashboard

A CloudWatch dashboard provides visibility into security events:

- WAF blocked requests
- WAF allowed requests
- WAF rule triggers

## Implementation by Environment

### Development Environment

The development environment has less restrictive security settings:

- WAF rules are set to "Count" mode to monitor without blocking
- Lower request rate limits
- Security Hub is disabled by default

### Production Environment

For production, you should enable stricter security:

```hcl
module "ecs_jenkins_github" {
  # Other settings...

  # OWASP Security settings
  blocked_ip_addresses = var.blocked_ip_addresses
  max_request_size     = 65536  # 64 KB - stricter than dev
  request_limit        = 500    # Lower than dev for better protection
  enable_security_hub  = true   # Enable Security Hub in production
}
```

## Monitoring Security Events

### WAF Logs

WAF logs are stored in an S3 bucket and can be analyzed using Amazon Athena or other log analysis tools.

To query WAF logs with Athena:

1. Create an Athena table for the WAF logs
2. Run queries to analyze blocked requests
3. Set up automated alerts based on specific patterns

### GuardDuty Findings

GuardDuty findings are sent to the security alerts SNS topic. You can:

1. Subscribe an email address to receive notifications
2. Integrate with a SIEM solution
3. Trigger automated remediation with AWS Lambda

### AWS Config Compliance

AWS Config evaluation results can be viewed in the AWS Console.

## Security Best Practices

1. **Regularly review WAF logs** to identify potential threats
2. **Tune WAF rules** based on false positives/negatives
3. **Subscribe to the security alerts topic** for timely notifications
4. **Periodically test** the security controls with penetration testing
5. **Update IP blocklists** with known threat actors

## Adding Custom WAF Rules

To add custom WAF rules, modify the `modules/security/main.tf` file:

```hcl
# Example custom rule to block specific User-Agent strings
rule {
  name     = "BlockMaliciousUserAgents"
  priority = 100

  action {
    block {}
  }

  statement {
    byte_match_statement {
      field_to_match {
        single_header {
          name = "user-agent"
        }
      }
      positional_constraint = "CONTAINS"
      search_string         = "Malicious-Bot"
      text_transformation {
        priority = 0
        type     = "NONE"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "BlockMaliciousUserAgents"
    sampled_requests_enabled   = true
  }
}
```

## Additional Security Enhancements

Consider implementing these additional security measures:

1. **AWS Shield Advanced** for enhanced DDoS protection
2. **Certificate Manager** for managed certificate lifecycle
3. **AWS Network Firewall** for deeper network-layer protection
4. **AWS Systems Manager Session Manager** for secure server access without SSH
5. **AWS IAM Access Analyzer** for resource access review
