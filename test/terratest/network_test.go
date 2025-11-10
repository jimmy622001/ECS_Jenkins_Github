package test

import (
	"testing"
	
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestNetworkModule tests the actual creation of network resources
// Note: This test creates real AWS resources and may incur costs
func TestNetworkModule(t *testing.T) {
	t.Skip("Skipping to avoid creating real AWS resources. Remove this line to run the full test.")
	
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../modules/network",
		Vars: map[string]interface{}{
			"vpc_cidr": "10.0.0.0/16",
			"vpc_name": "test-vpc",
			"region": "us-east-1",
			"azs": []string{"us-east-1a", "us-east-1b"},
			"private_subnets": []string{"10.0.1.0/24", "10.0.2.0/24"},
			"public_subnets": []string{"10.0.101.0/24", "10.0.102.0/24"},
		},
	})
	
	// Clean up resources when the test completes
	defer terraform.Destroy(t, terraformOptions)
	
	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)
	
	// Verify outputs
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")
	
	privateSubnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	assert.Equal(t, 2, len(privateSubnetIds), "Should have created 2 private subnets")
	
	publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	assert.Equal(t, 2, len(publicSubnetIds), "Should have created 2 public subnets")
}