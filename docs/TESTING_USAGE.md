# Testing Usage Guide

This guide explains how to use the testing tools included in the ECS Jenkins GitHub project.

## Table of Contents
1. [Quality Control Tools](#quality-control-tools)
2. [Terratest](#terratest)
3. [Checkov Security Scanning](#checkov-security-scanning)
4. [TFLint](#tflint)
5. [Setting up Your Development Environment](#setting-up-your-development-environment)

## Quality Control Tools

Our project includes several tools to ensure code quality, security, and best practices. These can be run through simple commands.

### Using the Makefile

We provide a comprehensive Makefile to run quality checks:

```bash
# Format Terraform code
make fmt

# Run TFLint for Terraform linting
make lint

# Update module documentation
make docs

# Run Checkov security scans
make security

# Validate Terraform configurations
make validate

# Run all checks at once
make check-all
```

### Using PowerShell Scripts (Windows)

For Windows users, we provide convenient scripts:

```powershell
# Run all checks at once
.\check-terraform.cmd

# Install required tools
.\install-tools.cmd
```

### Available Quality Checks

- **terraform fmt**: Formats Terraform code for consistent style
- **terraform-docs**: Updates documentation in README.md files
- **tflint**: Lints Terraform code to catch errors and enforce best practices
- **checkov**: Runs security checks on Terraform code
- **terraform validate**: Verifies that the configuration is syntactically valid

### Integration with CI/CD

All these checks are automatically run in Jenkins when you submit a pull request or push to the main branch.

## Terratest

Terratest allows you to test your Terraform infrastructure code by creating real resources or validating syntax.

### Running Terratest

#### Validation Tests (No Resource Creation)

These tests only validate Terraform syntax without creating infrastructure:

```bash
# Using Make
make terratest-validate

# Direct Go command
cd test/terratest
go test -v -run TestTerraformValidate
```

#### Simple Module Validation

To validate a specific module:

```bash
cd test/terratest
go test -v -run TestSimpleValidate
```

#### Full Infrastructure Tests

**Warning**: These create real AWS resources and may incur costs.

```bash
# Using Make
make terratest

# Direct Go command
cd test/terratest
go test -v ./...
```

#### Running Specific Tests

```bash
cd test/terratest
go test -v -run TestNetworkModule
```

### Troubleshooting Terratest

If you encounter errors like:
- `pattern ./...: directory prefix . does not contain main module`: Run `go mod tidy` in the test/terratest directory
- AWS credential errors: Ensure AWS credentials are configured properly
- Timeout errors: Increase timeout values in test files or run specific tests

## Checkov Security Scanning

Checkov is a static code analysis tool for infrastructure as code that detects security issues.

### Running Checkov

```bash
# Using make command
make security

# Direct command
checkov -d . --config-file .checkov.yaml
```

### Skipping Specific Checks

To skip specific checks, edit the `.checkov.yaml` file:

```yaml
skip-check:
  - CKV_AWS_123  # Reason for skipping
```

## TFLint

TFLint is a Terraform linter focused on identifying potential errors and enforcing best practices.

### Running TFLint

```bash
# Using make command
make lint

# Direct command
tflint --config=.tflint.hcl
```

### Customizing TFLint Rules

Edit `.tflint.hcl` to enable or disable specific rules.

## Setting up Your Development Environment

To ensure all testing tools work properly, set up your development environment with:

1. **Install Required Tools**:
   ```bash
   # Install Go for Terratest
   choco install golang -y  # Windows with Chocolatey
   # OR
   brew install go  # macOS with Homebrew
   
   # Install Make and other build tools
   choco install make -y  # Windows with Chocolatey
   # OR
   brew install make  # macOS with Homebrew
   
   # Install Terraform
   choco install terraform -y  # Windows
   brew install terraform  # macOS
   
   # Install TFLint
   choco install tflint  # Windows
   brew install tflint  # macOS
   ```

2. **Clone the Repository and Initialize**:
   ```bash
   git clone https://github.com/your-org/ECS_Jenkins_Github.git
   cd ECS_Jenkins_Github
   # Nothing to install here anymore
   cd test/terratest
   go mod tidy
   ```

3. **Configure AWS Credentials**:
   ```bash
   aws configure --profile dev
   aws configure --profile prod
   ```

4. **Validate Setup**:
   ```bash
   make terratest-validate
   make check-all
   ```

### CI/CD Integration

Tests automatically run in Jenkins on:
- Pull requests to main branch (validation tests only)
- Push to main branch (all tests)
- Manual trigger via Jenkins pipeline