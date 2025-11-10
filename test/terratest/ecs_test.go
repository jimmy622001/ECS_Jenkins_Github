package test

import (
	"testing"
	
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestECSModule tests the ECS module functionality
// Note: This test creates real AWS resources and may incur costs
func TestECSModule(t *testing.T) {
	t.Skip("Skipping to avoid creating real AWS resources. Remove this line to run the full test.")
	
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../modules/ecs",
		Vars: map[string]interface{}{
			"name_prefix": "test",
			"environment": "dev",
			"vpc_id": "dummy-vpc-id", // This would be replaced with a real VPC ID in a full test
			"subnet_ids": []string{"subnet-1", "subnet-2"}, // These would be replaced with real subnet IDs
			"container_image": "nginx:latest",
			"container_port": 80,
			"desired_count": 1,
			"region": "us-east-1",
		},
	})
	
	// Clean up resources when the test completes
	defer terraform.Destroy(t, terraformOptions)
	
	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)
	
	// Verify outputs
	clusterArn := terraform.Output(t, terraformOptions, "cluster_arn")
	assert.NotEmpty(t, clusterArn, "ECS Cluster ARN should not be empty")
	
	serviceArn := terraform.Output(t, terraformOptions, "service_arn")
	assert.NotEmpty(t, serviceArn, "ECS Service ARN should not be empty")
}