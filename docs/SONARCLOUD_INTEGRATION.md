# SonarCloud Integration

This project uses SonarCloud for continuous code quality inspection. SonarCloud analyzes code for bugs, vulnerabilities, code smells, and security hotspots.

## Features

- **Continuous Code Quality**: Analyze every commit and PR
- **Quality Gate**: Enforce code quality standards
- **Security Analysis**: Find and fix vulnerabilities early
- **Pull Request Decoration**: Get quality feedback directly in GitHub
- **Clean Code**: Track and reduce technical debt

## Setup Instructions

### 1. SonarCloud Account

1. Go to [SonarCloud.io](https://sonarcloud.io/) and sign in with your GitHub account
2. Create an organization and import your repository
3. Complete the setup wizard

### 2. Configure GitHub Repository

#### GitHub Secrets

Add the following secret to your GitHub repository:

- **SONAR_TOKEN**: Your SonarCloud auth token (generate this in SonarCloud)

#### GitHub Variables

Add the following variables to your GitHub repository:

- **SONAR_PROJECT_KEY**: Your SonarCloud project key (format: `organization_repository`)
- **SONAR_ORGANIZATION**: Your SonarCloud organization name

### 3. Jenkins Configuration

1. Install the SonarQube Scanner plugin in Jenkins
2. Configure SonarCloud in Jenkins:
   - Go to Manage Jenkins > Configure System
   - Find the SonarQube servers section
   - Add a server named `SonarCloud` with URL `https://sonarcloud.io`
   - Add your SonarCloud token as a Jenkins credential
3. Ensure the SonarQube Scanner is installed on your Jenkins agent

## Integration Points

- **GitHub Actions**: Automatic analysis on every push and PR
- **Jenkins Pipeline**: Analysis integrated into CI/CD workflow
- **GitHub PRs**: Quality feedback directly in pull requests
- **Quality Gates**: Prevents merging code that doesn't meet quality standards

## Viewing Results

1. Access your project in SonarCloud to see detailed analysis
2. View PR-specific analysis in GitHub pull requests
3. Monitor quality gate status in Jenkins builds

## Customizing Analysis

Adjust settings in `sonar-project.properties` to:

- Exclude files/directories from analysis
- Set quality profiles
- Configure language-specific rules
- Define custom quality gates

## Terraform-Specific Settings

SonarCloud includes specialized analysis for Terraform code:

- Detection of security issues in Terraform resources
- Best practice validation
- Terraform-specific code quality rules

## Best Practices

1. Always check SonarCloud feedback before merging code
2. Address security vulnerabilities as a top priority
3. Gradually reduce technical debt by addressing code smells
4. Use quality gates to enforce minimum standards
5. Include analysis in all development branches
