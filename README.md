# ECS with Jenkins CI/CD and Monitoring Infrastructure

## Overview

This Terraform project deploys a complete AWS infrastructure including:
- VPC with public/private subnets and dedicated database subnet
- ECS Cluster using EC2 instances with blue/green deployment capability
- CI/CD pipeline with Jenkins and GitHub integration on self-healing EC2 instances
- RDS database in a private subnet
- Prometheus and Grafana monitoring solution
- Automated patching and AMI management

## Project Architecture

### Infrastructure Diagram
                              ┌─────────────────┐
                              │   GitHub Repo   │
                              └────────┬────────┘
                                       │
                                       ▼
            ┌───────────────────────────────────────────────┐
Internet ───┤              Application Load Balancer        │
└─┬─────────────────────┬──────────────────┬────┘
│                     │                  │
┌─────────▼────────┐    ┌──────▼────────┐    ┌────▼─────────┐
│                  │    │               │    │              │
│ Jenkins EC2 ASG  │    │ Prometheus    │    │ Grafana      │
│ (CI/CD)          │    │ (Monitoring)  │    │ (Dashboards) │
│                  │    │               │    │              │
└─────────┬────────┘    └───────────────┘    └──────────────┘
│
▼         ┌─────────────────────┐
┌──────────────────────┐   │ AWS Systems Manager │
│   Amazon ECR         │   │ (Patch Management) │
│   (Container Registry)│   └─────────────────────┘
└──────────┬───────────┘
│         ┌─────────────────┐
│         │  CodeDeploy    │
│         │ (Blue/Green)   │
│         └────────┬────────┘
│                  │
┌──────────────────▼─────────────────────┐
│ ECS Cluster (Fargate)                  │
│                                        │
│ ┌─────────────┐     ┌─────────────┐    │
│ │ Service 1   │     │ Service 2   │    │
│ │ (Container) │     │ (Container) │    │
│ └─────┬───────┘     └──────┬──────┘    │
└─────────┼──────────────────┼───────────┘
          │                  │
          ▼                  ▼
┌─────────────────────────────────────────┐
│ Amazon RDS Database                     │
│ (Private Subnet)                        │
└─────────────────────────────────────────┘

The infrastructure is designed with a modular approach allowing for independent deployment of components. This enables:
- Infrastructure changes without impacting applications
- Separate CI/CD processes for infrastructure and applications
- Environment-specific configurations (prod, dev, DR)

## Module Structure

The infrastructure is organized into the following modules:

### 1. Network Module
- **Purpose**: Establishes the network foundation
- **Components**:
    - VPC with public and private subnets
    - Internet Gateway and NAT Gateway
    - Route tables and security groups
    - VPC Flow logs and S3 bucket for access logs

### 2. IAM Module
- **Purpose**: Handles security and permissions
- **Components**:
    - ECS task execution and task roles
    - Jenkins IAM role for ECS deployments
    - Monitoring service roles

### 3. ECS Module
- **Purpose**: Runs containerized applications
- **Components**:
    - Cluster configuration (ec2 instances)
    - Task definitions and services with blue/green deployment capability
    - Load balancer and auto scaling
    - CodeDeploy integration for zero-downtime deployments

### 4. Database Module
- **Purpose**: Provides persistent storage
- **Components**:
    - RDS instance in private subnet
    - Encrypted storage with backups
    - High availability configuration

### 5. CI/CD Module
- **Purpose**: Enables continuous integration/deployment
- **Components**:
    - Jenkins server in Auto Scaling Group with latest ECS-optimized AMIs
    - GitHub integration setup
    - Deployment pipeline to ECS
    - Self-healing infrastructure with health checks

### 6. Monitoring Module
- **Purpose**: Observability and metrics
- **Components**:
    - Prometheus for metrics collection
    - Grafana for visualization
    - Alerting configuration

### 7. Security Module
- **Purpose**: Implements OWASP and AWS security best practices
- **Components**:
    - WAF configuration with OWASP rules
    - Security headers and TLS configuration
    - GuardDuty and AWS Config integration

## Getting Started

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform v1.0+ installed
- AWS account with appropriate permissions

### Security Features
- **Network Isolation**: All resources run in private subnets where possible
- **Encrypted Data**: Encryption at rest and in transit for all sensitive data
- **Least Privilege**: IAM roles with minimum required permissions
- **Network Monitoring**: VPC flow logs capture all network activity
- **Security Groups**: Restrictive inbound/outbound rules for all resources
- **TLS Encryption**: HTTPS for all public-facing services
- **Automated Security Scanning**: Continuous security scanning with Checkov
- **Terraform Linting**: Code quality enforcement with TFLint
- **Automated Code Checks**: Quality checks integrated with the development workflow
- **Automated Patching**: Systems Manager Patch Manager for automatic security updates
- **Instance Metadata Security**: IMDSv2 requirement enforced on all EC2 instances
- **Immutable Infrastructure**: Updated AMIs instead of in-place patching
- **OWASP Protection**: AWS WAF with OWASP Top 10 protections and security headers
- **Threat Detection**: GuardDuty for continuous security monitoring
- **Compliance Monitoring**: AWS Config for security configuration compliance
- **Security Dashboard**: CloudWatch dashboard for security metrics visualization

### Deployment

Each environment has its own deployment scripts and configurations:

1. **Initialize Environment**:
   ```bash
   cd environments/<env>   # where <env> is dev, prod, or dr-pilot-light
   terraform init
   ```

### Developer Workflow & Quality Tools

