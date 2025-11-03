# Security Module

## Overview

This module implements OWASP security protections and AWS security services to protect your infrastructure against common web vulnerabilities and attacks.

## Components

### AWS WAF (Web Application Firewall)

The module creates an AWS WAF Web ACL with rules derived from the OWASP Top 10 security risks:

- **SQL Injection Protection**: Blocks common SQL injection patterns
- **XSS Protection**: Filters cross-site scripting attempts
- **Path Traversal, LFI, RFI Protection**: Prevents directory traversal and file inclusion attacks
- **HTTP Protocol Violations**: Blocks malformed HTTP requests
- **Bot Control**: Manages bot traffic with advanced rules
- **Rate Limiting**: Prevents DDoS attacks by limiting request rates
- **Geo-Blocking**: Restricts access from high-risk geographic locations
- **Known Bad Inputs**: Blocks requests with known malicious patterns

### Security Monitoring and Detection

The module sets up:

- **AWS GuardDuty**: For threat detection and continuous security monitoring
- **AWS Config**: For compliance monitoring and resource auditing
- **Security Dashboard**: CloudWatch dashboard for security metrics visualization
- **WAF Logging**: Logs all WAF actions to S3 for analysis and auditing

### Security Alerts

- Creates an SNS topic for security alerts
- Configures alerting for security-related events
- Integrates with CloudWatch alarms for security monitoring

## Usage

```hcl
module "security" {
  source = "../modules/security"
  
  # General configuration
  environment                 = var.environment
  project_name                = var.project_name
  region                      = var.aws_region
  
  # WAF configuration
  waf_enabled                 = true
  application_load_balancer_arn = module.ecs.alb_arn
  rate_limit_threshold        = 2000  # Requests per 5 minutes per IP
  geo_match_blocked_countries = ["CN", "RU", "IR", "KP"]
  
  # Security services
  enable_guardduty            = true
  enable_config               = true
  security_alerts_email       = "security@example.com"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name (dev, staging, prod) | string | - | yes |
| project_name | Project name for resource naming | string | - | yes |
| region | AWS region for resources | string | - | yes |
| waf_enabled | Whether to enable WAF protection | bool | true | no |
| application_load_balancer_arn | ARN of the ALB to protect | string | - | yes |
| rate_limit_threshold | Request threshold for rate limiting (per 5 min per IP) | number | 2000 | no |
| geo_match_blocked_countries | List of country codes to block | list(string) | [] | no |
| enable_guardduty | Whether to enable GuardDuty | bool | true | no |
| enable_config | Whether to enable AWS Config | bool | true | no |
| security_alerts_email | Email to receive security alerts | string | - | no |

## Outputs

| Name | Description |
|------|-------------|
| web_acl_id | ID of the created Web ACL |
| web_acl_arn | ARN of the created Web ACL |
| security_topic_arn | ARN of the security alerts SNS topic |
| guardduty_detector_id | ID of the GuardDuty detector |
| waf_logging_bucket | Name of the S3 bucket storing WAF logs |

## OWASP Top 10 Coverage

This module addresses the OWASP Top 10 web application security risks:

1. **Injection**: SQL injection rule group, input sanitization
2. **Broken Authentication**: Rate limiting, behavioral analysis
3. **Sensitive Data Exposure**: TLS enforcement, header controls
4. **XML External Entities (XXE)**: Request filtering, size limits
5. **Broken Access Control**: Path monitoring, authorization checks
6. **Security Misconfiguration**: Config rules, GuardDuty monitoring
7. **Cross-Site Scripting (XSS)**: XSS rule group, CSP headers
8. **Insecure Deserialization**: Bad input filtering, request validation
9. **Using Components with Known Vulnerabilities**: N/A (application-level)
10. **Insufficient Logging & Monitoring**: WAF logging, security dashboard

## Customization

The module can be customized by:

1. Adjusting rate limiting thresholds for your traffic patterns
2. Modifying the geo-blocking country list
3. Setting custom rules in the WAF configuration
4. Enabling/disabling specific AWS Managed Rule groups

## Security Best Practices

The module follows security best practices including:

- Defense in depth with multiple security layers
- Least privilege permissions for all IAM roles
- Encryption for all logs and sensitive data
- Comprehensive logging and monitoring
- Regular compliance checking