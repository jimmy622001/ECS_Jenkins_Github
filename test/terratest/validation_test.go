package test

import (
	"testing"
	
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestTerraformValidate validates the Terraform configuration without creating resources
func TestTerraformValidate(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
	})

	// This will run `terraform init` and `terraform validate`
	output := terraform.InitAndValidate(t, terraformOptions)
	
	// Validation should succeed without errors
	assert.Contains(t, output, "Success!")
}

// TestNetworkModuleValidate specifically validates the network module
func TestNetworkModuleValidate(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../modules/network",
	})

	output := terraform.InitAndValidate(t, terraformOptions)
	assert.Contains(t, output, "Success!")
}

// TestECSModuleValidate specifically validates the ECS module
func TestECSModuleValidate(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../modules/ecs",
	})

	output := terraform.InitAndValidate(t, terraformOptions)
	assert.Contains(t, output, "Success!")
}