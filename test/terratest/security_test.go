package test

import (
	"testing"
	
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestSecurityModule tests the security module functionality
// Note: This test creates real AWS resources and may incur costs
func TestSecurityModule(t *testing.T) {
	t.Skip("Skipping to avoid creating real AWS resources. Remove this line to run the full test.")
	
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../modules/security",
		Vars: map[string]interface{}{
			"vpc_id": "dummy-vpc-id", // This would be replaced with a real VPC ID in a full test
			"name_prefix": "test",
			"environment": "dev",
			"allowed_cidr_blocks": []string{"10.0.0.0/8"},
		},
	})
	
	// Clean up resources when the test completes
	defer terraform.Destroy(t, terraformOptions)
	
	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)
	
	// Verify outputs
	securityGroupId := terraform.Output(t, terraformOptions, "security_group_id")
	assert.NotEmpty(t, securityGroupId, "Security Group ID should not be empty")
}