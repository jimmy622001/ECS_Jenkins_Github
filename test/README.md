# Testing Framework

This directory contains the testing framework for the Terraform ECS Jenkins project. The tests are organized by type to better represent their functionality.

## Directory Structure

```
test/
├── terratest/            # Infrastructure tests using Terratest (Go)
│   ├── validation_test.go   # Terraform validation tests
│   ├── network_test.go      # Network module tests
│   ├── ecs_test.go          # ECS module tests
│   └── security_test.go     # Security module tests
├── unit/                 # Unit tests for individual modules
│   └── README.md            # Instructions for unit tests
└── integration/          # Integration tests across modules
    └── README.md            # Instructions for integration tests
```

## Test Categories

1. **Terratest**: Uses Go to validate and test Terraform modules, can create real AWS resources
2. **Unit Tests**: Validates individual module functionality without creating resources
3. **Integration Tests**: Tests interactions between multiple modules

## Running Tests

### Terratest

```bash
# Run validation tests only (no resource creation)
cd test/terratest
go test -v -run TestTerraformValidate

# Run all tests (creates real AWS resources)
cd test/terratest
go test -v ./...
```

### Using the Makefile

```bash
# Run all tests
make test-all

# Run validation tests only
make test-validate

# Run unit tests
make test-unit

# Run integration tests
make test-integration
```

## CI/CD Integration

Tests are automatically run as part of the Jenkins pipeline defined in the Jenkinsfile at the root of the project. The pipeline runs different test sets based on the deployment stage:

1. **Pull Request Stage**: Runs validation tests only
2. **Main Branch**: Runs both validation and unit tests
3. **Deployment Stage**: Runs validation, unit and selected integration tests

## Adding New Tests

See each directory's README.md file for specific instructions on adding new tests of that type.