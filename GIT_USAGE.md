# Git Workflow Guide

This document outlines the Git workflow and branching strategy for this project, including how to work with different environments and the CI/CD pipeline.

## Branch Structure

- `main` - Production environment
  - Protected branch (requires PR to merge into)
  - Deployed to production AWS account
  - Changes should be well-tested before merging

- `dev` - Development environment
  - For active development and testing
  - Deployed to development AWS account
  - Should be stable but may contain work in progress

- `dr` - Disaster Recovery environment (read-only)
  - Automatically synced from `main`
  - Used for failover scenarios
  - Should never be committed to directly

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/your-repo.git
   cd your-repo
   ```

2. **Set up remote tracking branches**
   ```bash
   git fetch --all
   git checkout -b dev origin/dev
   ```

## Development Workflow

### Starting a New Feature/Bugfix

1. Create a new branch from `dev`:
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Push your branch and create a PR:
   ```bash
   git push -u origin feature/your-feature-name
   # Then create a PR from your branch to dev
   ```

### Merging to Production

1. Create a PR from `dev` to `main`
2. Ensure all CI checks pass
3. Get required approvals
4. Squash and merge
5. The CI will automatically sync changes to the `dr` branch

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation only changes
- `style:` Changes that do not affect the meaning of the code
- `refactor:` A code change that neither fixes a bug nor adds a feature
- `perf:` A code change that improves performance
- `test:` Adding missing tests or correcting existing tests
- `chore:` Changes to the build process or auxiliary tools

Example:
```
feat: add user authentication

- Add JWT authentication
- Update user model
- Add login/logout endpoints
```

## CI/CD Pipeline

The CI/CD pipeline is defined in `.github/workflows/terraform-checks.yml` and runs on every push and pull request.

### What the Pipeline Does

1. **On Push to `dev` or `main`:**
   - Runs Terraform format and validation
   - Runs security scans
   - Updates documentation if needed
   - For `main` → Automatically syncs changes to `dr`

2. **On Pull Request:**
   - Runs all quality checks
   - Validates Terraform configuration
   - Checks for security issues

### Required Secrets

Make sure these GitHub Secrets are set in your repository:

- `GH_PAT`: GitHub Personal Access Token with `repo` scope
- `AWS_ACCESS_KEY_ID`: AWS access key for deployment
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for deployment
- `TF_API_TOKEN`: (Optional) For Terraform Cloud/Enterprise

## Handling Hotfixes

For critical production fixes:

1. Create a hotfix branch from `main`:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/description
   ```

2. Make and test your changes

3. Create a PR to `main` and merge it

4. After merging to `main`:
   ```bash
   git checkout dev
   git pull origin dev
   git merge main  # Bring hotfix into dev
   git push origin dev
   ```

## Disaster Recovery

The `dr` branch is automatically kept in sync with `main` by the CI/CD pipeline. In case of a disaster recovery scenario:

1. The `dr` branch will already contain the latest production configuration
2. Manual intervention may be needed to trigger the DR environment deployment
3. After recovery, merge any necessary changes back to `main` and `dev`

## Best Practices

- Always pull the latest changes before starting work
- Keep commits small and focused
- Write clear commit messages
- Never force push to shared branches
- Always create a PR for code review
- Keep your feature branches up to date with the target branch
- Delete merged branches to keep the repository clean

## Troubleshooting

### I can't push to a protected branch
- Create a PR from your feature branch instead of pushing directly
- Make sure you have the necessary permissions

### My PR is failing CI checks
- Check the workflow logs for errors
- Run `terraform fmt` and `terraform validate` locally
- Make sure all tests pass before pushing

### I need to update the `dr` branch manually
```bash
git checkout dr
git merge --no-ff main -m "Manual sync from main"
git push origin dr
```

---
*Last updated: November 2023*
