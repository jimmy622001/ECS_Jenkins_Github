# SonarCloud Integration

This document describes how to use SonarCloud integration with this project for code quality analysis.

## Overview

SonarCloud is a cloud-based code quality and security service. It performs static code analysis to detect bugs, code smells, and security vulnerabilities in your code. This project is configured to use SonarCloud for continuous code quality inspection.

## Setup

### 1. SonarCloud Account

1. Go to [SonarCloud.io](https://sonarcloud.io/) and sign in with your GitHub account
2. Create an organization or use an existing one
3. Note your organization name/key

### 2. GitHub Setup

#### Secrets and Variables

Add the following in your GitHub repository (Settings → Secrets and Variables → Actions):

1. **Secrets**:
   - `SONAR_TOKEN`: Your SonarCloud authentication token

2. **Variables**:
   - `SONAR_PROJECT_KEY`: Your SonarCloud project key (typically `your-organization_ecs-jenkins-github`)
   - `SONAR_ORGANIZATION`: Your SonarCloud organization name

### 3. Jenkins Setup

1. **Install Plugin**:
   - Install "SonarQube Scanner" plugin in Jenkins

2. **Configure SonarCloud in Jenkins**:
   - Go to Manage Jenkins → Configure System
   - Find "SonarQube servers" section
   - Add a server with:
     - Name: `SonarCloud` (must match name in Jenkinsfile)
     - Server URL: `https://sonarcloud.io`
     - Add your SonarCloud token as a Jenkins credential

## Usage

### Analysis Triggers

Code analysis will automatically run on:

1. **GitHub Actions**:
   - Every push to main, dev, or dr branches
   - Every pull request against these branches
   - Manual trigger via GitHub Actions interface

2. **Jenkins Pipeline**:
   - Every build executed through the Jenkins pipeline

### Reading Reports

1. Go to [SonarCloud.io](https://sonarcloud.io/)
2. Navigate to your organization and project
3. Review:
   - Quality Gate status
   - Issues (bugs, vulnerabilities, code smells)
   - Security hotspots
   - Code coverage (if configured)

### Quality Gates

SonarCloud uses Quality Gates to determine if your code meets the minimum quality requirements. The default Quality Gate checks:

- Code Coverage
- Duplicated Lines
- Maintainability Rating
- Reliability Rating
- Security Rating
- Security Hotspots Reviewed

You can customize the Quality Gate in the SonarCloud interface.

## Troubleshooting

### Common Issues

1. **Analysis Fails to Start**:
   - Check that GitHub secrets and variables are set correctly
   - Verify Jenkins credentials are configured properly

2. **Quality Gate Failures**:
   - Review the specific issues in the SonarCloud interface
   - Address the highest priority issues first (bugs and vulnerabilities)

3. **False Positives**:
   - Mark issues as "False Positive" in the SonarCloud interface
   - Consider adjusting rule settings if specific rules generate many false positives