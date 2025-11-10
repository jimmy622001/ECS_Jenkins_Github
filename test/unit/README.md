# Unit Tests

This directory contains unit tests for the Terraform modules. These tests are designed to validate specific functionality of individual modules without requiring the creation of actual AWS resources.

## Types of Tests

- **Syntax validation**: Ensures Terraform code is properly formatted and syntactically correct
- **Variable validation**: Tests that variables are properly defined and have appropriate constraints
- **Module structure**: Verifies modules follow project conventions and best practices

## Running Tests

Unit tests can be run using the commands defined in the Makefile:

```bash
# Run all unit tests
make test-unit

# Run specific unit test
cd test/unit
./<test_script_name>.sh
```