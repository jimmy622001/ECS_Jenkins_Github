# Terraform State Management

This document outlines how we manage Terraform state in this project and provides instructions for migrating from local state to remote state in AWS S3.

## Current State Configuration

This project is currently configured to use **local state storage**. This means that the Terraform state files are stored on your local filesystem where you run the `terraform` commands. This configuration is suitable for initial development and testing but not recommended for team environments or production workloads.

Local state files are stored in the `.terraform` directory and `terraform.tfstate` files in each environment directory.

## Why Remote State?

In a team environment or for production deployments, remote state storage is strongly recommended for several reasons:

1. **Collaboration**: Multiple team members can access and apply changes to the same infrastructure
2. **State Locking**: Prevents concurrent modifications that could corrupt the state
3. **Versioning**: Provides history of state changes
4. **Security**: Sensitive data can be encrypted at rest
5. **Disaster Recovery**: State is backed up and recoverable

## Migrating to AWS S3 Remote State

When you're ready to migrate from local state to remote state in AWS S3, follow these steps:

### Step 1: Create the S3 buckets for state storage

```bash
# For development environment
aws s3api create-bucket --bucket terraform-state-jenkins-cicd-dev --region us-east-1

# For production environment
aws s3api create-bucket --bucket terraform-state-jenkins-cicd-prod --region us-east-1

# Enable versioning on the buckets
aws s3api put-bucket-versioning --bucket terraform-state-jenkins-cicd-dev --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket terraform-state-jenkins-cicd-prod --versioning-configuration Status=Enabled
```

### Step 2: Create a DynamoDB table for state locking

```bash
# For development environment
aws dynamodb create-table \
  --table-name terraform-state-lock-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# For production environment
aws dynamodb create-table \
  --table-name terraform-state-lock-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Step 3: Update backend configuration

Uncomment and modify the backend configuration in each environment directory:

For `environments/dev/main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-jenkins-cicd-dev"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dev"
    encrypt        = true
  }
  
  required_providers {
    # ...existing provider configurations...
  }
}
```

For `environments/prod/main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-jenkins-cicd-prod"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-prod"
    encrypt        = true
  }
  
  required_providers {
    # ...existing provider configurations...
  }
}
```

### Step 4: Initialize and migrate the state

Run the following command from each environment directory:

```bash
cd environments/dev
terraform init -migrate-state

cd ../prod
terraform init -migrate-state
```

Terraform will prompt you to confirm that you want to migrate your state from local to S3. Type 'yes' to proceed.

## Best Practices for State Management

1. **Never manually edit state files**: Use Terraform commands to manipulate state
2. **Backup state before major changes**: Even with remote state, consider additional backups
3. **Use workspaces**: For managing multiple environments with shared configuration
4. **Restrict access to state**: Use IAM policies to limit who can access state data
5. **Enable encryption**: Always encrypt state data at rest
6. **Monitor state changes**: Set up notifications for state changes
7. **Regularly audit state**: Check for drift and unnecessary resources

## Handling State Conflicts

If multiple team members are working on the same environment and encounter state conflicts:

1. Communicate with the team about ongoing changes
2. Use `terraform refresh` to update the local view of state
3. Resolve conflicts by understanding what changes are in conflict
4. In extreme cases, use `terraform state rm` to selectively remove conflicting resources and re-apply

## Troubleshooting

Common issues and solutions:

1. **Access denied to S3 bucket**: Check IAM permissions
2. **Lock couldn't be acquired**: Someone else is running Terraform against the same state; wait or use `force-unlock` if necessary
3. **State version conflicts**: Ensure all team members use the same Terraform version