.PHONY: help fmt lint docs security validate check-all all-tests clean

# Default target - show help
help:
	@echo "Available targets:"
	@echo "  fmt        - Run Terraform format"
	@echo "  lint       - Run Terraform linting with tflint"
	@echo "  docs       - Update Terraform documentation"
	@echo "  security   - Run security scanning with Checkov"
	@echo "  validate   - Run Terraform validate"
	@echo "  check-all  - Run all checks (fmt, lint, docs, security, validate)"
	@echo "  all-tests  - Run all tests (check-all + any additional tests)"
	@echo "  clean      - Clean up test artifacts"

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Run Terraform linting
lint:
	@echo "Running Terraform linting..."
	tflint --recursive --format compact

# Generate Terraform documentation
docs:
	@echo "Updating Terraform documentation..."
	@command -v terraform-docs >/dev/null 2>&1 || { echo "Error: terraform-docs is not installed. Install it from https://github.com/terraform-docs/terraform-docs/releases"; exit 1; }
	find . -path "./modules/*" -type d -maxdepth 2 -exec bash -c 'if [ -f "{}/main.tf" ]; then echo "Updating docs for {}"; terraform-docs markdown table "{}" > "{}/README.md"; fi' \;

# Run security scanning
security:
	@echo "Running security scanning with Checkov..."
	checkov -d . --config-file .checkov.yaml

# Validate Terraform configurations
validate:
	@echo "Validating Terraform configurations..."
	find . -name "*.tf" -not -path "*/\.*" -not -path "*/\terraform/*" -exec dirname {} \; | sort -u | xargs -I {} bash -c 'echo "Validating {}"; cd {} && terraform init -backend=false -input=false && terraform validate'

# Run all checks
check-all: fmt lint docs security validate

# Run all tests (without real infrastructure creation)
all-tests: check-all

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	find . -name ".terraform" -type d -exec rm -rf {} \; 2>/dev/null || true
	find . -name "terraform.tfstate*" -type f -not -path "./terraform.tfstate" -not -path "./environments/*/terraform.tfstate" -exec rm -f {} \; 2>/dev/null || true
	find . -name "*.tfplan" -type f -exec rm -f {} \; 2>/dev/null || true
	rm -rf reports/* 2>/dev/null || true