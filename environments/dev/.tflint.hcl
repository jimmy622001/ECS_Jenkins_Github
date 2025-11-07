config {
  module = true
  force = false
}

# Disable some rules for development environment
rule "aws_resource_missing_tags" {
  enabled = false  # Disable during PoC phase
}

rule "terraform_unused_declarations" {
  enabled = false  # Allow some unused variables during development
}

rule "terraform_documented_variables" {
  enabled = true   # Still require documentation
}

rule "terraform_typed_variables" {
  enabled = true   # Still require typed variables
}

plugin "aws" {
  enabled = true
  version = "0.23.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}