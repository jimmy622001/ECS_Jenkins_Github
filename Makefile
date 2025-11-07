.PHONY: help lint security terratest terratest-validate pre-commit all-tests clean

# Default target - show help
help:
	@echo "Available targets:"
	@echo "  lint       - Run Terraform linting with tflint"
	@echo "  security   - Run security scanning with Checkov"
	@echo "  terratest  - Run Terratest infrastructure tests"
	@echo "  pre-commit - Run pre-commit hooks"
	@echo "  all-tests  - Run all tests (lint, security, terratest)"
	@echo "  clean      - Clean up test artifacts"

# Run Terraform linting
lint:
	@echo "Running Terraform linting..."
	tflint --recursive --format compact

# Run security scanning
security:
	@echo "Running security scanning with Checkov..."
	checkov -d . --config-file .checkov.yaml

# Run Terratest validation tests (doesn't create resources)
terratest-validate:
	@echo "Running Terraform validation tests with Terratest..."
	cd test/terratest && go test -v -run TestTerraformValidate

# Run full Terratest (creates and destroys real infrastructure)
terratest:
	@echo "Running full infrastructure tests with Terratest..."
	cd test/terratest && go test -v ./...

# Run pre-commit hooks
pre-commit:
	@echo "Running pre-commit hooks..."
	pre-commit run --all-files

# Run all tests (without real infrastructure creation)
all-tests: lint security terratest-validate

# Run all tests including infrastructure tests
all-tests-full: lint security terratest

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	rm -rf test/terratest/reports
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate*" -type f -not -path "./terraform.tfstate" -not -path "./environments/*/terraform.tfstate" -exec rm -f {} +
	find . -name "*.tfplan" -type f -exec rm -f {} +