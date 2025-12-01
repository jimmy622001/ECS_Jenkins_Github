@echo off
REM Script to create the required AWS Secrets Manager secrets

REM Configuration - Update these values
SET PROJECT_NAME=ecs-jenkins-dev
SET ENVIRONMENT=dev
SET AWS_REGION=us-east-1
SET AWS_PROFILE=default

REM Check if AWS CLI is installed
aws --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo AWS CLI is not installed. Please install it first.
    exit /b 1
)

REM 1. Database Credentials
echo Creating/updating database credentials secret...
aws secretsmanager describe-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-db-credentials" --region "%AWS_REGION%" --profile "%AWS_PROFILE%" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    aws secretsmanager update-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-db-credentials" --secret-string "{\"username\":\"dbadmin\",\"password\":\"YourStrongPasswordHere123!\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
) ELSE (
    aws secretsmanager create-secret --name "%PROJECT_NAME%-%ENVIRONMENT%-db-credentials" --secret-string "{\"username\":\"dbadmin\",\"password\":\"YourStrongPasswordHere123!\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
)

REM 2. Grafana Credentials
echo Creating/updating Grafana credentials secret...
aws secretsmanager describe-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-grafana-credentials" --region "%AWS_REGION%" --profile "%AWS_PROFILE%" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    aws secretsmanager update-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-grafana-credentials" --secret-string "{\"admin_user\":\"admin\",\"admin_password\":\"YourStrongGrafanaPasswordHere123!\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
) ELSE (
    aws secretsmanager create-secret --name "%PROJECT_NAME%-%ENVIRONMENT%-grafana-credentials" --secret-string "{\"admin_user\":\"admin\",\"admin_password\":\"YourStrongGrafanaPasswordHere123!\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
)

REM 3. SSH Key
echo Creating/updating SSH key secret...
aws secretsmanager describe-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-ssh-key" --region "%AWS_REGION%" --profile "%AWS_PROFILE%" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    aws secretsmanager update-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-ssh-key" --secret-string "{\"key_name\":\"jenkins-ssh-key\",\"private_key\":\"PLACEHOLDER_FOR_ACTUAL_PRIVATE_KEY_CONTENT\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
) ELSE (
    aws secretsmanager create-secret --name "%PROJECT_NAME%-%ENVIRONMENT%-ssh-key" --secret-string "{\"key_name\":\"jenkins-ssh-key\",\"private_key\":\"PLACEHOLDER_FOR_ACTUAL_PRIVATE_KEY_CONTENT\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
)

REM 4. Network Security
echo Creating/updating network security secret...
aws secretsmanager describe-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-network-security" --region "%AWS_REGION%" --profile "%AWS_PROFILE%" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    aws secretsmanager update-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-network-security" --secret-string "{\"trusted_ips\":[\"203.0.113.1/32\",\"198.51.100.0/24\"]}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
) ELSE (
    aws secretsmanager create-secret --name "%PROJECT_NAME%-%ENVIRONMENT%-network-security" --secret-string "{\"trusted_ips\":[\"203.0.113.1/32\",\"198.51.100.0/24\"]}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
)

REM 5. Security Settings
echo Creating/updating security settings secret...
aws secretsmanager describe-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-security-settings" --region "%AWS_REGION%" --profile "%AWS_PROFILE%" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    aws secretsmanager update-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-security-settings" --secret-string "{\"waf_rate_limit\":1000,\"max_request_size\":10485760,\"enable_security_hub\":false,\"enable_guardduty\":true}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
) ELSE (
    aws secretsmanager create-secret --name "%PROJECT_NAME%-%ENVIRONMENT%-security-settings" --secret-string "{\"waf_rate_limit\":1000,\"max_request_size\":10485760,\"enable_security_hub\":false,\"enable_guardduty\":true}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
)

REM 6. AWS Config
echo Creating/updating AWS config secret...
aws secretsmanager describe-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-aws-config" --region "%AWS_REGION%" --profile "%AWS_PROFILE%" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    aws secretsmanager update-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-aws-config" --secret-string "{\"aws_account_id\":\"123456789012\",\"cross_account_role\":\"arn:aws:iam::123456789012:role/CrossAccountAccessRole\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
) ELSE (
    aws secretsmanager create-secret --name "%PROJECT_NAME%-%ENVIRONMENT%-aws-config" --secret-string "{\"aws_account_id\":\"123456789012\",\"cross_account_role\":\"arn:aws:iam::123456789012:role/CrossAccountAccessRole\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
)

REM 7. Domain Config
echo Creating/updating domain config secret...
aws secretsmanager describe-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-domain-config" --region "%AWS_REGION%" --profile "%AWS_PROFILE%" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    aws secretsmanager update-secret --secret-id "%PROJECT_NAME%-%ENVIRONMENT%-domain-config" --secret-string "{\"domain_name\":\"dev.yourdomain.com\",\"enable_https\":true,\"certificate_arn\":\"arn:aws:acm:region:account-id:certificate/certificate-id\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
) ELSE (
    aws secretsmanager create-secret --name "%PROJECT_NAME%-%ENVIRONMENT%-domain-config" --secret-string "{\"domain_name\":\"dev.yourdomain.com\",\"enable_https\":true,\"certificate_arn\":\"arn:aws:acm:region:account-id:certificate/certificate-id\"}" --region "%AWS_REGION%" --profile "%AWS_PROFILE%"
)

echo All secrets have been created successfully!