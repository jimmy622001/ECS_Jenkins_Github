# Terraform Provider Version Management

This document provides guidance on managing Terraform provider versions in this project.

## Current Provider Configuration

The AWS provider version is configured with the following constraints:

- Root module: `>= 5.0.0, <= 6.19.0`
- Dev environment: `>= 4.0, <= 6.19.0`
- Prod environment: `>= 4.0, <= 6.19.0`

These constraints are designed to be compatible with the locked provider version in the dependency lock file (6.19.0).

## Understanding Version Constraints

Terraform uses semantic versioning (SemVer) for version constraints. The common formats are:

- `= 1.2.3` - Exact version match
- `>= 1.2.0` - Version 1.2.0 or newer
- `~> 1.2` - Any version in the 1.2.* range
- `>= 1.0, <= 2.0` - Any version between 1.0 and 2.0, inclusive

## Managing Provider Versions

### Updating Provider Versions

To update the AWS provider to a newer version:

```bash
terraform init -upgrade
```

This will fetch the latest version of the provider that matches your version constraints.

### Locking to a Specific Version

If you need to lock to a specific version:

1. Update the version constraint in the required_providers block
2. Run `terraform init`

### Resolving Version Conflicts

If you encounter version conflicts:

1. Check the `.terraform.lock.hcl` file to see which provider versions are locked
2. Update the version constraints in your Terraform files to be compatible
3. Run `terraform init` to re-initialize

## Best Practices

1. **Be Specific**: Use specific version constraints to avoid unexpected changes
2. **Test Updates**: Test provider updates in development before applying to production
3. **Document Changes**: Document any provider version changes and reasons
4. **Check Compatibility**: Review the provider's release notes for breaking changes

## Troubleshooting

If you encounter the error `locked provider does not match configured version constraint`, it means the version in your lock file doesn't match your configuration. Options to resolve:

1. Update your version constraint to include the locked version
2. Use `terraform init -upgrade` to fetch a new version that matches your constraints
3. Remove `.terraform.lock.hcl` and run `terraform init` again (not recommended for production)