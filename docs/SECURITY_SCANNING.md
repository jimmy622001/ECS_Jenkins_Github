# Security Scanning and Linting

This project includes automated security scanning and linting as part of the CI/CD process to ensure code quality and security best practices are followed.

## Tools Used

### SonarCloud

[SonarCloud](https://sonarcloud.io/) is a cloud-based code quality and security service. It performs automatic reviews with static code analysis to detect bugs, code smells, and security vulnerabilities in your codebase.

#### Features

- **Code Quality Analysis**: Identifies code quality issues, bugs, and vulnerabilities
- **Security Hotspots**: Highlights security-sensitive code that requires manual review
- **Pull Request Decoration**: Adds comments directly to pull requests
- **Quality Gates**: Enforces quality standards that code must meet before deployment

#### Usage

- **In CI/CD pipeline**: Automatically runs on all pull requests and in Jenkins pipelines
- **Viewing Results**: Access results in SonarCloud dashboard or directly in PRs
- **Configuration**: Settings are defined in `sonar-project.properties` file

For complete details on the SonarCloud integration, see [SONARCLOUD_INTEGRATION.md](SONARCLOUD_INTEGRATION.md).

### Checkov

[Checkov](https://www.checkov.io/) is a static code analysis tool for infrastructure-as-code (IaC) that scans cloud infrastructure resources defined in Terraform, CloudFormation, Kubernetes, Serverless, and ARM templates for security and compliance issues.

#### Usage

- **In CI/CD pipeline**: Automatically runs on all pull requests and in Jenkins pipelines
- **Locally**: Run the following command to scan your code:
  ```bash
  # Install Checkov
  pip install checkov

  # Run scan
  checkov -d . --config-file .checkov.yaml
  ```

#### Custom Rules

We've configured Checkov to skip certain checks that aren't applicable to our environment. These are defined in the `.checkov.yaml` file.

### TFLint

[TFLint](https://github.com/terraform-linters/tflint) is a Terraform linter focused on checking for possible errors, best practices, and naming conventions.

#### Usage

- **In CI/CD pipeline**: Automatically runs on all pull requests and in Jenkins pipelines
- **Locally**: Run the following commands:
  ```bash
  # Install TFLint
  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

  # Initialize plugins
  tflint --init

  # Run lint
  tflint --config=.tflint.hcl --recursive
  ```

### Local Quality Checks

We provide scripts and Make targets to run these checks locally before pushing changes.

#### Windows Usage

```cmd
# Install required tools
install-tools.cmd

# Run all checks
check-terraform.cmd
```

#### Linux/Mac Usage

```bash
# Run all checks
make check-all

# Or run specific checks
make security
make lint
```

## CI/CD Integration

### GitHub Actions

Security scans run automatically on all pull requests to the main and develop branches. Check the following workflow files for details:
- `.github/workflows/terraform-checks.yml` - Terraform checks
- `.github/workflows/sonarcloud.yml` - SonarCloud analysis

### Jenkins

The Jenkins pipeline includes stages for:
- Running Checkov security scans
- Running TFLint for linting
- Checking Terraform formatting

Results are displayed in the Jenkins UI as test results and are available in the reports directory.

## Handling Security Findings

1. Review all security findings from Checkov
2. Address critical and high-severity issues before merging code
3. For false positives, update the `.checkov.yaml` file with appropriate skip directives
4. Document any accepted risks and mitigations

## Best Practices

1. Run security scans locally before pushing changes
2. Keep security scanning tools updated in the CI/CD pipeline
3. Periodically review skipped checks to ensure they're still valid
4. Review and update security policies as cloud provider security features evolve
