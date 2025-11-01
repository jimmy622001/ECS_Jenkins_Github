# Script to help migrate variables from old tfvars files to the new environment structure

# Define the environments
$environments = @("dev", "prod", "dr")

foreach ($env in $environments) {
    $oldFile = "terraform.tfvars.$env"
    $envDir = "environments\$env"
    $newFile = "$envDir\terraform.tfvars"
    
    # Check if the old file exists
    if (Test-Path $oldFile) {
        Write-Host "Found old variables file: $oldFile" -ForegroundColor Cyan
        
        # Read the content of the old file
        $content = Get-Content -Path $oldFile -Raw
        
        # Ensure the environment directory exists
        if (-not (Test-Path $envDir)) {
            New-Item -ItemType Directory -Path $envDir -Force | Out-Null
            Write-Host "Created directory: $envDir"
        }
        
        # Append the content to the new file
        Add-Content -Path $newFile -Value $content -NoNewline
        Write-Host "Migrated variables to: $newFile" -ForegroundColor Green
    } else {
        Write-Host "No old variables file found for environment: $env" -ForegroundColor Yellow
    }
}

Write-Host "`nMigration complete. Please review the files in the environments directory." -ForegroundColor Green
Write-Host "You can now safely delete the old .tfvars files in the root directory." -ForegroundColor Yellow
