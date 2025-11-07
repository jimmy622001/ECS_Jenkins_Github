# CI/CD Integration Guide

This document explains how the security scanning tools (Checkov and TFLint) are integrated into the CI/CD pipeline.

## GitHub Actions Workflow

Our GitHub Actions workflow runs automatically on all pull requests to main and develop branches, as well as direct pushes to these branches.

### What it does:

1. **Terraform Format Check**: Ensures consistent code formatting
2. **TFLint**: Applies linting rules to catch errors and enforce best practices
3. **Checkov Security Scan**: Performs static code analysis to identify security issues

### Configuration

The workflow is defined in `.github/workflows/terraform-checks.yml`

Example failures you might see:
- Format violations: Inconsistent indentation, unnecessary newlines, etc.
- TFLint warnings: Deprecated syntax, naming convention violations, etc.
- Checkov findings: Security misconfigurations, compliance violations, etc.

## Jenkins Pipeline Integration

The Jenkinsfile includes dedicated stages for security scanning.

### Pipeline Stages

#### Security Scan - Checkov
```groovy
stage('Security Scan - Checkov') {
    steps {
        sh 'pip install checkov'
        sh 'checkov -d . --skip-check CKV_AWS_23,CKV_AWS_24 --output cli --output junitxml --output-file-path reports/checkov'
    }
    post {
        always {
            junit skipPublishingChecks: true, testResults: 'reports/checkov/results_junitxml.xml'
        }
    }
}
```

#### Lint - TFLint
```groovy
stage('Lint - TFLint') {
    steps {
        sh 'curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash'
        sh 'tflint --init'
        sh 'tflint --recursive --format junit > reports/tflint-report.xml || true'
    }
    post {
        always {
            junit skipPublishingChecks: true, testResults: 'reports/tflint-report.xml'
        }
    }
}
```

## Configuring Jenkins

To properly set up Jenkins for these scans:

1. Install required plugins:
   - JUnit Plugin
   - Warnings Next Generation Plugin
   - HTML Publisher Plugin

2. Ensure the Jenkins agent has these dependencies:
   - Python 3.x
   - pip
   - curl

3. Configure Jenkins credentials:
   - AWS credentials for terraform operations
   - GitHub access token if needed

## Handling Scan Results

### In GitHub Actions:
- Results appear directly in the workflow run output
- Security issues are highlighted in the PR comments

### In Jenkins:
- Test reports are published as JUnit XML
- The pipeline will continue even if issues are found
- Review the "Test Results" section in the Jenkins job to see details

## Customizing Security Rules

### Checkov Configuration
Edit `.checkov.yaml` to:
- Skip specific checks
- Add custom policies
- Change output formats

### TFLint Configuration
Edit `.tflint.hcl` to:
- Enable/disable specific rules
- Set rule parameters
- Configure AWS provider rules

## Example: Adding a Custom Check

For Checkov, you can create custom policies:

```python
# custom_checks/rds_encryption.py
from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class RDSEncryption(BaseResourceCheck):
    def __init__(self):
        name = "Ensure RDS instances are encrypted"
        id = "MY_CUSTOM_RDS_ENCRYPTION"
        supported_resources = ['aws_db_instance']
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        if 'storage_encrypted' in conf.keys():
            if conf['storage_encrypted'][0]:
                return CheckResult.PASSED
        return CheckResult.FAILED

check = RDSEncryption()
```

Then update your .checkov.yaml to include this check:

```yaml
external-checks-dir:
  - custom_checks/
```

## Best Practices

1. **Address issues early**: Fix security and linting issues at the PR stage
2. **Don't ignore warnings**: Even "minor" issues can indicate bigger problems
3. **Update configurations**: Periodically review and update security rules
4. **Enable pre-commit hooks**: Catch issues before they reach CI/CD
