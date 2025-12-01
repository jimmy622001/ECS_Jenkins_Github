# GitHub Branch Strategy

This project uses a branch strategy that aligns with the multi-environment architecture. Each environment has its own branch, allowing for isolated development and controlled promotion between environments.

## Branch Structure

### Main Branches

- **`main`**: Default development branch
- **`prod`**: Production environment branch
- **`dev`**: Development environment branch
- **`dr`**: Disaster Recovery environment branch

### Feature Branches

- **`feature/feature-name`**: For new features
- **`bugfix/bug-name`**: For bug fixes
- **`hotfix/issue-name`**: For urgent production fixes
- **`release/version`**: For release candidates

## Workflow

### Development Workflow

1. Create a feature branch from `dev`:
   ```bash
   git checkout dev
   git pull
   git checkout -b feature/my-new-feature
   ```

2. Develop and test your changes locally

3. Push your changes to GitHub:
   ```bash
   git push -u origin feature/my-new-feature
   ```

4. Create a Pull Request to merge into the `dev` branch

5. After code review and testing, merge the PR into the `dev` branch

### Promotion Workflow

To promote changes from one environment to another:

1. Test thoroughly in the source environment

2. Create a PR from source to target branch:
   - From `dev` to `prod` for production deployment
   - From `dev` to `dr` for DR environment updates

3. Review the PR carefully, focusing on environment-specific configurations

4. Merge the PR to deploy to the target environment

### Hotfix Workflow

For urgent production fixes:

1. Create a hotfix branch from `prod`:
   ```bash
   git checkout prod
   git pull
   git checkout -b hotfix/urgent-fix
   ```

2. Implement and test the fix

3. Create a PR to merge into `prod`

4. After merging to `prod`, create another PR to merge the hotfix back to `dev` and `dr`

## Branch Protection Rules

The repository should be set up with the following branch protection rules:

### For `prod` Branch

- Require pull request reviews before merging
- Require at least 2 approvals
- Dismiss stale pull request approvals when new commits are pushed
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Include administrators in these restrictions
- Do not allow bypassing the above settings

### For `dev` and `dr` Branches

- Require pull request reviews before merging
- Require at least 1 approval
- Require status checks to pass before merging
- Include administrators in these restrictions

## Automated Checks

All branches should run the following automated checks when a PR is created:

- Terraform format validation
- Terraform security scans (Checkov)
- Terraform plan to verify changes

## Tagging Strategy

The repository should use semantic versioning for releases:

- **Major version**: Incompatible API changes (`v1.0.0`)
- **Minor version**: Backward-compatible functionality (`v1.1.0`)
- **Patch version**: Backward-compatible bug fixes (`v1.1.1`)

When merging to `prod`, create a tag:
```bash
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0
```

## Deployment Integration

Each branch corresponds to an environment:

- Changes to the `dev` branch trigger deployments to the dev environment
- Changes to the `prod` branch trigger deployments to the production environment
- Changes to the `dr` branch trigger deployments to the DR environment

## Code Reviews

When reviewing PRs, focus on:

1. **Security**: Ensure the changes follow security best practices
2. **Costs**: Evaluate the cost impact of the changes
3. **Performance**: Consider performance implications
4. **Environment-specific Configurations**: Check that environment values are appropriate
5. **Dependencies**: Verify that dependencies are properly managed
6. **Documentation**: Ensure documentation is updated to reflect changes

## PR Templates

Use standardized PR templates to ensure all relevant information is provided:

- Description of changes
- Associated ticket/issue numbers
- Testing performed
- Screenshots or logs if relevant
- Checklist of completed items
- Security implications
- Deployment considerations