The project provides a streamlined developer workflow with built-in quality checks:

#### Installation
- For Windows users: Simply run `install-tools.cmd` to automatically install required tools
- For Linux/Mac users: Standard tool installation via package managers

#### Local Quality Checks
- Run `check-terraform.cmd` (Windows) or `make check-all` (Linux/Mac) to verify your changes before committing

#### Automated Controls
- **GitHub Actions**: CI/CD pipeline performs comprehensive checks on PRs and commits
- **Terraform Format**: Enforces consistent code style
- **TFLint**: Linting tool to enforce best practices and catch errors early
- **Terraform Docs**: Automated documentation generation for modules
- **Terraform Validate**: Confirms configurations are syntactically valid and internally consistent
- **Checkov**: Static code analysis for infrastructure-as-code to detect misconfigurations and security issues

#### Available Make Targets
```
make fmt        # Format Terraform code
make lint       # Run TFLint for Terraform linting
make docs       # Update module documentation
make security   # Run Checkov security scans
make validate   # Validate Terraform configurations
make check-all  # Run all checks at once
```

#### Additional Quality Tools
- **SonarCloud**: Continuous code quality inspection for bugs, vulnerabilities, code smells, and security hotspots
- **GitHub Actions**: Security scanning integrated into CI/CD pipelines

- See [Security Scanning Documentation](docs/SECURITY_SCANNING.md) for details
- See [Testing Documentation](docs/TESTING.md) for comprehensive testing strategy

### Deploy Infrastructure Components
Each component can be deployed independently using the provided scripts:

For Windows:
```batch
deploy_infrastructure.bat [network|iam|ecs|database|cicd|monitoring|security|all]
```

For Linux/macOS:
```bash
./deploy_infrastructure.sh [network|iam|ecs|database|cicd|monitoring|security|all]
```

### Set Up Secrets
```bash
./setup_secrets.sh   # On Linux/macOS
# OR
setup_secrets.bat    # On Windows
```

## Monitoring Capabilities

The monitoring solution provides:

### Prometheus
- Metric collection from ECS, RDS, and AWS resources
- Long-term metrics storage with retention policies
- Alert management for critical events

### Grafana
- Visualization dashboards for all infrastructure components
- Pre-configured dashboards for common metrics
- User-friendly interface for exploring metrics

## CI/CD Pipeline

The integrated CI/CD pipeline enables:

1. Automated builds triggered by GitHub commits
2. Comprehensive test execution
3. Container image creation and registry storage
4. Zero-downtime deployments to ECS using blue/green deployment strategy
5. Automatic rollback capabilities for failed deployments
6. Self-healing Jenkins infrastructure using auto-scaling groups

## Next Steps

For detailed setup and usage instructions, see [Usage.md](Usage.md).

### Additional Documentation

- [Environment Deployment Guide](docs/ENVIRONMENT_DEPLOYMENT.md) - How to deploy and manage environments
- [Automated Patching Guide](docs/AUTOMATED_PATCHING.md) - Automated patching setup and customization
- [Testing Usage Guide](docs/TESTING_USAGE.md) - How to use the quality checking tools and testing frameworks
- [Testing Strategy](docs/TESTING.md) - Comprehensive testing strategy for the infrastructure

## Patching and Update Strategy

This infrastructure implements a comprehensive strategy for maintaining up-to-date and secure systems:

### Managed AMIs
- Uses the latest ECS-optimized Amazon Linux AMIs via dynamic data sources
- Automatically selects the most recent secure AMIs for all EC2 instances

### Automated Patching
- Systems Manager (SSM) Patch Manager for ongoing security updates
- Scheduled maintenance windows with minimal service disruption
- Patch compliance reporting and monitoring

### Immutable Infrastructure
- Blue/Green deployments for both application services and infrastructure
- EC2 instance replacement instead of in-place patching
- Auto Scaling Groups with instance refresh policies

### Monitoring and Notifications
- SNS notifications for patch status and instance replacements
- CloudWatch metrics for patch compliance
- Health check integration with deployment processes

## Environment Configuration

The project supports multiple environments with specialized configurations:

### Development Environment
- Optimized for cost efficiency with spot instances
- Scaled-down resources for development and testing
- Full feature parity with production for accurate testing

### Production Environment
- Highly available configuration using on-demand instances
- Enhanced scaling parameters for production workloads
- Stricter security controls and monitoring

### DR Pilot Light Environment
- Minimal running infrastructure in a secondary AWS region
- Uses spot instances for cost efficiency during normal operations
- Auto scaling capabilities to rapidly expand during failover events

## Secrets Management

This project uses AWS Secrets Manager for handling sensitive information:

1. No sensitive data is stored in the Terraform code
2. All secrets are referenced from AWS Secrets Manager
3. Environment-specific secrets are separated by path

## GitHub Workflow

The project uses GitHub for source control with the following branch strategy:
- `main`: Production-ready code
- `dev`: Development environment code
- `feature/*`: Feature branches
- `hotfix/*`: Emergency fixes

CI/CD pipelines are configured for automatic testing and deployment.

## Additional Documentation

For more detailed documentation, see:
- [Modular Deployment Guide](docs/MODULAR_DEPLOYMENT.md)
- [GitHub Branch Strategy](docs/GITHUB_BRANCH_STRATEGY.md)
- [Security Implementation](docs/SECURITY_IMPLEMENTATION.md)
- [Disaster Recovery Plan](docs/DISASTER_RECOVERY.md)
- [CI/CD Pipeline](docs/CI_CD_PIPELINE.md)