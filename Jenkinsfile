pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    environment {
        // Define your environment variables here
        AWS_REGION = 'us-east-1'
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Select the environment to deploy'
        )

        booleanParam(
            name: 'APPLY',
            defaultValue: false,
            description: 'Apply the Terraform changes'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Security Scan - Checkov') {
            steps {
                sh 'pip install checkov'
                sh 'checkov -d . --skip-check CKV_AWS_23,CKV_AWS_24 --output cli --output junitxml --output-file-path reports/checkov'
            }
            post {
                always {
                    junit skipPublishingChecks: true, testResults: 'reports/checkov/results_junitxml.xml'
                }
            }
        }
        
        stage('Lint - TFLint') {
            steps {
                sh 'curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash'
                sh 'tflint --init'
                sh 'tflint --recursive --format junit > reports/tflint-report.xml || true'
            }
            post {
                always {
                    junit skipPublishingChecks: true, testResults: 'reports/tflint-report.xml'
                }
            }
        }
        
        stage('Terraform Tests - Validation') {
            steps {
                sh 'cd test/terratest && go test -v -run TestTerraformValidate'
            }
        }

        stage('Terraform Format') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                withSonarQubeEnv('SonarCloud') {
                    // Using sonar-scanner with the properties file
                    // The configuration is in sonar-project.properties
                    sh 'sonar-scanner'
                }
            }
        }

        stage('SonarCloud Quality Gate') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    // Wait for the quality gate response from SonarCloud
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform validate -no-color'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform plan -no-color -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.APPLY == true }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply -no-color -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
