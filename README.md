# ECS Jenkins GitHub

This project sets up AWS ECS infrastructure for running Jenkins with GitHub integration.

## Features

- AWS ECS Cluster for Jenkins
- Auto Scaling Group configuration
- VPC and Networking setup
- Security Groups
- Jenkins controller and agent configuration
- GitHub integration for CI/CD

## Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Security Scanning](docs/SECURITY_SCANNING.md)
- [Terraform Modules](docs/TERRAFORM_MODULES.md)
- [SonarCloud Integration](docs/SONARCLOUD_INTEGRATION.md)

## Prerequisites

- AWS CLI configured
- Terraform v0.14.x or later
- GitHub account with admin rights to repository

## Quick Start

1. Clone this repository
2. Update `terraform.tfvars` with your configuration
3. Run `terraform init` to initialize
4. Run `terraform plan` to preview changes
5. Run `terraform apply` to provision infrastructure

## Security Checks

This project includes multiple security scanning tools:

- Checkov for infrastructure security scanning
- TFLint for Terraform linting
- pre-commit hooks for automated checks
- SonarCloud for code quality and security analysis

See [Security Scanning](docs/SECURITY_SCANNING.md) for more information.