# Modular Deployment Guide

This project implements a modular deployment approach that allows you to deploy infrastructure components separately. This approach offers several benefits:

- **Reduced Risk**: Changes to one component don't affect others
- **Faster Deployments**: Deploy only what has changed
- **Team Collaboration**: Different teams can manage different components
- **Controlled Updates**: Apply updates to infrastructure, cluster, and application independently

## POC Mode vs. Production Mode

This project supports two operational modes:

### POC Mode (Default)

- Uses dummy values instead of AWS Secrets Manager
- Set `use_aws_secrets = false` in your tfvars file (this is the default)
- Faster iteration for testing and development
- No need to set up AWS Secrets Manager initially

### Production Mode

- Uses AWS Secrets Manager for all sensitive information
- Set `use_aws_secrets = true` in your tfvars file
- Requires proper AWS Secrets Manager setup using the provided scripts
- Enhanced security for production deployments

## Component Separation

The infrastructure is separated into these main deployment units:

1. **Base Infrastructure** (infrequent updates)
   - Network components (VPC, subnets, gateways)
   - IAM roles and policies
   - Security groups and baseline security configurations

2. **ECS Cluster** (occasional updates)
   - ECS cluster configuration
   - Auto Scaling Groups
   - Load balancers

3. **Application Components** (frequent updates)
   - Task definitions
   - ECS services
   - Application-specific configurations

4. **CI/CD Pipeline** (infrequent updates)
   - Jenkins server
   - GitHub integration components

5. **Monitoring Infrastructure** (infrequent updates)
   - Prometheus server
   - Grafana dashboards
   - Alert configurations

## Deployment Scripts

The project includes deployment scripts that support modular deployment:

### Windows Batch Scripts (`.bat`)

- `deploy_infrastructure.bat`: Deploy the complete infrastructure
- `deploy_network.bat`: Deploy only the network components
- `deploy_ecs.bat`: Deploy only the ECS cluster
- `deploy_application.bat`: Deploy only the application components
- `deploy_cicd.bat`: Deploy only the CI/CD components
- `deploy_monitoring.bat`: Deploy only the monitoring components

### Linux Shell Scripts (`.sh`)

- `deploy_infrastructure.sh`: Deploy the complete infrastructure
- `deploy_network.sh`: Deploy only the network components
- `deploy_ecs.sh`: Deploy only the ECS cluster
- `deploy_application.sh`: Deploy only the application components
- `deploy_cicd.sh`: Deploy only the CI/CD components
- `deploy_monitoring.sh`: Deploy only the monitoring components

## Using Module-Specific Deployments

### Command Line Approach

You can deploy specific modules using Terraform's `-target` parameter:

```bash
# Deploy only the network module
terraform apply -target=module.network

# Deploy only the IAM module
terraform apply -target=module.iam

# Deploy only the ECS module
terraform apply -target=module.ecs

# Deploy only the database module
terraform apply -target=module.database

# Deploy only the CI/CD module
terraform apply -target=module.cicd

# Deploy only the monitoring module
terraform apply -target=module.monitoring

# Deploy only the security module
terraform apply -target=module.security
```

### Using the Provided Scripts

1. Navigate to the environment directory:
   ```bash
   cd environments/dev
   ```

2. Run the appropriate deployment script:
   ```bash
   # For Windows
   deploy_network.bat
   
   # For Linux/Mac
   ./deploy_network.sh
   ```

### Order of Deployment

When deploying components separately, follow this recommended order:

1. Network module
2. IAM module
3. Security module
4. Database module
5. ECS cluster module
6. CI/CD module
7. Monitoring module
8. Application components

## State Management

This modular approach uses a single Terraform state file for all components. This ensures that inter-component dependencies are properly managed. 

For large-scale deployments, consider using Terraform workspaces or separate state files for each environment:

```bash
# Create and switch to an environment-specific workspace
terraform workspace new dev
terraform workspace select dev
```

## Remote State Management

For team environments, configure a remote state backend (like S3 with DynamoDB locking):

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "environment/component.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## CI/CD Integration

The modular approach integrates with CI/CD pipelines:

1. **Infrastructure Pipeline**: Infrequent updates to base infrastructure
2. **ECS Cluster Pipeline**: Occasional updates to the cluster
3. **Application Pipeline**: Frequent updates to applications running on the cluster

Each pipeline can target specific modules without rebuilding the entire infrastructure.

## Environment-Specific Configurations

Each environment (dev, prod, dr-pilot-light) has its own configuration, allowing for:

- Different instance sizes
- Different scaling parameters
- Environment-specific security settings
- Cost optimization based on environment purpose

## Handling Dependencies

When modifying a component with dependencies, ensure that dependent components are updated appropriately:

1. **Direct Dependencies**: Components that directly depend on the modified component
2. **Indirect Dependencies**: Components that depend on components that depend on the modified component
3. **Shared Resources**: Resources that are used by multiple components

Use `terraform plan` to review all changes before applying them.