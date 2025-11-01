# PowerShell script to set up Terraform workspaces

# Check if terraform is installed
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "Terraform is not installed or not in PATH. Please install Terraform first."
    exit 1
}

# Initialize Terraform if not already done
if (-not (Test-Path ".terraform")) {
    Write-Host "Initializing Terraform..." -ForegroundColor Cyan
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform initialization failed."
        exit 1
    }
}

# Function to create or select a workspace
function Set-TerraformWorkspace {
    param (
        [string]$WorkspaceName
    )
    
    Write-Host "`nSetting up $WorkspaceName workspace..." -ForegroundColor Cyan
    
    # Check if workspace exists
    $workspaceList = terraform workspace list
    $workspaceExists = $workspaceList -match "^[* ] $WorkspaceName$"
    
    if ($workspaceExists) {
        Write-Host "Selecting existing workspace: $WorkspaceName"
        terraform workspace select $WorkspaceName
    } else {
        Write-Host "Creating new workspace: $WorkspaceName"
        terraform workspace new $WorkspaceName
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to set up workspace: $WorkspaceName"
        exit 1
    }
    
    # Create environment directory if it doesn't exist
    $envDir = Join-Path -Path "environments" -ChildPath $WorkspaceName
    if (-not (Test-Path $envDir)) {
        New-Item -ItemType Directory -Path $envDir -Force | Out-Null
    }
    
    # Create a terraform.tfvars file in the environment directory if it doesn't exist
    $tfvarsFile = Join-Path -Path $envDir -ChildPath "terraform.tfvars"
    if (-not (Test-Path $tfvarsFile)) {
        # Use the existing tfvars file if it exists in the root
        $rootTfvars = "terraform.tfvars.$WorkspaceName"
        if (Test-Path $rootTfvars) {
            Write-Host "Moving $rootTfvars to $envDir/terraform.tfvars..."
            Move-Item -Path $rootTfvars -Destination $tfvarsFile -Force
        } else {
            # Create a new tfvars file from the example if it exists
            if (Test-Path "terraform.tfvars.example") {
                Write-Host "Creating $tfvarsFile from template..."
                Copy-Item "terraform.tfvars.example" -Destination $tfvarsFile -ErrorAction SilentlyContinue
            } else {
                Write-Host "Creating empty $tfvarsFile..."
                Set-Content -Path $tfvarsFile -Value "# $WorkspaceName environment variables"
            }
        }
        Write-Host "Created/updated $tfvarsFile. Please review and update the values." -ForegroundColor Yellow
    }
}

# Set up all workspaces
$workspaces = @("dev", "prod", "dr")

foreach ($workspace in $workspaces) {
    Set-TerraformWorkspace -WorkspaceName $workspace
}

# Show final status
Write-Host "`nWorkspace setup complete. Current workspace status:" -ForegroundColor Green
terraform workspace list

# Get the current directory path
$currentDir = (Get-Item -Path ".").FullName

Write-Host "`nTo work with a specific environment, use one of these methods:`n" -ForegroundColor Cyan

# Method 1: Change to the directory first
Write-Host "Method 1: Change to the project directory first:" -ForegroundColor Yellow
Write-Host "  cd `"$currentDir`""
Write-Host "  terraform workspace select <workspace>"
Write-Host "  terraform plan -var-file=environments/<workspace>/terraform.tfvars"
Write-Host "  terraform apply -var-file=environments/<workspace>/terraform.tfvars`n"

# Method 2: Use -chdir flag
Write-Host "Method 2: Use the -chdir flag:" -ForegroundColor Yellow
Write-Host "  terraform -chdir=`"$currentDir`" workspace select <workspace>"
Write-Host "  terraform -chdir=`"$currentDir`" plan -var-file=environments/<workspace>/terraform.tfvars"
Write-Host "  terraform -chdir=`"$currentDir`" apply -var-file=environments/<workspace>/terraform.tfvars`n"

# Show next steps
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Review and update the .tfvars files for each environment"
Write-Host "2. Run 'terraform plan' to see what will be created"
Write-Host "3. Run 'terraform apply' to create the infrastructure"
Write-Host "4. Check WORKSPACES.md for more information on managing workspaces"
