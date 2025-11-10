# Terraform Tests

This directory contains infrastructure tests for the Terraform ECS Jenkins project.

## Structure

- `validation_test.go`: Tests that validate Terraform syntax without creating resources
- `network_test.go`: Tests for the network module
- `ecs_test.go`: Tests for the ECS module
- `security_test.go`: Tests for security configurations
- `integration_test.go`: End-to-end integration tests

## Running Tests

To run validation tests only (no resource creation):

```bash
go test -v -run TestTerraformValidate
```

To run all tests (will create real AWS resources):

```bash
go test -v ./...
```

To run specific test file:

```bash
go test -v security_test.go
```