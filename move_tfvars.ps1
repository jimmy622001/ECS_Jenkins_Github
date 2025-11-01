# Script to move tfvars files to their respective environment directories

$environments = @("dev", "prod", "dr")

foreach ($env in $environments) {
    $sourceFile = "terraform.tfvars.$env"
    $targetDir = Join-Path -Path "environments" -ChildPath $env
    $targetFile = Join-Path -Path $targetDir -ChildPath "terraform.tfvars"
    
    # Create the environment directory if it doesn't exist
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Write-Host "Created directory: $targetDir"
    }
    
    # Move the tfvars file if it exists and the target doesn't exist
    if ((Test-Path $sourceFile) -and (-not (Test-Path $targetFile))) {
        Move-Item -Path $sourceFile -Destination $targetFile -Force
        Write-Host "Moved $sourceFile to $targetFile"
    } elseif (Test-Path $sourceFile) {
        Write-Host "Skipping $sourceFile - $targetFile already exists"
    } else {
        Write-Host "Source file not found: $sourceFile"
    }
}

Write-Host "`nCleanup complete. You can now safely delete this script." -ForegroundColor Green
