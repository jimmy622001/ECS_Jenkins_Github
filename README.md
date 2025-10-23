# ECS with Jenkins CI/CD and Monitoring Infrastructure

## Overview

This Terraform project deploys a complete AWS infrastructure including:
- VPC with public/private subnets and dedicated database subnet
- ECS Cluster using Fargate
- CI/CD pipeline with Jenkins and GitHub integration
- RDS database in a private subnet
- Prometheus and Grafana monitoring solution

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
│    Jenkins EC2   │    │ Prometheus    │    │ Grafana      │
│    (CI/CD)       │    │ (Monitoring)  │    │ (Dashboards) │
│                  │    │               │    │              │
└─────────┬────────┘    └───────────────┘    └──────────────┘
│
▼
┌──────────────────────┐
│   Amazon ECR         │
│   (Container Registry)│
└──────────┬───────────┘
│
┌──────────────────▼─────────────────────┐ │ ECS Cluster (Fargate) │ │ │ │ ┌─────────────┐ ┌─────────────┐ │ │ │ Service 1 │ │ Service 2 │ │ │ │ (Container) │ │ (Container) │ │ │ └─────┬───────┘ └──────┬──────┘ │ └─────────┼──────────────────┼───────────┘ │ │ ▼ ▼ ┌─────────────────────────────────────────┐ │ Amazon RDS Database │ │ (Private Subnet) │ └─────────────────────────────────────────┘


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
    - Fargate cluster configuration
    - Task definitions and services
    - Load balancer and auto scaling

### 4. Database Module
- **Purpose**: Provides persistent storage
- **Components**:
    - RDS instance in private subnet
    - Encrypted storage with backups
    - High availability configuration

### 5. CI/CD Module
- **Purpose**: Enables continuous integration/deployment
- **Components**:
    - Jenkins server configuration
    - GitHub integration setup
    - Deployment pipeline to ECS

### 6. Monitoring Module
- **Purpose**: Observability and metrics
- **Components**:
    - Prometheus for metrics collection
    - Grafana for visualization
    - Alerting configuration

## Security Features

This infrastructure implements numerous security best practices:

- **Network Isolation**: All resources run in private subnets where possible
- **Encrypted Data**: Encryption at rest and in transit for all sensitive data
- **Least Privilege**: IAM roles with minimum required permissions
- **Network Monitoring**: VPC flow logs capture all network activity
- **Security Groups**: Restrictive inbound/outbound rules for all resources
- **TLS Encryption**: HTTPS for all public-facing services
- **Automated Scanning**: Integration with Checkov and TFLint

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
4. Zero-downtime deployments to ECS
5. Rollback capabilities for failed deployments

## Next Steps

For detailed setup and usage instructions, see [USAGE.md](USAGE.md).