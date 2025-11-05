# Security and Compliance Scanning

This document describes the security and compliance scanning configuration for this project.

## Terraform Scanning Tools

### Checkov

Checkov is a static code analysis tool for infrastructure-as-code. It scans cloud infrastructure managed in Terraform, Cloudformation, Kubernetes, etc. and detects security and compliance misconfigurations.

```bash
# Run Checkov locally
checkov -d .
```

### TFLint

TFLint is a Terraform linter focused on possible errors and best practices.

```bash
# Run TFLint locally
tflint
```

### SonarCloud

SonarCloud provides continuous code quality and security analysis. It detects bugs, vulnerabilities, and code smells across project types.

```bash
# SonarCloud analysis is triggered automatically via GitHub Actions and Jenkins
# No manual command needed
```

For detailed SonarCloud setup and usage, see [SONARCLOUD_INTEGRATION.md](SONARCLOUD_INTEGRATION.md).

## CI/CD Integration

These scanning tools are integrated into the CI/CD pipeline:

1. **Terraform fmt**: Code formatting verification
2. **Terraform validate**: Syntax and configuration validation
3. **TFLint**: Linting checks
4. **Checkov**: Security and compliance scanning
5. **SonarCloud**: Code quality and security analysis

Refer to the Jenkinsfile for implementation details.