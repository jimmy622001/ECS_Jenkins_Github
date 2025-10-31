# ECS with Jenkins CI/CD and Monitoring Infrastructure

## Overview

This Terraform project deploys a complete AWS infrastructure including:
- VPC with public/private subnets and dedicated database subnet
- ECS Cluster using Fargate with blue/green deployment capability
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

## Security Features

This infrastructure implements numerous security best practices:

- **Network Isolation**: All resources run in private subnets where possible
- **Encrypted Data**: Encryption at rest and in transit for all sensitive data
- **Least Privilege**: IAM roles with minimum required permissions
- **Network Monitoring**: VPC flow logs capture all network activity
- **Security Groups**: Restrictive inbound/outbound rules for all resources
- **TLS Encryption**: HTTPS for all public-facing services
- **Automated Scanning**: Integration with Checkov and TFLint
- **Automated Patching**: Systems Manager Patch Manager for automatic security updates
- **Instance Metadata Security**: IMDSv2 requirement enforced on all EC2 instances
- **Immutable Infrastructure**: Updated AMIs instead of in-place patching

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

For detailed setup and usage instructions, see [Usage-and-Applicaton-Guide.md](Usage-and-Applicaton-Guide.md).

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

## Multi-Environment Architecture

This project supports multiple environments with specialized configurations:

### Development Environment
- Optimized for cost efficiency with spot instances
- Scaled-down resources for development and testing
- Full feature parity with production for accurate testing

### Production Environment
- Highly available configuration using on-demand instances
- Enhanced scaling parameters for production workloads
- Stricter security controls and monitoring

## Disaster Recovery Strategy

The infrastructure includes a comprehensive DR strategy:

### Pilot Light in Secondary Region
- Minimal running infrastructure in a secondary AWS region (us-west-2)
- Uses spot instances for cost efficiency during normal operations
- Auto scaling capabilities to rapidly expand during failover events
- Warm pool of stopped instances for faster recovery

### Automated Failover Testing
- Scheduled Lambda function for regular DR testing
- Route 53 health checks for automatic traffic routing
- Blue/Green deployment capability across regions
- SNS notifications for failover events and status updates

### Cross-Region Data Replication
- Database snapshots replicated to DR region
- Automated synchronization of critical configuration data
- State tracking for replication health and consistency

### Multi-Region Coordination
- Route 53 for DNS-based failover between regions
- CloudWatch for cross-region monitoring
- Centralized logging for comprehensive visibility