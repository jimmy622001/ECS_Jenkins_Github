# Integration Tests

This directory contains integration tests for the Terraform modules. These tests validate that multiple modules work correctly together.

## Test Scenarios

- **Network + ECS**: Tests that ECS resources deploy correctly in the network module's VPC and subnets
- **Security + Database**: Tests security group configurations properly control access to database resources
- **End-to-end environment**: Tests complete environment provisioning across all modules

## Running Tests

Integration tests can be run using the commands defined in the Makefile:

```bash
# Run all integration tests
make test-integration

# Run specific integration test
cd test/integration
./run_<test_name>.sh
```

⚠️ **Warning**: Integration tests create real AWS resources that may incur costs. They automatically destroy resources when complete, but use caution and ensure proper AWS credentials are configured.