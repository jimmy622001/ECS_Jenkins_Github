# OWASP Security Module for Terraform

This module implements OWASP security best practices for AWS infrastructure using Terraform.

## Features

### 1. AWS WAF with OWASP Top 10 Protections

The module configures AWS WAF (Web Application Firewall) with rule sets that protect against the OWASP Top 10 vulnerabilities:

- **A1:2017 Injection** - SQL injection protection via AWS Managed Rules
- **A2:2017 Broken Authentication** - Rate limiting to prevent brute force attacks
- **A3:2017 Sensitive Data Exposure** - TLS 1.2+ enforcement on ALB
- **A4:2017 XML External Entities (XXE)** - Blocked by AWS Managed Rules
- **A5:2017 Broken Access Control** - IP-based access control for known bad actors
- **A6:2017 Security Misconfiguration** - Secure headers implementation
- **A7:2017 Cross-Site Scripting (XSS)** - XSS protection via AWS Managed Rules
- **A8:2017 Insecure Deserialization** - Request size limiting and validation
- **A9:2017 Using Components with Known Vulnerabilities** - Bot control and known bad inputs
- **A10:2017 Insufficient Logging & Monitoring** - WAF logging to S3, CloudWatch metrics

### 2. Security Monitoring & Compliance

- **AWS GuardDuty** - For continuous threat detection
- **AWS Config** - For monitoring security configuration compliance
- **CloudWatch Dashboard** - For security visualization
- **AWS Security Hub** (optional) - For comprehensive security posture management

### 3. Secure Headers Implementation

Enhanced security headers based on OWASP recommendations:

- **Content Security Policy (CSP)** - Prevents XSS and data injection attacks
- **HTTP Strict Transport Security (HSTS)** - Forces HTTPS connections
- **X-Content-Type-Options** - Prevents MIME type sniffing
- **X-Frame-Options** - Prevents clickjacking
- **X-XSS-Protection** - Additional XSS protection for older browsers
- **Referrer Policy** - Controls information in the Referer header

## Usage

```hcl
module "security" {
  source = "./modules/security"

  project     = var.project_name
  environment = var.environment
  aws_region  = var.aws_region
  alb_arn     = module.ecs.alb_arn

  # IP addresses to block - can be customized per environment
  blocked_ip_addresses = var.blocked_ip_addresses

  # Rate limiting settings
  max_request_size    = var.max_request_size
  request_limit       = var.request_limit
  enable_security_hub = var.enable_security_hub
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project | Name of the project | string | n/a |
| environment | Environment (dev, staging, prod) | string | n/a |
| alb_arn | ARN of the Application Load Balancer | string | n/a |
| aws_region | AWS region | string | n/a |
| blocked_ip_addresses | List of IP addresses to block | list(string) | [] |
| max_request_size | Maximum allowed request size in bytes | number | 131072 (128 KB) |
| request_limit | Maximum requests allowed per 5 minutes from a single IP | number | 1000 |
| enable_security_hub | Whether to enable AWS Security Hub | bool | false |

## Outputs

| Name | Description |
|------|-------------|
| web_acl_id | ID of the WAF Web ACL |
| web_acl_arn | ARN of the WAF Web ACL |
| security_alerts_topic_arn | ARN of the SNS topic for security alerts |
| guardduty_detector_id | ID of the GuardDuty detector |
| s3_waf_logs_bucket | S3 bucket for WAF logs |
| s3_config_bucket | S3 bucket for AWS Config |
| security_dashboard_name | Name of the CloudWatch dashboard for security monitoring |

## Notes

1. This module implements multiple layers of security following the defense-in-depth principle.
2. Consider enabling AWS Shield Advanced for additional DDoS protection in production environments.
3. The WAF rules are configured to be in "count" mode initially - review logs before switching to "block" mode.
4. Security Hub integration requires an additional subscription to the service.
