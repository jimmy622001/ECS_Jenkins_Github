# Security Scanning Tools Guide

This guide explains how to use the security scanning tools integrated with this project.

## Table of Contents

1. [Overview](#overview)
2. [Checkov](#checkov)
3. [TFLint](#tflint)
4. [Pre-commit Hooks](#pre-commit-hooks)
5. [CI/CD Integration](#cicd-integration)
6. [Custom Rules](#custom-rules)
7. [Troubleshooting](#troubleshooting)

## Overview

This project integrates multiple security scanning tools to ensure infrastructure-as-code best practices and detect security vulnerabilities:

- **Checkov**: Scans Terraform code for security issues and compliance violations
- **TFLint**: Verifies Terraform code against AWS best practices and style conventions
- **Pre-commit hooks**: Runs security checks before code is committed
- **CI/CD integration**: Automatically runs security checks during pull requests and deployments

## Checkov

[Checkov](https://www.checkov.io/) is a static code analysis tool that scans cloud infrastructure configurations for misconfigurations.

### Running Checkov Locally

```bash
# Run Checkov on the entire project
checkov -d .

# Run Checkov on a specific directory
checkov -d ./modules/ecs/

# Run Checkov with specific checks
checkov -d . --check CKV_AWS_23,CKV_AWS_41

# Run Checkov and output results to JSON
checkov -d . --output-file-path checkov_results.json --output json
```

### Understanding Checkov Results

Checkov output includes:
- Failed checks with explanations
- Resources affected by each issue
- Guidelines for remediation
- References to security standards

### Skipping Specific Checks

To skip specific Checkov checks in your Terraform code:

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  
  # checkov:skip=CKV_AWS_18: This bucket doesn't need logging for development environment
  # checkov:skip=CKV_AWS_21: Public access is required for this specific use case
}
```

## TFLint

[TFLint](https://github.com/terraform-linters/tflint) checks for possible errors, best practices, and deprecated syntax.

### Running TFLint Locally

```bash
# Run TFLint on the entire project
tflint

# Run TFLint on a specific directory
cd modules/ecs && tflint

# Run TFLint and output results to JSON
tflint --format json
```

### Understanding TFLint Results

TFLint provides:
- Syntax errors and deprecated features
- AWS best practice violations
- Style recommendations
- Resource naming issues

### TFLint Configuration

The `.tflint.hcl` file in the project root configures TFLint behavior:

```hcl
plugin "aws" {
  enabled = true
  version = "0.21.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}
```

## Pre-commit Hooks

[Pre-commit](https://pre-commit.com/) hooks run checks before code is committed.

### Setup

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run hooks against all files
pre-commit run --all-files
```

### Available Hooks

The `.pre-commit-config.yaml` file includes:
- Terraform validation
- Terraform formatting
- Checkov scanning
- TFLint validation
- Secret detection

## CI/CD Integration

Security scanning is integrated into the CI/CD pipeline via:

### GitHub Actions

The workflow in `.github/workflows/terraform-checks.yml` automatically runs:
- Checkov security scans
- TFLint validation
- Terraform validation

### Jenkins Pipeline

The `Jenkinsfile` includes security scanning stages:
- Scan pull requests for security issues
- Produce security reports
- Block deployments with critical security issues

## Custom Rules

### Creating Custom Checkov Rules

Custom Checkov rules can be added in the `.checkov` directory:

```python
# .checkov/custom_rules/s3_bucket_naming.py
from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class S3BucketNaming(BaseResourceCheck):
    def __init__(self):
        name = "S3 buckets must follow company naming convention"
        id = "CUSTOM_001"
        supported_resources = ['aws_s3_bucket']
        categories = [CheckCategories.CONVENTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        if 'bucket' in conf.keys():
            bucket_name = conf['bucket'][0]
            if bucket_name.startswith('company-'):
                return CheckResult.PASSED
            return CheckResult.FAILED
        return CheckResult.FAILED
```

## Troubleshooting

### Common Issues

1. **Checkov can't find AWS credentials**
   - Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables

2. **TFLint reports false positives**
   - Update TFLint version and rules
   - Check for rule exceptions in `.tflint.hcl`

3. **Pre-commit hooks are slow**
   - Use selective hooks (comment out CPU-intensive hooks)
   - Run hooks only on changed files

4. **CI/CD pipeline failures**
   - Check the security scan logs for specific issues
   - Update security scan thresholds if necessary