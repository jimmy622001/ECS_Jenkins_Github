# Testing Strategy for Terraform ECS Jenkins Project

This document outlines the testing strategy for our Terraform infrastructure code.

## Testing Tools

### 1. Terratest

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a collection of helper functions and patterns for common testing tasks.

#### What it tests
- Actual resource creation and configuration
- Integration between different resources
- Real-world behavior of infrastructure

#### Types of Terratest in this project

1. **Validation Tests** (No resource creation)
   - Validates the syntax and structure of Terraform code
   - Safe to run without AWS credentials
   - First run might take a few minutes to initialize Terraform
   - Subsequent runs are faster
   - Runs on every PR automatically

2. **Full Infrastructure Tests** (Creates real resources)
   - Tests actual resource creation and configuration
   - Requires AWS credentials with appropriate permissions
   - Creates and destroys real AWS resources (costs money)
   - Runs only on main branch or via manual triggers

#### How to run Terratest

**To run validation tests only** (recommended for development):

```bash
# Using Make
make terratest-validate

# OR directly with Go
cd test/terratest
go test -v -run TestTerraformValidate
```

**To run full infrastructure tests** (creates real AWS resources):

```bash
# Using Make
make terratest

# OR directly with Go
cd test/terratest
go test -v ./...
```

**To run specific tests**:

```bash
cd test/terratest
go test -v -run TestNetworkModule
```

#### Automatic test execution in CI/CD

Terratest is configured to run automatically in GitHub Actions:

1. **All PRs**: Only validation tests run, ensuring code quality without creating resources
2. **Main branch**: Both validation and full infrastructure tests run, confirming actual functionality
3. **Manual trigger**: Full suite can be triggered manually when needed

### 2. Checkov (Static Analysis)

We use Checkov for static code analysis to identify security and compliance issues.

#### What it tests
- Security best practices
- Compliance with standards
- Common configuration mistakes

#### How to run Checkov

```bash
checkov -d . --config-file .checkov.yaml
```

### 3. TFLint (Linting)

TFLint helps find possible errors and enforces best practices in Terraform code.

#### What it tests
- Syntax issues
- Best practices
- Unused declarations
- AWS provider-specific rules

#### How to run TFLint

```bash
tflint --config=.tflint.hcl
```

## Continuous Integration

Our testing strategy is integrated into the CI/CD pipeline using Jenkins:

1. **Pull Request Checks**:
   - Terraform format and validation
   - TFLint for linting
   - Checkov for security scanning
   - Terratest for infrastructure validation

2. **Local Quality Checks**:
   - Development workflow checks via Makefile or scripts
   - Ensures code quality before pushing

## Adding New Tests

### Adding Terratest Tests

1. Create a new Go test file in `test/terratest/`
2. Import required packages:
   ```go
   import (
     "testing"
     "github.com/gruntwork-io/terratest/modules/terraform"
     "github.com/stretchr/testify/assert"
   )
   ```
3. Define test function following this pattern:
   ```go
   func TestSomething(t *testing.T) {
     terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
       TerraformDir: "../../path/to/module",
       Vars: map[string]interface{}{
         "key": "value",
       },
     })
     
     defer terraform.Destroy(t, terraformOptions)
     terraform.InitAndApply(t, terraformOptions)
     
     // Assertions
     output := terraform.Output(t, terraformOptions, "output_name")
     assert.Equal(t, "expected", output)
   }
   ```

## Best Practices

1. **Test isolation**: Each test should be independent and not rely on state from other tests
2. **Clean up resources**: Always use `defer terraform.Destroy()` to clean up after tests
3. **Meaningful assertions**: Test that the infrastructure behaves as expected
4. **Test all modules**: Aim for comprehensive test coverage across all modules
5. **Keep tests fast**: Optimize tests to run efficiently
6. **Mock external dependencies** when possible to speed up tests