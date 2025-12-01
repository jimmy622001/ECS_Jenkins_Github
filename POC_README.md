# ECS with Jenkins CI/CD and Monitoring Infrastructure POC

This Proof of Concept (POC) demonstrates a complete AWS infrastructure including:

- VPC with public/private subnets and dedicated database subnet
- ECS Cluster using EC2 instances with blue/green deployment capability
- CI/CD pipeline with Jenkins and GitHub integration
- RDS database in a private subnet
- Prometheus and Grafana monitoring solution
- Automated patching and AMI management

## Quick Start for POC

For the POC phase, we've simplified the setup process by using dummy values to replace AWS Secrets Manager.

### Prerequisites

1. AWS CLI installed and configured with appropriate credentials
2. Terraform v1.0.0 or later
3. Git (for version control)

### Running the POC

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ECS_Jenkins_Github
   ```

2. **Choose an environment to deploy**
   ```bash
   cd environments/dev
   ```

3. **Run Terraform**
   ```bash
   # Initialize Terraform
   terraform init
   
   # Plan the deployment
   terraform plan -out=tfplan
   
   # Apply the plan
   terraform apply "tfplan"
   ```

### Modular Deployment

You can deploy components separately using the provided scripts:

- **Network Infrastructure**:
  ```bash
  # Windows
  deploy_network.bat
  
  # Linux/Mac
  ./deploy_network.sh
  ```

- **ECS Cluster**:
  ```bash
  # Windows
  deploy_ecs.bat
  
  # Linux/Mac
  ./deploy_ecs.sh
  ```

- **CI/CD Pipeline**:
  ```bash
  # Windows
  deploy_cicd.bat
  
  # Linux/Mac
  ./deploy_cicd.sh
  ```

- **Monitoring**:
  ```bash
  # Windows
  deploy_monitoring.bat
  
  # Linux/Mac
  ./deploy_monitoring.sh
  ```

- **Application Deployment**:
  ```bash
  # Windows
  deploy_application.bat
  
  # Linux/Mac
  ./deploy_application.sh
  ```

## Environment-Specific Configurations

The POC supports multiple environments:

- `dev` - Development environment (smaller instances, cost-optimized)
- `prod` - Production environment (larger instances, high availability)
- `dr-pilot-light` - Disaster recovery environment (minimal standby resources)

Each environment has its own configuration in its respective directory.

## POC to Production Migration

When ready to move from POC to production:

1. Set up AWS Secrets Manager with real secrets as specified in `docs/SECRETS_MANAGEMENT_UPDATED.md`
2. Set `use_aws_secrets = true` in your environment's `terraform.tfvars` file
3. Follow the branch strategy outlined in `docs/GITHUB_BRANCH_STRATEGY.md`

## Documentation

Detailed information is available in the `docs` directory:

- **[MODULAR_DEPLOYMENT.md](docs/MODULAR_DEPLOYMENT.md)** - How to deploy each component separately
- **[SECRETS_MANAGEMENT_UPDATED.md](docs/SECRETS_MANAGEMENT_UPDATED.md)** - Managing sensitive information
- **[GITHUB_BRANCH_STRATEGY.md](docs/GITHUB_BRANCH_STRATEGY.md)** - Branch strategy for different environments
- **[OWASP_SECURITY.md](docs/OWASP_SECURITY.md)** - Web application security implementations
- **[CI_CD_INTEGRATION.md](docs/CI_CD_INTEGRATION.md)** - Details on the CI/CD pipeline
- **[AUTOMATED_PATCHING.md](docs/AUTOMATED_PATCHING.md)** - Automated updating and patching strategy

## Security Note

This POC uses dummy values for demonstration purposes. Before deploying to production:

1. Replace all dummy values with real, secure values
2. Implement proper IAM permissions
3. Enable all security features
4. Follow the guidelines in the security documentation

## Support

For questions about this POC, contact the infrastructure team.