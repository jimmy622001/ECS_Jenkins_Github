# Testing Usage Guide

This guide explains how to use the testing tools included in the ECS Jenkins GitHub project.

## Table of Contents
1. [Pre-commit Hooks](#pre-commit-hooks)
2. [Terratest](#terratest)
3. [Checkov Security Scanning](#checkov-security-scanning)
4. [TFLint](#tflint)
5. [Setting up Your Development Environment](#setting-up-your-development-environment)

## Pre-commit Hooks

Pre-commit hooks help catch issues before committing code. They run automatically when you commit changes if set up correctly.

### Setting Up Pre-commit

1. **Install pre-commit**:
   ```bash
   pip install pre-commit
   ```

2. **Install the git hooks**:
   ```bash
   pre-commit install
   ```

3. **Run manually on all files**:
   ```bash
   pre-commit run --all-files
   ```

### Available Pre-commit Hooks

- **terraform_fmt**: Formats Terraform code
- **terraform_docs**: Updates documentation in README.md files
- **terraform_tflint**: Lints Terraform code
- **terraform_checkov**: Runs security checks on Terraform code
- **terratest**: Runs Terratest validation tests
- **go-fmt**: Formats Go code
- **go-vet**: Analyzes Go code for suspicious constructs
- **go-lint**: Lints Go code

### Skipping Pre-commit Hooks

If you need to bypass pre-commit hooks temporarily:

```bash
git commit -m "Your message" --no-verify
```

However, CI checks will still run these checks and may fail the build.

### Disabling Specific Hooks

To disable specific hooks, create a `.pre-commit-config.yaml` file in your home directory with:

```yaml
repos:
- repo: local
  hooks:
  - id: skip-terraform-checkov
    name: Skip Terraform Checkov
    entry: echo "Skipping Terraform Checkov"
    language: system
    files: \.tf$
    stages: [commit]
    # This will override the hook with the same name from the project configuration
```

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
# Using pre-commit
pre-commit run terraform_checkov --all-files

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
# Using pre-commit
pre-commit run terraform_tflint --all-files

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
   
   # Install pre-commit
   pip install pre-commit
   
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
   pre-commit install
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
   pre-commit run --all-files
   ```

### CI/CD Integration

Tests automatically run in GitHub Actions on:
- Pull requests to main branch (validation tests only)
- Push to main branch (all tests)
- Manual trigger from Actions tab